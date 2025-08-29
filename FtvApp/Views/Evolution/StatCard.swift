//
//  StatCard.swift
//  FtvApp
//
//  Created by Filipi Romão on 27/08/25.
//

import SwiftUI

struct StatCard: View {
    let title: Text
    let value: String
    let unit: String
    let dateText: String
//    let stroke = stroke(Color.blue.opacity(0.3), lineWidth: 1)
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                title
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .fontWeight(.semibold)
                    .font(.title)
                Text(unit)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(height: 76)
        .background(
            
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.progressBarBGDark, Color.progressBarBGLight]),
                        startPoint: .bottom,
                        endPoint: .top
                    ).opacity(0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.backgroundProgressBar, lineWidth: 0.3)
                )
            
        )
        .cornerRadius(10)
    }
}

