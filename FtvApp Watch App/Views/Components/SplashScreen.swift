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
                
                Image("LogoS") 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Spacer()
            }

        }
    }
}
