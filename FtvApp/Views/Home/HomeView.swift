//
//  HomeView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    
    @State private var isGamesPresented = false
    @State var selectedDate: Date = Date()
    @State var opcaoDeTreinoParaMostrarCard: Int = 0
    
    // Pré-calcular estatísticas
    //    var maxDistance: String {
    //        let maxDist = manager.workouts.map { $0.distance }.max() ?? 0
    //        return "\(maxDist) cm"
    //    }
    //
    //    var maxSpeed: String {
    //        let maxSpeed =
    //            manager.workouts.map { $0.distance / 1000 }.max() ?? 0
    //        return "\(maxSpeed) km/h"
    //    }
    //
 
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DatePickerField(selectedDate: $selectedDate, manager: manager)
                    
                    VStack {
//                        Button("Buscar dados") {
//                            manager.fetchDataWorkout(
//                                endDate: selectedDate,
//                                period: "day"
//                            )
//                        }
                        
//                        ForEach(manager.workouts, id: \.id) { workout in
//                            //WorkoutView(workout: workout)
//                            //Text("\(workout.dateWorkout)")
//                            //
//                        }
                    }
                    
                    if let workoutsDoDia = manager.workoutsByDay[
                        Calendar.current.startOfDay(for: selectedDate)
                    ] {
                        ForEach(Array(workoutsDoDia.enumerated()), id: \.element.id) { index, opcaoTreino in
                            Button(action: {
                                opcaoDeTreinoParaMostrarCard = index
                            }) {
                                Text("Treino \(index + 1)")
                            }
                        }
                        
                        if opcaoDeTreinoParaMostrarCard < workoutsDoDia.count {
                            WorkoutStatsCard(workout: workoutsDoDia[opcaoDeTreinoParaMostrarCard])
                        }
                        
                    } else {
                        Text("Nenhum treino nesse dia")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    
                    //                    HStack(spacing: 12) {
                    //                        InfoCard(
                    //                            title: "ALTURA MÁX",
                    //                            value: maxDistance,
                    //                            icon: "arrow.up.and.down"
                    //                        )
                    //                        InfoCard(
                    //                            title: "VELOCIDADE MÁX",
                    //                            value: maxSpeed,
                    //                            icon: "wind"
                    //                        )
                    //                    }
                    
                    
                    
                    Divider()
                    
                    TotalGames(totalWorkouts: manager.workouts.count)
                }
                .navigationTitle("Seus jogos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: EvolutionView()) {
                            Circle()
                                .fill(Color.brandGreen)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "chart.bar")
                                        .font(.subheadline)
                                        .foregroundStyle(.black)
                                )
                        }
                    }
                }
                .onAppear {
                    manager.fetchMonthWorkouts(for: selectedDate)
                }
            }
        }
    }
    
}





