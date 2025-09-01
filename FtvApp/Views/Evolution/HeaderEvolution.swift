//
//  HeaderEvolution.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 28/08/25.
//

import SwiftUI

struct HeaderEvolution: View {
    @State private var selectedSelection = "M"
    @Binding var selectedMetricId: String
    var body: some View {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Evolução")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    MenuView(selectedMetricId: $selectedMetricId)
                        .padding(.horizontal)
                }
                .foregroundColor(.white)
                .background(Color.black)
    }
}
