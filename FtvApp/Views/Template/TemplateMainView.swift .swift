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

                    HeaderTemplate(
                        selectedBackground: $selectedBackground,
                        showCopiedAlert: $showCopiedAlert,
                        viewModel: viewModel,
                        workout: workout,
                        totalWorkouts: totalWorkouts,
                        currentStreak: currentStreak,
                        badgeImage: badgeImage
                    )
        
                    ScrollView {
                        ZStack {
                            if selectedBackground == .semFundo {
                                Image("SemFundo")
                                    .resizable()
                                    .scaledToFill()
                                    .ignoresSafeArea()
                            }

                            VStack {
                                Picker("", selection: $selectedBackground) {
                                    Text(ShareBg.comFundo.rawValue)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .tag(ShareBg.comFundo)
                                    Text(ShareBg.semFundo.rawValue)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .tag(ShareBg.semFundo)
                                }
                                .pickerStyle(.segmented)
                                .padding(12)
                              

                                Spacer()

                                TemplateBodyView(
                                    workout: workout,
                                    withBackground: selectedBackground
                                        == .comFundo,
                                    badgeImage: badgeImage,
                                    totalWorkouts: totalWorkouts,
                                    currentStreak: currentStreak,
                                    isPreview: true
                                )
                                .padding(
                                    .top,
                                    selectedBackground == .comFundo ? 12 : 0
                                )
                            }
                            .padding(.top, 8)
                        }
                    }.scrollDisabled(true)
                }
                .background(
                    Group {
                        if selectedBackground == .comFundo {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gradiente2, Color.gradiente2,
                                    Color.gradiente2, Color.gradiente2,
                                    Color.gradiente2, Color.gradiente2,
                                    Color.gradiente2, Color.gradiente1,
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomLeading
                            )
                            .frame(maxHeight: .infinity)
                            .ignoresSafeArea(.all)
                        }
                    }
                    .ignoresSafeArea()
                )
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
                .toolbarBackground(Color.black, for: .navigationBar)
                .background(Color.gray.opacity(0.1).ignoresSafeArea())
                .foregroundColor(.white)

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
