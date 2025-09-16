import SwiftUI

struct HeatmapView: View {
    let points: [CGPoint]
    var originPoint: CGPoint? = nil
    var flipX: Bool = false
    var flipY: Bool = false

    private let idealCellSize: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            print("--- Iniciando renderização do Heatmap ---")
            print("Tamanho do Canvas: \(size.width) x \(size.height)")
            print("Recebeu \(points.count) pontos.")

            guard !points.isEmpty else {
                print("‼️ FIM: Array de pontos está vazio. Nada a desenhar.")
                return
            }

            guard size.width > 0, size.height > 0 else {
                print("‼️ FIM: Tamanho do Canvas é zero. Nada a desenhar.")
                return
            }

            let minX = points.map(\.x).min() ?? 0
            let maxX = points.map(\.x).max() ?? 1
            let minY = points.map(\.y).min() ?? 0
            let maxY = points.map(\.y).max() ?? 1
            let bounds = CGRect(
                x: minX,
                y: minY,
                width: maxX - minX,
                height: maxY - minY
            )

            print("Bounds dos pontos calculados: \(bounds)")
            if bounds.width == 0 || bounds.height == 0 {
                print(
                    "⚠️ ATENÇÃO: Bounds com largura ou altura zero. Todos os pontos podem ser idênticos."
                )
            }

            let cols = max(Int(size.width / idealCellSize), 1)
            let rows = max(Int(size.height / idealCellSize), 1)

            let result = HeatmapProcessor.process(
                points: points,
                worldBounds: bounds,
                gridSize: (rows: rows, cols: cols)
            )

            print("Processador retornou valor máximo de: \(result.maxValue)")

            let cellWidth = size.width / CGFloat(cols)
            let cellHeight = size.height / CGFloat(rows)

            if result.maxValue > 0 {
                context.drawLayer { layer in
                    layer.addFilter(.blur(radius: 9))

                    print("✅ Desenhando \(rows) linhas e \(cols) colunas...")
                    var cellsDrawn = 0

                    for row in 0..<rows {
                        for col in 0..<cols {
                            let value = result.grid[row][col]
                            guard value > 0 else { continue }

                            cellsDrawn += 1
                            let tLinear = CGFloat(value) / CGFloat(result.maxValue)
                            let intensity = pow(tLinear, 0.85)
                            let color = color(forIntensity: intensity)

                            let centerX = (CGFloat(col) + 0.5) * cellWidth
                            let centerY = (CGFloat(row) + 0.5) * cellHeight

                            let diameter = max(cellWidth, cellHeight) * 1.8
                            let circleRect = CGRect(
                                x: centerX - diameter / 2,
                                y: centerY - diameter / 2,
                                width: diameter,
                                height: diameter
                            )

                            layer.fill(
                                Path(ellipseIn: circleRect),
                                with: .color(color.opacity(1.0))
                            )
                        }
                    }
                    print("✅ Células desenhadas: \(cellsDrawn)")

                    if let origin = originPoint {
                        print("✅ Desenhando ponto de origem: \(origin)")

                        let mappedOrigin = mapWorldPointToCanvas(
                            point: origin,
                            worldBounds: bounds,  
                            canvasSize: size
                        )

                        let originRect = CGRect(
                            x: mappedOrigin.x - 5,
                            y: mappedOrigin.y - 5,
                            width: 10,
                            height: 10
                        )  

                        layer.fill(
                            Path(ellipseIn: originRect),  
                            with: .color(Color.pink.opacity(1.0))
                        )  
                        layer.stroke(
                            Path(ellipseIn: originRect),  
                            with: .color(Color.black.opacity(0.8)),
                            lineWidth: 1
                        )
                    }
                }

            } else {
                print("‼️ FIM: Valor máximo do grid é 0. Nada a desenhar.")
            }
        }
    }

    private func color(forIntensity t: CGFloat) -> Color {
        switch t {
        case ..<0.25:
            return Color(red: 0.00, green: 0.60, blue: 1.00, opacity: 1.0)
        case ..<0.40:
            return Color(red: 0.00, green: 1.00, blue: 0.35, opacity: 1.0)
        case ..<0.60:
            return Color(red: 1.00, green: 1.00, blue: 0.00, opacity: 1.0)
        case ..<0.75:
            return Color(red: 1.00, green: 0.60, blue: 0.00, opacity: 1.0)
        default:
            return Color(red: 1.00, green: 0.20, blue: 0.20, opacity: 1.0)
        }
    }
    
    private func mapWorldPointToCanvas(point: CGPoint, worldBounds: CGRect, canvasSize: CGSize) -> CGPoint {
        guard worldBounds.width > 0 && worldBounds.height > 0 else { return .zero }

        let normalizedX = (point.x - worldBounds.minX) / worldBounds.width
        let normalizedY = (point.y - worldBounds.minY) / worldBounds.height

        let canvasX = normalizedX * canvasSize.width
        var canvasY = normalizedY * canvasSize.height

        canvasY = canvasSize.height - canvasY

        return CGPoint(x: canvasX, y: canvasY)
    }
}
