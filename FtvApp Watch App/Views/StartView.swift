//
//  StartView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import HealthKit
import SwiftUI

struct StartView: View {

    @StateObject var manager = WorkoutManager()
    @StateObject var wcSessionDelegate = WatchWCSessionDelegate()
    @State private var isWorkoutActive = false
    @State private var isCountingDown = false
    @State private var savedWorkout: HKWorkout?
    @State private var selectedWorkoutType: HKWorkoutActivityType? = nil
    @State private var isCalibratingOrigin = false
    @ObservedObject var positionManager = managerPosition.shared

    var workoutTypes: [HKWorkoutActivityType] = [.soccer]

    var body: some View {
        NavigationStack {
            if isWorkoutActive {
                SessionPagingView(
                    manager: manager,
                    wcSessionDelegate: wcSessionDelegate
                )
                .onAppear {
                    manager.onWorkoutEnded = { workout in
                        self.savedWorkout = workout
                    }
                }
                .sheet(
                    item: $savedWorkout,
                    onDismiss: {
                        isWorkoutActive = false
                    }
                ) { workout in
                    SummaryView(
                        wcSessionDelegate: wcSessionDelegate,
                        positionManager: positionManager,
                        workout: workout
                    )
                    .environmentObject(manager)
                }
            } else if isCalibratingOrigin {
                CalibrateOriginView(positionManager: positionManager) {
                    // Callback quando calibrar origem
                    self.isCalibratingOrigin = false
                    self.isCountingDown = true
                }

            } else if isCountingDown, let workoutType = selectedWorkoutType {
                CountdownScreen(onCountdownFinished: {
                    self.isCountingDown = false
                    manager.startWorkout(workoutType: workoutType)
                    isWorkoutActive = true
                })

            } else {
                startScreenContent
            }
        }
    }

    var startScreenContent: some View {
        ZStack {
            Image("LogoS")
                .resizable()
                .scaledToFill()
                .opacity(0.20)
                .ignoresSafeArea()
                .scaleEffect(0.7)

            LinearGradient(
                gradient: Gradient(colors: [
                    .gradiente1, .gradiente2, .gradiente2, .gradiente2,
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .opacity(0.85)
            .ignoresSafeArea()

            VStack(spacing: 8) {
                Text("Seu desempenho será registrado")
                    .font(.headline)  // headline em vez de title3 → mais compacto
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                Button(action: {
                    self.selectedWorkoutType = .soccer
                    self.isCalibratingOrigin = true   // <- novo estado
                }) {
                    Text("Iniciar Treino")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundStyle(.black)
                        .background(Color.colorPrimal)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
        }
        .onAppear {
            manager.requestAuthorization()
            wcSessionDelegate.startSession()
        }
    }
}

extension HKWorkout: @retroactive Identifiable {
    public var id: UUID { self.uuid }
}

extension HKWorkoutActivityType: @retroactive Identifiable {
    public var id: UInt { rawValue }

    var name: String {
        switch self {
        case .soccer: return "Futevôlei"
        default: return "Treino"
        }
    }
}
