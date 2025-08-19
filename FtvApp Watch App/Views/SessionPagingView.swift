//
//  SessionPagingView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import WatchKit

struct SessionPagingView: View {
    @Environment(\.isLuminanceReduced) var isLuminationReduced
    @ObservedObject var manager: WorkoutManager
    @State private var selection: Tab = .metrics
    
    enum Tab {
        case controls, metrics
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView(manager: manager)
                .tag(Tab.controls)
            MetricsView(workoutManager: manager)
                .tag(Tab.metrics)
        }
        .navigationTitle("Futevôlei")
        .navigationBarBackButtonHidden(true)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminationReduced ? .never : .automatic))
        .onAppear {
                    // Se o treino já estiver rodando quando a view aparecer,
                    // vá para a tela de métricas.
                    if manager.running {
                        displayMetricsView()
                    }
                }
                // O onChange continua importante para o "resume"
                .onChange(of: manager.running) { isRunning in
                    if isRunning {
                        displayMetricsView()
                    }
                }
                .onChange(of: isLuminationReduced) { isReduced in
                    if isReduced {
                        displayMetricsView()
                    }
                }
    }
    
    private func displayMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}
