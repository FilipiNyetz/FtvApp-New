//
//  TemplateMainView.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 20/08/25.
//

import SwiftUI

struct TemplateMainView: View {
    @ObservedObject private var manager = HealthManager()
    @State private var selectedBackground: ShareBg = .comFundo
    @State private var showShare = false
    @State private var renderedImage: UIImage?
    let workout: Workout
    
    
    var body: some View {
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
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                // Título
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TEMPLATE")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text("Compartilhe com seus amigos")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                    }
                    .padding(.top, 2)
                }
                
                // Botão compartilhar
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        exportCurrentTemplate()
                    } label: {
                        ZStack {
                            Circle().fill(Color.brandGreen)
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.black)
                        }
                        .frame(width: 52, height: 52)
                        .contentShape(Circle())
                    }
                    .accessibilityLabel("Compartilhar")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let image = renderedImage {
                ShareSheet(items: [image])
            }
        }
    }
    
    private func exportCurrentTemplate() {
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
