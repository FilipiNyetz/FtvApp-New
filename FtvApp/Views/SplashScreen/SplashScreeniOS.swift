//
//  SplashScreen.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 25/08/25.
//

import SwiftUI

struct SplashScreeniOS: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo principal com ajuste visual para a direita
            HStack {
                Spacer()
                Image("logo7S")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: 8) // Move logo ligeiramente para a direita
                Spacer()
            }
            
            // Texto do nome com ajuste visual para a esquerda
            HStack {
                Spacer()
                Text("SETE")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundColor(Color("ColorPrimal"))
                    .tracking(4)
                    .textCase(.uppercase)
                    .offset(x: -4) // Move texto ligeiramente para a esquerda
                Spacer()
            }
                
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
