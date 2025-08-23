//
//  TotalGames.swift
//  FtvApp
//
//  Created by Filipi Romão on 21/08/25.
//

import SwiftUI

struct TotalGames: View {
    var manager: HealthManager
    var totalWorkouts: Int
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Total de jogos")
                .font(.headline)
            Text("Jogue suas partidas e conquiste insígnias")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 8) {
                
                ProgressBarView(manager: manager)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}
