//
//  ButtonDiaryGames.swift
//  FtvApp
//
//  Created by Filipi Romão on 21/08/25.
//

import SwiftUI

struct ButtonDiaryGames: View {
    @ObservedObject var manager: HealthManager
    @Binding var selectedDate: Date
    @State private var opcaoDeTreinoParaMostrarCard: Int = 0
    
    var body: some View {
        Group {
            if let workoutsDoDia = manager.workoutsByDay[
                Calendar.current.startOfDay(for: selectedDate)
            ] {
                
                VStack {
                    Menu {
                        ForEach(Array(workoutsDoDia.enumerated()), id: \.element.id) { index, opcaoTreino in
                            Button(action: {
                                opcaoDeTreinoParaMostrarCard = index
                            }) {
                                Text("Treino \(index + 1)")
                            }
                        }
                    } label: {
                        HStack {
                            Text("Jogos do dia")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        
                    }
                    .frame(width: 361, height: 40)
                    .background(Color.darkGrayBackground)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 8)
                    
                    if opcaoDeTreinoParaMostrarCard < workoutsDoDia.count {
                        WorkoutStatsCard(workout: workoutsDoDia[opcaoDeTreinoParaMostrarCard])
                    }
                }
                
            } else {
                Text("Nenhum treino nesse dia")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        // 🔑 Agora sim funciona corretamente
        .onChange(of: selectedDate) { _ in
            opcaoDeTreinoParaMostrarCard = 0
        }
    }
}



