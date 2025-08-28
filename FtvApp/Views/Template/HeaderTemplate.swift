//
//  HeaderTemplate.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 28/08/25.
//

import SwiftUI

struct HeaderTemplate: View {
    @Binding var selectedBackground: ShareBg
    @Binding var showCopiedAlert: Bool
    @ObservedObject var viewModel: TemplateViewModel
    let workout: Workout
    let totalWorkouts: Int
    let currentStreak: Int
    let badgeImage: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                if (selectedBackground == .comFundo){
                    Text("Compartilhar")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("Compartilhe com seus amigos")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }else{
                    Text("Compartilhar")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("Copie e cole nas suas fotos")
                        .font(.headline)
                        .foregroundStyle(.gray)
                }

            }
            
            Spacer()
            
            Button {
                if selectedBackground == .comFundo {
                    viewModel.exportTemplate(workout: workout, withBackground: true, badgeImage: badgeImage, totalWorkouts: totalWorkouts, currentStreak: currentStreak)
                } else {
                    viewModel.copyTemplateToClipboard(workout: workout, badgeImage: badgeImage, totalWorkouts: totalWorkouts, currentStreak: currentStreak)
                    withAnimation {
                        showCopiedAlert = true
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.colorPrimal)
                        .frame(width: 54, height: 54)
                        .overlay(
                            Image(systemName: selectedBackground == .comFundo ? "square.and.arrow.up" : "doc.on.doc")
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.black)
                                .padding()
                            
                        )
                        .padding()
                    
                }
                
                .contentShape(Circle())
            }
            .accessibilityLabel(selectedBackground == .comFundo ? "Compartilhar" : "Copiar")
            
        }
        .padding(.top, -12)
        .padding(.horizontal)
        .background(Color.black)
    }
}
