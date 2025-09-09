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
    @ObservedObject var wcSessionDelegate: WatchWCSessionDelegate
    @State private var selection: Tab = .metrics
    
    enum Tab {
        case controls, metrics
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ControlsView(
                manager: manager,
                onNextMatch: {
                    // Navega para MetricsView quando "Próxima partida" é clicada
                    displayMetricsView()
                },
                onResume: {
                    // Navega para MetricsView quando "Retomar" é clicado
                    displayMetricsView()
                }
            )
                .tag(Tab.controls)
            MetricsView(workoutManager: manager, wcSessionDelegate: wcSessionDelegate)
                .tag(Tab.metrics)
        }
        //.navigationTitle("Futevôlei")
        .navigationBarBackButtonHidden(true)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminationReduced ? .never : .automatic))
        .onAppear {
            if manager.running {
                displayMetricsView()
            }
        }
        // O onChange continua importante para o "resume"
        .onChange(of: manager.running) { _, _ in
            displayMetricsView()
        }
        .onChange(of: isLuminationReduced) { oldValue, newValue in
            if newValue {
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
