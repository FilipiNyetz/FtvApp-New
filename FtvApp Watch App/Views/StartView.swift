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
    @StateObject private var jumpDetector = JumpDetector()
    @State var numeroWatch: Int = 0

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
                    jumpDetector.start()
                }
                .sheet(
                    item: $savedWorkout,
                    onDismiss: {
                        isWorkoutActive = false
                    }
                ) { workout in
                    SummaryView(
                        wcSessionDelegate: wcSessionDelegate,
                        jumpDetector: jumpDetector,
                        workout: workout
                    )
                    .environmentObject(manager)
                }
            } else if isCountingDown, let workoutType = selectedWorkoutType {
                CountdownScreen(onCountdownFinished: {
                    self.isCountingDown = false
                    manager.startWorkout(workoutType: workoutType)
                    isWorkoutActive = true
                })
            } else {
                //criar a logica de onboarding
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

                    VStack(spacing: 12) {

                        //Text("Seu desempenho será registrado em tempo real")
                        Text(
                            "Seu desempenho será registrado"
                        )
                        .font(.title3)
                        .fontWeight(.medium)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                        Button(action: {
                            self.selectedWorkoutType = .soccer
                            self.isCountingDown = true
                        }) {
                            Text("Iniciar Treino")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(width: 180, height: 60)
                                .background(Color.colorPrimal)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)

                        // Botão "Medir salto" - cinza escuro com borda verde
                        Button(action: {
                            // Ação vazia conforme solicitado
                        }) {
                            Text("Medir salto")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(width: 180, height: 60)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.colorPrimal, lineWidth: 2)
                                )
                                .cornerRadius(24)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())

                    }
                    .padding(.horizontal)
                }

                .onAppear {
                    manager.requestAuthorization()
                    wcSessionDelegate.startSession()
                }
            }
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
