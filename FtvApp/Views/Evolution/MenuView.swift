//
//  MenuView.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct MenuView: View {

    @Binding var selectedMetric: String

    let metrics: [(name: String, icon: String)] = [
        (NSLocalizedString("Batimento", comment: ""), "heart.fill"),
        (NSLocalizedString("Caloria", comment: ""),   "flame.fill"),
        (NSLocalizedString("Distância", comment: ""), "location.fill"),
        (NSLocalizedString("Altura", comment: ""), "location.fill")
    ]

    private var currentMetricIcon: String {
        metrics.first(where: { $0.name == selectedMetric })?.icon ?? "arrow.up.and.down"
    }

    var body: some View {
        Menu {
            ForEach(metrics, id: \.name) { metric in
                Button(action:{
                    selectedMetric = metric.name
                },label:{
                    HStack{
                        Text(LocalizedStringKey(metric.name))
                        Image(systemName: metric.icon)
                    }
                })
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: currentMetricIcon)
                    .font(.body)
                    .foregroundColor(.colorSecond)
                Text(selectedMetric == "Velocidade máx" ? "Vel. máx" : selectedMetric)
                    .font(.body)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .opacity(0.85)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: 160, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
        }
        .menuStyle(.button)
        .menuIndicator(.hidden)
    }
}
