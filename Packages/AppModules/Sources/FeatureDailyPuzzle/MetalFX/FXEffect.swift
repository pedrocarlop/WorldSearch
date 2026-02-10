import Metal

public protocol FXEffect: AnyObject {
    var isActive: Bool { get }

    func handle(event: FXEvent)
    func update(dt: Float)
    func draw(
        encoder: MTLRenderCommandEncoder,
        resolution: SIMD2<Float>,
        time: Float
    )
    func reset()
}
