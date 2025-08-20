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

    // Pré-calcular estatísticas
    var maxDistance: String {
        let maxDist = manager.workouts.map { $0.distance }.max() ?? 0
        return "\(maxDist) cm"
    }

    var maxSpeed: String {
        let maxSpeed =
            manager.workouts.map { $0.distance / 1000 }.max() ?? 0
        return "\(maxSpeed) km/h"
    }

    var totalHeartRate: Int {
        guard manager.workouts.count > 0 else { return 0 }
        let sum = manager.workouts.map { $0.frequencyHeart }.reduce(0, +)
        return Int(sum) / manager.workouts.count
    }

    var totalCalories: Double {
        manager.workouts.map { Double($0.calories) }.reduce(0, +)
    }

    var totalDuration: TimeInterval {
        manager.workouts.map { Double($0.duration * 60) }.reduce(0, +)
    }

    var totalDistance: Double {
        manager.workouts.map { Double($0.distance) / 1000 }.reduce(0, +)
    }

    var totalWorkouts: Int {
        manager.workouts.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DatePickerField(selectedDate: $selectedDate, manager: manager)

                    VStack {
                        Button("Buscar dados") {
                            manager.fetchDataWorkout(
                                endDate: selectedDate,
                                period: "day"
                            )
                        }

                        ForEach(manager.workouts, id: \.id) { workout in
                            //WorkoutView(workout: workout)
                            //Text("\(workout.dateWorkout)")
                            //
                        }
                    }

                    if let workoutsDoDia = manager.workoutsByDay[
                        Calendar.current.startOfDay(for: selectedDate)
                    ] {
                        ForEach(workoutsDoDia, id: \.id) { workout in
                            WorkoutView(workout: workout)
                        }
                    } else {
                        Text("Nenhum treino nesse dia")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    HStack(spacing: 12) {
                        InfoCard(
                            title: "ALTURA MÁX",
                            value: maxDistance,
                            icon: "arrow.up.and.down"
                        )
                        InfoCard(
                            title: "VELOCIDADE MÁX",
                            value: maxSpeed,
                            icon: "wind"
                        )
                    }

                    HStack {
                        WorkoutStatsCard(
                            heartRate: totalHeartRate,
                            calories: totalCalories,
                            elapsedTime: totalDuration,
                            steps: 0,
                            distance: totalDistance
                        )
                    }

                    Divider()

                    Text("Total de jogos")
                        .font(.headline)
                    Text("Jogue suas partidas e conquiste insígnias")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 8) {
                        let meta = max(totalWorkouts, 1)
                        ProgressView(
                            value: Double(totalWorkouts),
                            total: Double(meta)
                        )
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: .blue)
                        )
                        .frame(height: 12)
                        .cornerRadius(6)
                        HStack {
                            Text("\(totalWorkouts)")
                            Spacer()
                            Text("\(meta)")
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

// MARK: - WorkoutView
struct WorkoutView: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Duração: \(workout.duration) min")
            Text("Calorias: \(workout.calories) cal")
            Text("Distância: \(workout.distance) m")
            Text("Freq. Cardíaca: \(workout.frequencyHeart) bpm")
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - WorkoutStatsCard
struct WorkoutStatsCard: View {
    var heartRate: Int
    var calories: Double
    var elapsedTime: TimeInterval
    var steps: Int
    var distance: Double

    private var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    var body: some View {
        VStack(spacing: 16) {
            // Linha de cima
            HStack {
                statItem(
                    title: "BATIMENTO",
                    value: "\(heartRate)",
                    unit: "bpm",
                    icon: "heart.fill"
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(
                    title: "CALORIA",
                    value: String(format: "%.0f", calories),
                    unit: "cal",
                    icon: "flame.fill"
                )
            }

            // Tempo central
            Text(timeFormatter.string(from: elapsedTime) ?? "00:00:00")
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            // Linha de baixo
            HStack {
                statItem(
                    title: "PASSOS",
                    value: "\(steps)",
                    unit: "",
                    icon: "figure.walk"
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(
                    title: "DISTÂNCIA",
                    value: String(format: "%.1f", distance),
                    unit: "km",
                    icon: "location.fill"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func statItem(
        title: String,
        value: String,
        unit: String,
        icon: String
    ) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.gray)

            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(value)
                    .font(
                        .system(size: 22, weight: .semibold, design: .rounded)
                    )
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(
                            .system(size: 12, weight: .medium, design: .rounded)
                        )
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
