//
//  HeadTemplateView.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 20/08/25.
//
//
//import SwiftUI
//
//
//
///// Topo da tela: Toolbar (TEMPLATE + subtítulo + botão) + Segmented com divider
//struct HeadTemplateView: View {
//    @State private var selection: ShareBg = .comFundo
//    var onShare: () -> Void = {}
//
//    private let neon = Color.brandGreen
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Segmented Control + Divider
//            Picker("", selection: $selection) {
//                ForEach(ShareBg.allCases, id: \.self) { option in
//                    Text(option.rawValue).tag(option)
//                }
//            }
//            .pickerStyle(.segmented)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//
//            Divider()
//                .background(Color.white.opacity(0.15))
//        }
//    }
//}
