//
//  HomeView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var dataManager: DataManager
    @Environment(\.modelContext) private var context
    
    @State private var isGamesPresented = false
    
    @Query var workoutsSave: [WorkoutModel]
    
    // Mock data
    //    let data = WorkoutMock(
    //        date: "12 de ago. de 2025",
    //        alturaMax: "40 cm",
    //        velocidadeMax: "15 km/h",
    //        batimento: "125 bpm",
    //        calorias: "294 cal",
    //        passos: "129",
    //        tempo: "15:21.12",
    //        distancia: "0,3 km",
    //        progresso: 123,
    //        meta: 250
    //    )
    @State var selectedDate: Date
    @State var countWorkouts: Int = 0
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Data do treino
                    DatePickerField(selectedDate: $selectedDate)
                    VStack{
                        
                        Button(action:{
                            manager.fetchDataWorkout(endDate: selectedDate, period: "day")
                        },label: {
                            Text("Buscar dados")
                        })
                        
                        ForEach(manager.workouts, id: \.id) { workout in
                            WorkoutView(workout: workout)
                        }
                        Text("Dados dos treinos")
                        Text("Quantidade de workout da variavel published dailyWorkouts: \(manager.dailyWorkouts.count)")
                        Text("Tem \(workoutsSave.count) salvo")
                        ForEach(workoutsSave){workout in
                            Text("Workout: \(workout.distance)")
                        }
                    }
                    
                    //jogos
                    //                    VStack(alignment: .leading, spacing: 8) {
                    //                        NavigationLink(destination: GamesView()) {
                    //                            HStack {
                    //                                Text("Jogos")
                    //                                    .font(.title3)
                    //
                    //                                Spacer()
                    //
                    //                                Text("1º")
                    //                                    .font(.title3)
                    //
                    //                                Image(systemName: "chevron.right")
                    //                            }
                    //                            .background(Color(.secondarySystemBackground))
                    //                            .cornerRadius(12)
                    //                        }
                    //                        .buttonStyle(PlainButtonStyle())
                    //                    }
                    //                    .padding()
                    //                    .background(Color(.secondarySystemBackground))
                    //                    .cornerRadius(12)
                    //
                    //                    // Linha 1: altura + velocidade
                    //                    HStack(spacing: 12) {
                    //
                    //                        InfoCard(
                    //                            title: "ALTURA MÁX",
                    //                            value: data.alturaMax,
                    //                            icon: "arrow.up.and.down"
                    //                        )
                    //                        InfoCard(
                    //                            title: "VELOCIDADE MÁX",
                    //                            value: data.velocidadeMax,
                    //                            icon: "wind"
                    //                        )
                    //                    }
                    //
                    //                    // Linha 2: batimento + calorias + tempo(s) + passos + distância
                    //                    WorkoutStatsCard(
                    //                        heartRate: 132,
                    //                        calories: 234,
                    //                        elapsedTime: 55272,
                    //                        steps: 3560,
                    //                        distance: 2.35
                    //                    )
                    //
                    //                    Divider()
                    //
                    //                    Text("Total de jogos")
                    //                        .font(.headline)
                    //                    Text("Jogue suas partidas e conquiste insígnias")
                    //                        .font(.subheadline)
                    //                        .foregroundColor(.gray)
                    //
                    //                    // Progresso
                    //                    VStack(alignment: .leading, spacing: 8) {
                    //
                    //                        ProgressView(
                    //                            value: Double(data.progresso),
                    //                            total: Double(data.meta)
                    //                        )
                    //                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    //                        .frame(height: 12)
                    //                        .cornerRadius(6)
                    //
                    //                        HStack {
                    //                            Text("\(data.progresso)")
                    //                            Spacer()
                    //                            Text("\(data.meta)")
                    //                        }
                    //                        .font(.caption)
                    //                        .foregroundColor(.gray)
                    //                    }
                    //                    .padding()
                    //                    .background(Color(.secondarySystemBackground))
                    //                    .cornerRadius(12)
                    //                }
                    //                .padding(.horizontal)
                    //                .padding(.vertical)
                    //            }
                    //            .navigationTitle("Seus jogos")
                    //            .toolbar {
                    //                ToolbarItem(placement: .navigationBarTrailing) {
                    //                    NavigationLink(destination: EvolutionView()) {
                    //                        Image(systemName: "chart.bar")
                    //                    }
                    //                }
                    //            }
                }
            }
            
        }
        .onAppear(){
            countWorkouts = workoutsSave.count
            manager.fetchDailyValue(context: context, countWorkouts: countWorkouts)
        }
        .onChange(of: manager.dailyWorkouts){
            Task{
                try await dataManager.saveOnDB(context:context, workouts: manager.dailyWorkouts, numberOfWorkoutsSaveds: workoutsSave.count)
            }
        }
        
        //struct InfoCard: View {
        //    let title: String
        //    let value: String
        //    let icon: String
        //
        //    var body: some View {
        //        VStack(spacing: 8) {
        //            Label(value, systemImage: icon)
        //                .font(.headline)
        //                .labelStyle(.titleAndIcon)
        //                .frame(maxWidth: .infinity, alignment: .center)
        //            Text(title)
        //                .font(.caption)
        //                .foregroundColor(.gray)
        //        }
        //        .padding()
        //        .frame(maxWidth: .infinity)
        //        .background(Color(.secondarySystemBackground))
        //        .cornerRadius(12)
        //    }
        //}
        //
        //struct WorkoutMock {
        //    let date: String
        //    let alturaMax: String
        //    let velocidadeMax: String
        //    let batimento: String
        //    let calorias: String
        //    let passos: String
        //    let tempo: String
        //    let distancia: String
        //    let progresso: Int
        //    let meta: Int
        //}
        //
        //
    }
}
