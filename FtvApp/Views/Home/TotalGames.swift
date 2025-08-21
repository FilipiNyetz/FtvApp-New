//
//  TotalGames.swift
//  FtvApp
//
//  Created by Filipi Romão on 21/08/25.
//

import SwiftUI

struct TotalGames: View {
    
    var totalWorkouts: Int
    
    var body: some View {
        VStack{
            Text("Total de jogos")
                .font(.headline)
            Text("Jogue suas partidas e conquiste insígnias")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                let meta = max(totalWorkouts, 1)
                ProgressView(
                    value: Double(totalWorkouts),
                    total: Double(meta)
                )
                .progressViewStyle(
                    LinearProgressViewStyle(tint: .blue)
                )
                .frame(height: 12)
                .cornerRadius(6)
                HStack {
                    Text("\(totalWorkouts)")
                    Spacer()
                    Text("\(meta)")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}



