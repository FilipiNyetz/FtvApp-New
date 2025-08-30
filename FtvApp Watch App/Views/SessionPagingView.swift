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
            ControlsView(
                manager: manager, 
                onNextMatch: {
                    displayMetricsView()
                },
                onResume: {
                    displayMetricsView()
                }
            )
                .tag(Tab.controls)
            MetricsView(workoutManager: manager)
                .tag(Tab.metrics)
        }
        .navigationBarBackButtonHidden(true)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminationReduced ? .never : .automatic))
        .onAppear {
            if manager.running {
                displayMetricsView()
            }
        }
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
