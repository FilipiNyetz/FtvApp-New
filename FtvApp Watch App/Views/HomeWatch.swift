//
//  HomeWatch.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 22/08/25.
//

import SwiftUI

struct HomeWatch: View {
    var body: some View {
        NavigationStack {
            Text("Ajuste seu Apple Watch antes de iniciar")
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            NavigationLink(destination: calibrator()){
                Image(systemName: "wrench.adjustable.fill")
            }
            .foregroundColor(Color.colorPrimal)
            .frame(width: 160, height: 56)
            
        }

    }
}

#Preview {
    HomeWatch()
}
