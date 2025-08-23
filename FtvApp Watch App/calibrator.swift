//
//  calibrator.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 23/08/25.
//

import SwiftUI

struct calibrator: View {
    var body: some View {
            Text("Vá ao centro da quadra e olhe para a rede")
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        
        Button(action: {}){
                Text("Calibrar")
            }
            .foregroundColor(Color.colorPrimal)
            .frame(width: 160, height: 56)
            
        }
    }


#Preview {
    calibrator()
}
