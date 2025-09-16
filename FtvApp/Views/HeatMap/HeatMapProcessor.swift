import Foundation
import CoreGraphics

struct HeatmapProcessor {

    struct GridResult {
        let grid: [[Int]]
        let maxValue: Int
    }

    static func process(points: [CGPoint],
                        worldBounds: CGRect,
                        gridSize: (rows: Int, cols: Int)) -> GridResult {

        let rows = max(gridSize.rows, 1)
        let cols = max(gridSize.cols, 1)

        var grid = Array(repeating: Array(repeating: 0, count: cols), count: rows)
        var maxValue = 0

        let minX = worldBounds.minX
        let maxX = worldBounds.maxX
        let minY = worldBounds.minY
        let maxY = worldBounds.maxY

        let spanX = max(maxX - minX, 0.001)
        let spanY = max(maxY - minY, 0.001)

        for p in points {
            let nx = (p.x - minX) / spanX           
            let ny = (p.y - minY) / spanY           
            let invY = 1 - ny                       

            var col = Int(nx * CGFloat(cols))
            var row = Int(invY * CGFloat(rows))

            if col >= cols { col = cols - 1 }
            if row >= rows { row = rows - 1 }
            if col < 0 { col = 0 }
            if row < 0 { row = 0 }

            grid[row][col] &+= 1
            if grid[row][col] > maxValue { maxValue = grid[row][col] }
        }

        return GridResult(grid: grid, maxValue: max(maxValue, 1)) 
    }
}
