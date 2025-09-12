import SwiftUI

struct HeatmapView: View {
    let points: [CGPoint]
    var rotationDegrees: CGFloat = 0
    var originPoint: CGPoint? = nil
    var flipX: Bool = false
    var flipY: Bool = false

    private let idealCellSize: CGFloat = 20

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
                    layer.addFilter(.blur(radius: 10))

                    print("✅ Desenhando \(rows) linhas e \(cols) colunas...")
                    var cellsDrawn = 0

                    for row in 0..<rows {
                        for col in 0..<cols {
                            let value = result.grid[row][col]
                            guard value > 0 else { continue }

                            cellsDrawn += 1
                            let intensity =
                                CGFloat(value) / CGFloat(result.maxValue)
                            let color = color(forIntensity: intensity)

                            let rect = CGRect(
                                x: CGFloat(col) * cellWidth,
                                y: CGFloat(row) * cellHeight,
                                width: cellWidth * 1.5,
                                height: cellHeight * 1.5
                            )

                            layer.fill(
                                Path(rect),
                                with: .color(color.opacity(0.7))
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
                            width: 50,
                            height: 50
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
        // Esta função já tem um print(t), o que é ótimo para depuração.
        print("Calculando cor para intensidade: \(t)")
        switch t {
        case ..<0.25: return .blue
        case ..<0.4: return .green
        case ..<0.6: return .yellow
        case ..<0.75: return .orange
        default: return .red
        }
    }
    
    private func mapWorldPointToCanvas(point: CGPoint, worldBounds: CGRect, canvasSize: CGSize) -> CGPoint {
        guard worldBounds.width > 0 && worldBounds.height > 0 else { return .zero }

        // Normaliza o ponto para 0...1 dentro dos bounds do mundo
        let normalizedX = (point.x - worldBounds.minX) / worldBounds.width
        let normalizedY = (point.y - worldBounds.minY) / worldBounds.height

        // Mapeia para o tamanho do canvas
        var canvasX = normalizedX * canvasSize.width
        var canvasY = normalizedY * canvasSize.height

        // Inverte o Y se o seu sistema de coordenadas do mundo for de baixo para cima
        // e o Canvas for de cima para baixo (o padrão)
        canvasY = canvasSize.height - canvasY

        return CGPoint(x: canvasX, y: canvasY)
    }
}
