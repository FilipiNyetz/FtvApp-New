//
//  TemplateMainView.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 20/08/25.
//

import SwiftUI

// Opções do segmented
enum ShareBg: String, CaseIterable {
    case comFundo = "Com fundo"
    case semFundo = "Sem fundo"
}

struct TemplateMainView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TemplateViewModel()
    @State private var selectedBackground: ShareBg = .comFundo
    @State private var showCopiedAlert = false
    let workout: Workout
    let totalWorkouts: Int
    let currentStreak: Int
    let badgeImage: String
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 0) {
                    
                    // Header com título e botão
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Compartilhar")
                                .font(.title.bold())
                                .foregroundColor(.white)
                            Text("Compartilhe com seus amigos")
                                .font(.headline)
                                .foregroundStyle(.gray)
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
                                Circle().fill(Color.colorPrimal)
                                Image(systemName: selectedBackground == .comFundo ? "square.and.arrow.up" : "doc.on.doc")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.black)
                            }
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                        }
                        .accessibilityLabel(selectedBackground == .comFundo ? "Compartilhar" : "Copiar")
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Picker
                    Picker("", selection: $selectedBackground) {
                        Text(ShareBg.comFundo.rawValue).tag(ShareBg.comFundo)
                        Text(ShareBg.semFundo.rawValue).tag(ShareBg.semFundo)
                    }
                    .pickerStyle(.segmented)
                    .padding(12)
                    
                    // Template Preview
                    ScrollView {
                        TemplateBodyView(
                            workout: workout,
                            withBackground: selectedBackground == .comFundo,
                            badgeImage: badgeImage,
                            totalWorkouts: totalWorkouts,
                            currentStreak: currentStreak,
                            isPreview: true
                            
                        )
                        .padding(.top, selectedBackground == .comFundo ? 12 : 0)
                    }
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Seus jogos")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(Color("ColorPrimal"))
                        }
                    }
                }
                
            }
            
            if showCopiedAlert {
                CopiedAlertView(isPresented: $showCopiedAlert)
            }
            
        }
        .sheet(isPresented: $viewModel.showShare) {
            if let image = viewModel.renderedImage {
                ShareSheet(items: [image])
            }
        }
    }
}
