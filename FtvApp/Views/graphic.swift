////
////  graphic.swift
////  FtvApp
////
////  Created by Joao pedro Leonel on 19/08/25.
////
//
//import SwiftUI
//import Charts
//
//struct graphic: View {
//    var body: some View {
//        // ---------- Gráfico ----------
//        Chart {
//            ForEach(dados) { dado in
//                BarMark(
//                    x: .value("Dia", dado.dia),
//                    y: .value(selectedMetric, dado.valor) // título usa a métrica atual
//                )
//                .foregroundStyle(Color.white)
//            }
//        }
//        .frame(height: 200)
//    }
//}
//
//#Preview {
//    graphic()
//}
