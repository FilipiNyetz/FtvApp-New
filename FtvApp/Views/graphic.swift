
import SwiftUI
import Charts

struct graphic: View {
    struct Dado: Identifiable {
        let id = UUID()
        let dia: Int
        let valor: Double
    }
    let dados: [Dado] = [
        .init(dia: 1,  valor: 28),
        .init(dia: 4,  valor: 28),
        .init(dia: 10, valor: 26),
        .init(dia: 12, valor: 40),
        .init(dia: 19, valor: 12),
        .init(dia: 21, valor: 28),
        .init(dia: 24, valor: 14),
        .init(dia: 26, valor: 16),
        .init(dia: 30, valor: 12)
    ]
    var body: some View {
        Chart {
            ForEach(dados) { dado in
                BarMark(
                    x: .value("Dia", dado.dia),

                    y: .value("valor", dado.valor) 
                )
                .foregroundStyle(Color.white)
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    graphic()
        .preferredColorScheme(.dark)
}
