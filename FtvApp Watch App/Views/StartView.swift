//
//  StartView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import HealthKit
import SwiftUI

enum JumpNavigationPath: Hashable {
    case instruction
    case measure
    case result(bestJump: Int)
}

struct StartView: View {

    @StateObject var manager = WorkoutManager()
    @StateObject var wcSessionDelegate = WatchWCSessionDelegate()
    @State private var isWorkoutActive = false
    @State private var isCountingDown = false
    @State private var savedWorkout: HKWorkout?
    @State private var selectedWorkoutType: HKWorkoutActivityType? = nil
    @StateObject private var jumpDetector = JumpDetector()
    @State private var navigationPath: [JumpNavigationPath] = []
    @State private var latestJumpMeasurement: Int? = nil
    
    @StateObject var positionManager = managerPosition()

    var workoutTypes: [HKWorkoutActivityType] = [.soccer]

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                        positionManager: positionManager,
                        workout: workout
                        
                        
                    )
                    .environmentObject(manager)
                }
            } else if isCountingDown, let workoutType = selectedWorkoutType {
                CountdownScreen(onCountdownFinished: {
                    self.isCountingDown = false
                    // Limpa o path caso o usuário tenha voltado
                    self.navigationPath.removeAll()
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
                    manager.preWorkoutJumpHeight = self.latestJumpMeasurement
                    self.selectedWorkoutType = .soccer
                    self.isCountingDown = true
                    self.latestJumpMeasurement = nil
                }) {
                    Text("Iniciar Treino")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity, maxHeight: 50)  // preenche largura disponível
                        .foregroundStyle(.black)
                        .background(Color.colorPrimal)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(.plain)
                
                Button(action: { navigationPath.append(.instruction) }) {
                    Text("Medir salto")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24).stroke(
                                Color.colorPrimal,
                                lineWidth: 2
                            )
                        )
                }
                .buttonStyle(.plain)

            }
            .padding(.horizontal, 12)
        }
        .onAppear {
            manager.requestAuthorization()
            wcSessionDelegate.startSession()
        }
        // 4. Aqui definimos o que cada valor do nosso enum deve mostrar
        .navigationDestination(for: JumpNavigationPath.self) { path in
            switch path {
            case .instruction:
                JumpInstructionView(navigationPath: $navigationPath)

            case .measure:
                JumpMeasureView(
                    jumpDetector: jumpDetector,
                    navigationPath: $navigationPath
                )

            case .result(let bestJump):
                JumpResultView(
                    bestJump: bestJump,
                    onStart: {
                        self.latestJumpMeasurement = bestJump
                        self.navigationPath.removeAll()
                    },
                    onRedo: {
                        self.navigationPath.removeLast()
                    }
                )
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
