import SwiftUI

struct HeatmapView: View {
    let points: [CGPoint]
    var originPoint: CGPoint? = nil
    var flipX: Bool = false
    var flipY: Bool = false

    private let idealCellSize: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            // --- INÍCIO DA DEPURAÇÃO ---
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
            // --- FIM DA DEPURAÇÃO ---

            // 🔹 Calcula os bounds a partir dos pontos
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

            // --- INÍCIO DA DEPURAÇÃO ---
            print("Bounds dos pontos calculados: \(bounds)")
            if bounds.width == 0 || bounds.height == 0 {
                print(
                    "⚠️ ATENÇÃO: Bounds com largura ou altura zero. Todos os pontos podem ser idênticos."
                )
            }
            // --- FIM DA DEPURAÇÃO ---

            // 🔹 Define grid
            let cols = max(Int(size.width / idealCellSize), 1)
            let rows = max(Int(size.height / idealCellSize), 1)

            // 🔹 Processa o heatmap
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

                            // Center of the cell
                            let centerX = (CGFloat(col) + 0.5) * cellWidth
                            let centerY = (CGFloat(row) + 0.5) * cellHeight

                            // Circle diameter slightly larger than a cell to improve blending
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

                        // Mapeia o ponto de origem para as coordenadas do Canvas
                        let mappedOrigin = mapWorldPointToCanvas(
                            point: origin,
                            worldBounds: bounds,  // Use os bounds calculados para o mapeamento
                            canvasSize: size
                        )

                        let originRect = CGRect(
                            x: mappedOrigin.x - 5,
                            y: mappedOrigin.y - 5,
                            width: 10,
                            height: 10
                        )  // Um pequeno quadrado ou círculo

                        layer.fill(
                            Path(ellipseIn: originRect),  // Desenha um círculo para a origem
                            with: .color(Color.pink.opacity(1.0))
                        )  // Cor branca e sólida para destacar
                        layer.stroke(
                            Path(ellipseIn: originRect),  // Borda preta para melhor visibilidade
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
        // Paleta com thresholds estáveis + tons mais vivos (opacidade total)
        switch t {
        case ..<0.25:
            // Azul vivo (base fria)
            return Color(red: 0.00, green: 0.60, blue: 1.00, opacity: 1.0)
        case ..<0.40:
            // Verde vivo
            return Color(red: 0.00, green: 1.00, blue: 0.35, opacity: 1.0)
        case ..<0.60:
            // Amarelo intenso
            return Color(red: 1.00, green: 1.00, blue: 0.00, opacity: 1.0)
        case ..<0.75:
            // Laranja forte
            return Color(red: 1.00, green: 0.60, blue: 0.00, opacity: 1.0)
        default:
            // Vermelho intenso
            return Color(red: 1.00, green: 0.20, blue: 0.20, opacity: 1.0)
        }
    }
    
    private func mapWorldPointToCanvas(point: CGPoint, worldBounds: CGRect, canvasSize: CGSize) -> CGPoint {
        guard worldBounds.width > 0 && worldBounds.height > 0 else { return .zero }

        // Normaliza o ponto para 0...1 dentro dos bounds do mundo
        let normalizedX = (point.x - worldBounds.minX) / worldBounds.width
        let normalizedY = (point.y - worldBounds.minY) / worldBounds.height

        // Mapeia para o tamanho do canvas
        let canvasX = normalizedX * canvasSize.width
        var canvasY = normalizedY * canvasSize.height

        // Inverte o Y se o seu sistema de coordenadas do mundo for de baixo para cima
        // e o Canvas for de cima para baixo (o padrão)
        canvasY = canvasSize.height - canvasY

        return CGPoint(x: canvasX, y: canvasY)
    }
}
