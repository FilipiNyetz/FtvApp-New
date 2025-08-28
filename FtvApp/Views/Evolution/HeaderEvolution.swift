//
//  HeaderEvolution.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 28/08/25.
//

import SwiftUI

struct HeaderEvolution: View {
    @State private var selectedSelection = "M"
    @State private var selectedMetric: String = "Batimento"
    
    var body: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Evolução")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    MenuView(selectedMetric: $selectedMetric)
                        .padding(.horizontal)
                }
                .frame(maxHeight: .infinity)
                //.padding(.top, 12)
                .padding(.bottom, 30)
                .background(Color.black)
    }
}

#Preview {
    HeaderEvolution()
}
