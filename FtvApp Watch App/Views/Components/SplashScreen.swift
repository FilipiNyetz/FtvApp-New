//
//  SplashScreen.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 25/08/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack {
            HStack{
                Spacer()
                
                Image("LogoS") // Substitua por sua imagem de logo
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                Spacer()
            }

        }
    }
}
