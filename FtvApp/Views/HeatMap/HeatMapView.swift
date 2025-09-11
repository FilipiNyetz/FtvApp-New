import SwiftUI

// Heatmap “blurred” com rotação em torno da ORIGEM (0,0).
//- points: pontos no sistema do “mundo” (metros)
//- worldBounds: retângulo fixo do mundo (ex.: meia quadra)
//- rotationDegrees: rotação aplicada aos pontos ao redor da ORIGEM (0,0)
//- flipX/flipY: espelhamento opcional no mundo
struct HeatmapView: View {
    let points: [CGPoint]
    var rotationDegrees: CGFloat = 0
    var flipX: Bool = false
    var flipY: Bool = false

    private let idealCellSize: CGFloat = 20

    var body: some View {
        Canvas { context, size in
            guard !points.isEmpty else { return }

            // 🔹 Calcula os bounds a partir dos pontos
            let minX = points.map(\.x).min() ?? 0
            let maxX = points.map(\.x).max() ?? 1
            let minY = points.map(\.y).min() ?? 0
            let maxY = points.map(\.y).max() ?? 1
            let bounds = CGRect(x: minX, y: minY,
                                width: maxX - minX,
                                height: maxY - minY)

            // 🔹 Define grid (número de linhas e colunas)
            let cols = max(Int(size.width / idealCellSize), 1)
            let rows = max(Int(size.height / idealCellSize), 1)

            // 🔹 Processa o heatmap com os bounds corretos
            let result = HeatmapProcessor.process(points: points,
                                                  worldBounds: bounds,
                                                  gridSize: (rows: rows, cols: cols))

            let cellWidth = size.width / CGFloat(cols)
            let cellHeight = size.height / CGFloat(rows)

            if result.maxValue > 0 {
                context.drawLayer { layer in
                    layer.addFilter(.blur(radius: 10))

                    for row in 0..<rows {
                        for col in 0..<cols {
                            let value = result.grid[row][col]
                            guard value > 0 else { continue }

                            let intensity = CGFloat(value) / CGFloat(result.maxValue)
                            let color = color(forIntensity: intensity)

                            // célula
                            let rect = CGRect(
                                x: CGFloat(col) * cellWidth,
                                y: CGFloat(row) * cellHeight,
                                width: cellWidth,
                                height: cellHeight
                            )

                            layer.fill(Path(rect),
                                       with: .color(color.opacity(0.4)))
                        }
                    }
                }
            }
        }


    }

    private func color(forIntensity t: CGFloat) -> Color {
        print(t)
        switch t {
        case ..<0.25:  return .blue
        case ..<0.4:   return .green
        case ..<0.6:  return .yellow
        case ..<0.75: return .orange
        default:      return .red
        }
    }
}
