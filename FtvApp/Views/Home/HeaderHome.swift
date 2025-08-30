//
//  HeaderHome.swift
//  FtvApp
//
//  Created by Filipi Romão on 23/08/25.
//

import SwiftUI

struct HeaderHome: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var wcSessionDelegate: PhoneWCSessionDelegate

    var nivelFogo: Int {
        let s = manager.currentStreak

        switch s {
        case 0...1: return 1
        case 2...3: return 2
        case 4...7: return 3
        case 8...15: return 4
        default: return 5
        }
    }

    var imageFogoNum: String {
        "Fogo\(nivelFogo)"
    }

    var body: some View {
        HStack {

            VStack(alignment: .leading, spacing: 4) {

                Text("Seus jogos")
                    .font(.title.bold())
                    .foregroundColor(.white)

                // Foguinho evolutivo por streak
                HStack(spacing: 8) {
                    Image(imageFogoNum)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.25), value: nivelFogo)

                    Text(
                        "\(manager.currentStreak) semana\(manager.currentStreak == 1 ? "" : "s")"
                    )
                    .foregroundColor(.secondary)
                    .font(.headline.weight(.semibold))
                    .accessibilityLabel(
                        "Streak de \(manager.currentStreak) semanas"
                    )
                }
            }.padding(.horizontal)

            Spacer()

            NavigationLink(destination: EvolutionView(wcSessionDelegate: wcSessionDelegate)) {
                Circle()
                    .fill(Color.colorPrimal)
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "chart.bar")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                    )
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color.black)
    }
}
