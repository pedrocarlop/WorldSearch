import CoreGraphics

public enum FXEventType: Sendable {
    case wordSuccessWave
    case wordSuccessScanline
    case wordSuccessParticles
    case wordSuccessTrail
    case wordSuccessPulseBloom
    case wordSuccessScreenBloom
    case wordSuccessInkReveal
    case wordSuccessLiquidGlass
    case wordSuccessDissolve
    case wordSuccessMagnetSnapTrail
    case wordSuccessCellVolume
    case wordSuccessLaserHeat
}

public struct FXEvent: Sendable {
    public let type: FXEventType
    public let timestamp: Double
    public let gridBounds: CGRect
    public let pathPoints: [CGPoint]
    public let cellCenters: [CGPoint]
    public let wordRects: [CGRect]?
    public let intensity: Float

    public init(
        type: FXEventType,
        timestamp: Double,
        gridBounds: CGRect,
        pathPoints: [CGPoint],
        cellCenters: [CGPoint],
        wordRects: [CGRect]?,
        intensity: Float
    ) {
        self.type = type
        self.timestamp = timestamp
        self.gridBounds = gridBounds
        self.pathPoints = pathPoints
        self.cellCenters = cellCenters
        self.wordRects = wordRects
        self.intensity = intensity
    }
}
