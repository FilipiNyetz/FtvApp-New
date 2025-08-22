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
    @ObservedObject private var manager = HealthManager()
    @State private var selectedBackground: ShareBg = .comFundo
    @State private var showShare = false
    @State private var renderedImage: UIImage?
    let workout: Workout
    
    
    var body: some View {
        
        @State var selection: ShareBg = .comFundo


        let neon = Color.brandGreen

        NavigationStack {
            VStack(spacing: 0) {
                // Header com segmented control
                VStack(spacing: 0) {
                    Picker("", selection: $selectedBackground) {
                        Text(ShareBg.comFundo.rawValue).tag(ShareBg.comFundo)
                        Text(ShareBg.semFundo.rawValue).tag(ShareBg.semFundo)
                    }
                    .pickerStyle(.segmented)
                    .padding(12)
                    
                    Divider()
                        .background(Color.white.opacity(0.15))
                }
                
                // Template preview
                ScrollView {
                    if selectedBackground == .comFundo {
                        SessionPosterView(workout: workout)
                    } else {
                        SemFundoView(workout: workout)
                    }
                }
                .padding(.top, 16)
            }
            .background(Color.black.ignoresSafeArea())
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                // 2. Item para o título e subtítulo customizados no CENTRO
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("TEMPLATE")
                            .font(.headline.bold())
                            .foregroundStyle(.white)

                        Text("Compartilhe com seus amigos")
                            .font(.caption) // .caption é mais adequado para subtítulos
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    func exportCurrentTemplate() {
        let templateView = selectedBackground == .comFundo
            ? AnyView(SessionPosterView(workout: workout))
            : AnyView(SemFundoView(workout: workout))
        
        let renderer = ImageRenderer(content: templateView)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = selectedBackground == .comFundo
        
        if let uiImage = renderer.uiImage {
            self.renderedImage = uiImage
            self.showShare = true
        }
    }
}
