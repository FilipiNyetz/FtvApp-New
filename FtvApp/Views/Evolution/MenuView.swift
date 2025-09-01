//
//  MenuView.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct MenuView: View {
    
    @Binding var selectedMetricId: String   // binding único
    
    struct Metric {
        let id: String        // chave fixa
        let name: String      // texto localizável
        let icon: String
    }
    
    let metrics: [Metric] = [
        Metric(id: "heartRate", name: NSLocalizedString("Batimento", comment: ""), icon: "heart.fill"),
        Metric(id: "calories", name: NSLocalizedString("Caloria", comment: ""), icon: "flame.fill"),
        Metric(id: "distance", name: NSLocalizedString("Distância", comment: ""), icon: "location.fill"),
        Metric(id: "height", name: NSLocalizedString("Altura", comment: ""), icon: "location.fill")
    ]
    
    private var currentMetric: Metric? {
        metrics.first(where: { $0.id == selectedMetricId })
    }
    
    var body: some View {
        Menu {
            ForEach(metrics, id: \.id) { metric in
                Button {
                    selectedMetricId = metric.id
                } label: {
                    HStack {
                        Text(LocalizedStringKey(metric.name))
                        Image(systemName: metric.icon)
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: currentMetric?.icon ?? "arrow.up.and.down")
                    .font(.body)
                    .foregroundColor(.colorSecond)
                
                Text(currentMetric?.name ?? "")
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

