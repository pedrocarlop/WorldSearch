import CoreGraphics
import Metal

final class WordSuccessWaveEffect: FXEffect {
    private enum Constants {
        static let duration: Float = 0.55
        static let ringWidth: Float = 18
        static let additiveRingWidth: Float = 12
        static let maxConcurrentWaves = 24
    }

    private struct WaveState {
        let startTime: Float
        let center: CGPoint
        let maxRadius: Float
        let intensity: Float
        let pathStart: CGPoint
        let pathEnd: CGPoint
        let bounds: CGRect
    }

    private let alphaPipeline: MTLRenderPipelineState
    private let additivePipeline: MTLRenderPipelineState
    private let uniformBuffer: MTLBuffer
    private let uniformStride: Int

    private var elapsedTime: Float = 0
    private var waves: [WaveState] = []
    private var debugEnabled = false

    var isActive: Bool {
        !waves.isEmpty
    }

    init?(
        device: MTLDevice,
        alphaPipeline: MTLRenderPipelineState,
        additivePipeline: MTLRenderPipelineState
    ) {
        self.alphaPipeline = alphaPipeline
        self.additivePipeline = additivePipeline

        uniformStride = MemoryLayout<FXOverlayUniforms>.stride.alignedTo256
        let bufferLength = uniformStride * Constants.maxConcurrentWaves
        guard let uniformBuffer = device.makeBuffer(length: bufferLength, options: .storageModeShared) else {
            return nil
        }
        self.uniformBuffer = uniformBuffer
    }

    func setDebugEnabled(_ enabled: Bool) {
        debugEnabled = enabled
    }

    func handle(event: FXEvent) {
        guard event.type == .wordSuccessWave else { return }
        guard event.gridBounds.width > 0, event.gridBounds.height > 0 else { return }

        guard let center = MetalFXCoordinateMapper.average(event.cellCenters) ?? event.pathPoints.first else {
            return
        }

        let intensity = min(max(event.intensity, 0), 1)
        let pathStart = event.pathPoints.first ?? center
        let pathEnd = event.pathPoints.last ?? center
        let maxRadius = Float(hypot(event.gridBounds.width, event.gridBounds.height))

        waves.append(
            WaveState(
                startTime: elapsedTime,
                center: center,
                maxRadius: maxRadius,
                intensity: intensity,
                pathStart: pathStart,
                pathEnd: pathEnd,
                bounds: event.gridBounds
            )
        )

        if waves.count > Constants.maxConcurrentWaves {
            waves.removeFirst(waves.count - Constants.maxConcurrentWaves)
        }
    }

    func update(dt: Float) {
        let clampedDelta = max(0, min(dt, 0.1))
        elapsedTime += clampedDelta
        waves.removeAll { elapsedTime - $0.startTime >= Constants.duration }
    }

    func draw(
        encoder: MTLRenderCommandEncoder,
        resolution: SIMD2<Float>,
        time: Float
    ) {
        guard !waves.isEmpty else { return }

        encoder.setRenderPipelineState(alphaPipeline)

        let activeWaves = waves.suffix(Constants.maxConcurrentWaves)
        for (index, wave) in activeWaves.enumerated() {
            let age = max(0, elapsedTime - wave.startTime)
            let linearProgress = min(age / Constants.duration, 1)
            let progress = easeOutCubic(linearProgress)
            let alphaDecay = 1 - smoothStep(0.74, 1, linearProgress)
            let additiveDecay = 1 - smoothStep(0.62, 1, linearProgress)

            let baseUniforms = FXOverlayUniforms(
                resolution: resolution,
                center: SIMD2<Float>(Float(wave.center.x), Float(wave.center.y)),
                progress: progress,
                maxRadius: wave.maxRadius,
                ringWidth: Constants.ringWidth,
                alpha: max(0, alphaDecay) * (0.2 + 0.2 * wave.intensity),
                intensity: wave.intensity,
                debugEnabled: debugEnabled ? 1 : 0,
                pathStart: SIMD2<Float>(Float(wave.pathStart.x), Float(wave.pathStart.y)),
                pathEnd: SIMD2<Float>(Float(wave.pathEnd.x), Float(wave.pathEnd.y)),
                bounds: SIMD4<Float>(
                    Float(wave.bounds.minX),
                    Float(wave.bounds.minY),
                    Float(wave.bounds.width),
                    Float(wave.bounds.height)
                ),
                time: time,
                effectKind: FXEffectKind.wave,
                params: SIMD2<Float>(0.0, 0.0)
            )

            let additiveUniforms = FXOverlayUniforms(
                resolution: resolution,
                center: baseUniforms.center,
                progress: min(1.0, progress + 0.025),
                maxRadius: wave.maxRadius,
                ringWidth: Constants.additiveRingWidth,
                alpha: max(0, additiveDecay) * (0.22 + 0.18 * wave.intensity),
                intensity: min(1.2 as Float, wave.intensity + 0.12),
                debugEnabled: baseUniforms.debugEnabled,
                pathStart: baseUniforms.pathStart,
                pathEnd: baseUniforms.pathEnd,
                bounds: baseUniforms.bounds,
                time: time,
                effectKind: FXEffectKind.wave,
                params: SIMD2<Float>(1.0, 0.0)
            )

            let offset = index * uniformStride
            let pointer = uniformBuffer.contents().advanced(by: offset)
            var mutableBaseUniforms = baseUniforms
            withUnsafeBytes(of: &mutableBaseUniforms) { bytes in
                guard let baseAddress = bytes.baseAddress else { return }
                pointer.copyMemory(from: baseAddress, byteCount: bytes.count)
            }

            encoder.setRenderPipelineState(alphaPipeline)
            encoder.setFragmentBuffer(uniformBuffer, offset: offset, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)

            var mutableAdditiveUniforms = additiveUniforms
            withUnsafeBytes(of: &mutableAdditiveUniforms) { bytes in
                guard let baseAddress = bytes.baseAddress else { return }
                pointer.copyMemory(from: baseAddress, byteCount: bytes.count)
            }

            encoder.setRenderPipelineState(additivePipeline)
            encoder.setFragmentBuffer(uniformBuffer, offset: offset, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
    }

    func reset() {
        elapsedTime = 0
        waves.removeAll(keepingCapacity: false)
    }

    private func easeOutCubic(_ value: Float) -> Float {
        let t = min(max(value, 0), 1)
        let oneMinusT = 1 - t
        return 1 - oneMinusT * oneMinusT * oneMinusT
    }

    private func smoothStep(_ edge0: Float, _ edge1: Float, _ value: Float) -> Float {
        guard edge0 != edge1 else {
            return value >= edge0 ? 1 : 0
        }
        let t = min(max((value - edge0) / (edge1 - edge0), 0), 1)
        return t * t * (3 - 2 * t)
    }
}
