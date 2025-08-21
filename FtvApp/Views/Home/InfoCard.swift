//
//  InfoCard.swift
//  FtvApp
//
//  Created by Filipi Romão on 21/08/25.
//

import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
            Label(value, systemImage: icon)
                .font(.headline)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
