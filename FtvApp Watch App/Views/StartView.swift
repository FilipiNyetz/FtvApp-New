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
    @State private var isWorkoutActive = false
    @State private var isCountingDown = false
    @State private var savedWorkout: HKWorkout?
    @State private var selectedWorkoutType: HKWorkoutActivityType? = nil
    
    @State var numeroWatch: Int = 0

    var workoutTypes: [HKWorkoutActivityType] = [.soccer]

    var body: some View {
        NavigationStack {
            if isWorkoutActive {
                SessionPagingView(manager: manager)
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
                        SummaryView(workout: workout)
                            .environmentObject(manager)
                    }
            } else if isCountingDown, let workoutType = selectedWorkoutType {
                CountdownScreen(onCountdownFinished: {
                    self.isCountingDown = false
                    manager.startWorkout(workoutType: workoutType)
                    isWorkoutActive = true
                })
            } else {
                ZStack{
                    Image("LogoS")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.50)
                        .ignoresSafeArea()
                        .scaleEffect(0.7)
                    
                    LinearGradient(
                     gradient: Gradient(colors: [.gradiente1, .gradiente2, .gradiente2,  .gradiente2]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    .opacity(0.85)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 12) {
                        Text("Bem vindo ao SETE, vamos registrar sua performance e evoluir seu jogo")
                            .font(.title3)
                            .fontWeight(.medium)
                            .fontDesign(.rounded)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .padding(.bottom, 12)


                        Button(action: {
                            self.selectedWorkoutType = .soccer
                            self.isCountingDown = true
                        }) {
                            Text("Iniciar")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.colorPrimal)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }


                .onAppear {
                    manager.requestAuthorization()
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
