import Core
import CoreGraphics

enum MetalFXCoordinateMapper {
    static func clipSpacePoint(for point: CGPoint, in size: CGSize) -> SIMD2<Float> {
        guard size.width > 0, size.height > 0 else {
            return SIMD2<Float>(0, 0)
        }

        let x = Float((point.x / size.width) * 2 - 1)
        let y = Float(1 - (point.y / size.height) * 2)
        return SIMD2<Float>(x, y)
    }

    static func average(_ points: [CGPoint]) -> CGPoint? {
        guard !points.isEmpty else { return nil }

        let sum = points.reduce(CGPoint.zero) { partial, point in
            CGPoint(x: partial.x + point.x, y: partial.y + point.y)
        }
        let count = CGFloat(points.count)
        return CGPoint(x: sum.x / count, y: sum.y / count)
    }
}

enum MetalFXGridGeometry {
    static func pathPoints(
        for positions: [GridPosition],
        in gridBounds: CGRect,
        rows: Int,
        cols: Int
    ) -> [CGPoint] {
        positions.map { position in
            center(for: position, in: gridBounds, rows: rows, cols: cols)
        }
    }

    static func center(
        for position: GridPosition,
        in gridBounds: CGRect,
        rows: Int,
        cols: Int
    ) -> CGPoint {
        let safeRows = max(rows, 1)
        let safeCols = max(cols, 1)
        let cellWidth = gridBounds.width / CGFloat(safeCols)
        let cellHeight = gridBounds.height / CGFloat(safeRows)

        return CGPoint(
            x: CGFloat(position.col) * cellWidth + cellWidth / 2,
            y: CGFloat(position.row) * cellHeight + cellHeight / 2
        )
    }
}
