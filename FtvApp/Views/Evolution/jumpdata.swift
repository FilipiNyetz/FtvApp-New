//
//  jumpdata.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct jumpdata: View {
    var body: some View {
        // ---------- Cards Máx / Mín ----------
        HStack(spacing: 12) {
            // Card Máx
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("MÁX")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    // Aqui colocar a Data que ele conquistou esse dado
                    Text("12/07/25")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    // Aqui puxa o maior dado que o usuario teve
                    Text("40")
                        .fontWeight(.semibold)
                        .font(.title)
                    Text("cm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(height: 76)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)

            // Card Mín
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("MÍN")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    // Aqui colocar a Data que ele conquistou esse dado
                    Text("08/02/25")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    // Aqui puxa o menor dados que o usuario teve
                    Text("12")
                        .fontWeight(.semibold)
                        .font(.title)
                    Text("cm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(height: 76)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }
}

#Preview {
    jumpdata()
        .preferredColorScheme(.dark)
}
