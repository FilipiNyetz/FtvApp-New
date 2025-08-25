//
//  HeaderHome.swift
//  FtvApp
//
//  Created by Filipi Romão on 23/08/25.
//

import SwiftUI

struct HeaderHome: View {
    @ObservedObject var manager: HealthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Seus jogos")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: EvolutionView()) {
                    Circle()
                        .fill(Color.brandGreen)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "chart.bar")
                                .font(.subheadline)
                                .foregroundStyle(.black)
                        )
                }
                .padding(.top, 16)
            }
            .padding(.horizontal)
           // .padding(.top, 50)
            
            // “Foguinho” logo abaixo do título
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.brandGreen)
                Text("\(manager.currentStreak)")  // valor dinâmico se quiser
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color.black)
    }
}

