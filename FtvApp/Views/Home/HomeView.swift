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
    @Environment(\.modelContext) private var context
    
    @State private var isGamesPresented = false
    
    @Query var workoutsSave: [WorkoutModel]
    
    // Mock data
    let data = WorkoutMock(
        date: "12 de ago. de 2025",
        alturaMax: "0 cm",
        velocidadeMax: "0 km/h",
        batimento: "125 bpm",
        calorias: "294 cal",
        passos: "129",
        tempo: "15:21.12",
        distancia: "0,3 km",
        progresso: 123,
        meta: 250
    )
    @State var selectedDate: Date
    @State var countWorkouts: Int = 0
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    
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
                        
                        Text("Tem \(workoutsSave.count) salvo")
                    }
                    
                    //jogos
                    // Linha 1: altura + velocidade
                    HStack(spacing: 12) {
                        
                        InfoCard(
                            title: "ALTURA MÁX",
                            value: data.alturaMax,
                            icon: "arrow.up.and.down"
                        )
                        InfoCard(
                            title: "VELOCIDADE MÁX",
                            value: data.velocidadeMax,
                            icon: "wind"
                        )
                    }
                    Spacer()
                        .padding(.top, 5)
                    
                    HStack(){
                        // Linha 2: batimento + calorias + tempo(s) + passos + distância
                        WorkoutStatsCard(
                            heartRate: countWorkouts,
                            calories: 0,
                            elapsedTime: 0,
                            steps: 0,
                            distance:0
                        )
                    }
                    Spacer()
                        .padding(.top, 5)
                    
                    Divider()
                    
                    Text("Total de jogos")
                        .font(.headline)
                    Text("Jogue suas partidas e conquiste insígnias")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Progresso
                    VStack(alignment: .leading, spacing: 8) {
                        
                        ProgressView(
                            value: Double(data.progresso),
                            total: Double(data.meta)
                        )
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 12)
                        .cornerRadius(6)
                        
                        HStack {
                            Text("\(data.progresso)")
                            Spacer()
                            Text("\(data.meta)")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .navigationTitle("Seus jogos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EvolutionView()) {
                        Image(systemName: "chart.bar")
                    }
                }
            }
        }
        .onAppear(){
            countWorkouts = workoutsSave.count
            Task{
                try await manager.fetchDailyValue(context: context, countWorkouts: countWorkouts)
            }
        }
    }
        
}
        

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
            Label(value, systemImage: icon)
                .font(.headline)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .center)
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WorkoutMock {
    let date: String
    let alturaMax: String
    let velocidadeMax: String
    let batimento: String
    let calorias: String
    let passos: String
    let tempo: String
    let distancia: String
    let progresso: Int
    let meta: Int
}


