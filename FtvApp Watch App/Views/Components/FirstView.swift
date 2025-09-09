//
//  FirstView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 05/09/25.
//

import HealthKit
import SwiftUI

struct FirstView: View {
    @Binding var hasCompletedOnboarding: Bool
    var body: some View {
        NavigationStack {
            //criar a logica de onboarding
            ZStack {
                Image("LogoS")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.50)
                    .ignoresSafeArea()
                    .scaleEffect(0.7)

                LinearGradient(
                    gradient: Gradient(colors: [
                        .gradiente1, .gradiente2, .gradiente2, .gradiente2,
                    ]),
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .opacity(0.85)
                .ignoresSafeArea()

                VStack(spacing: 12) {

                    //Text("Seu desempenho será registrado em tempo real")
                    Text(
                        "Bem vindo ao SETE, vamos registrar sua performance e evoluir seu jogo"
                    )
                    .font(.title3)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.bottom, 12)
                    .foregroundStyle(Color.colorPrimal)

                    Button(action: {
                        self.hasCompletedOnboarding = true
                    }) {
                        Text("Ok")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.colorPrimal)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
            }

        }
    }
}
