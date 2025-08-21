//
//  HeadTemplateView.swift
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

/// Topo da tela: Toolbar (TEMPLATE + subtítulo + botão) + Segmented com divider
struct HeadTemplateView: View {
    @State private var selection: ShareBg = .comFundo
    var onShare: () -> Void = {}

    private let neon = Color.brandGreen

    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control + Divider
            Picker("", selection: $selection) {
                Text(ShareBg.comFundo.rawValue).tag(ShareBg.comFundo)
                Text(ShareBg.semFundo.rawValue).tag(ShareBg.semFundo)
            }
            .pickerStyle(.segmented)
            .padding(12) // mesmo espaço em cima, baixo e laterais

            Divider()
                .background(Color.white.opacity(0.15))
        }
        Spacer()
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            // Título grande + subtítulo
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

            // Botão de compartilhar
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onShare) {
                    ZStack {
                        Circle().fill(neon)
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
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HeadTemplateView()
            .background(Color.black.ignoresSafeArea())
    }
}
