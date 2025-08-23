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
    @StateObject private var viewModel = TemplateViewModel()
    @State private var selectedBackground: ShareBg = .comFundo
    @State private var showCopiedAlert = false
    let workout: Workout
    
    var body: some View {
        NavigationStack {
            ZStack{
                VStack(spacing: 0) {
                    
                    HStack{
                        VStack(alignment: .leading, spacing: 2) {
                            Text("TEMPLATE")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("Compartilhe com seus amigos")
                                .font(.headline)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Button {
                            if selectedBackground == .comFundo {
                                viewModel.exportTemplate(workout: workout, withBackground: true)
                            } else {
                                viewModel.copyTemplateToClipboard(workout: workout)
                                showCopiedAlert = true
                            }
                        } label: {
                            ZStack {
                                Circle().fill(Color.brandGreen)
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
                    
                    // Picker
                    Picker("", selection: $selectedBackground) {
                        Text(ShareBg.comFundo.rawValue).tag(ShareBg.comFundo)
                        Text(ShareBg.semFundo.rawValue).tag(ShareBg.semFundo)
                    }
                    .pickerStyle(.segmented)
                    .padding(12)
                    
                    Divider()
                        .background(Color.white.opacity(0.15))
                    
                    // Template Preview
                    ScrollView {
                        TemplateBodyView(
                            workout: workout,
                            withBackground: selectedBackground == .comFundo
                        )
                    }
                }
                .background(Color.black.ignoresSafeArea())
                
                if showCopiedAlert {
                    CopiedAlertView(isPresented: $showCopiedAlert)
                }
            }
            
        }
        .sheet(isPresented: $viewModel.showShare) {
            if let image = viewModel.renderedImage {
                ShareSheet(items: [image])
            }
        }
    }
}
