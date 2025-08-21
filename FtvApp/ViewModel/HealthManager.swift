//  HealthManager.swift
//  BeActiv
//
//  Created by Filipi Romão on 10/08/25.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject, @unchecked Sendable {
    
    //Instancia a classe que controla do DB do healthKit, criando o objeto capaz de acessar e gerenciar os dados no healthKit
    let healthStore = HKHealthStore()
    
    //Variavel que aramazena um array de workouts e pode ser acessada pela view
    @Published var workouts: [Workout] = []
    @Published var workoutsByDay: [Date: [Workout]] = [:]
    @Published var mediaBatimentosCardiacos: Double = 0.0
    @Published var totalWorkoutsCount: Int = 0
    
    init() {
        //Inicia a classe manager declarando quais serão as variaveis e os tipos de dados solicitados ao HealthKit
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let typeWorkouts = HKObjectType.workoutType()
        let hearthRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        
        //Seta um array com todos os valores que precisam ser solicitados para permissao do usuario
        let healthTypes: Set = [
            steps, calories, typeWorkouts, hearthRate, distance,
        ]
        
        Task {
            do {
                //Realiza um pedido para o usuario permitir compartilhar os dados
                try await healthStore.requestAuthorization(
                    toShare: healthTypes,
                    read: healthTypes
                )
                
            } catch {
                print("Error fetching data")
            }
        }
    }
    func updateWorkoutsByDay() {
        let calendar = Calendar.current
        DispatchQueue.main.async {
            self.workoutsByDay = Dictionary(grouping: self.workouts) { workout in
                calendar.startOfDay(for: workout.dateWorkout)
            }
            self.totalWorkoutsCount = self.workouts.count
        }
    }
    
    func fetchMonthWorkouts(for month: Date) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let range = calendar.range(of: .day, in: .month, for: month)!
        let endOfMonth = calendar.date(byAdding: .day, value: range.count, to: startOfMonth)!
        
        self.fetchDataWorkout(endDate: endOfMonth, period: "month")
        // Depois que ele popular ⁠ workouts ⁠, organiza:
        DispatchQueue.main.async {
            self.workoutsByDay = Dictionary(grouping: self.workouts) { workout in
                calendar.startOfDay(for: workout.dateWorkout)
            }
        }
    }
    
    
    func fetchDataWorkout(endDate: Date, period: String) {
        let calendar = Calendar.current
        let startDate: Date
        let adjustedEndDate: Date
        
        switch period {
        case "day":
            // Começo do dia
            startDate = calendar.startOfDay(for: endDate)
            // Fim do dia (adiciona 1 dia e subtrai 1 segundo)
            adjustedEndDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: startDate
            )!
                .addingTimeInterval(-1)
            
        case "week":
            adjustedEndDate = endDate
            startDate = calendar.date(
                byAdding: .weekOfYear,
                value: -1,
                to: adjustedEndDate
            )!
            
        case "month":
            adjustedEndDate = endDate
            startDate = calendar.date(
                byAdding: .month,
                value: -1,
                to: adjustedEndDate
            )!
            
        case "year":
            adjustedEndDate = endDate
            startDate = calendar.date(
                byAdding: .year,
                value: -1,
                to: adjustedEndDate
            )!
            
        default:
            return
        }
        
//        print("Start: \(startDate)")
//        print("End: \(adjustedEndDate)")
        
        DispatchQueue.main.async {
            self.workouts.removeAll()
        }
        
        let workoutType = HKObjectType.workoutType()
        
        // Predicados para semana e tipo de treino(filtros)
        let timePredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: adjustedEndDate
        )
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            timePredicate, workoutPredicate,
        ])
        
        // Query principal de workouts, baseando se nos filtros
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: 50,
            sortDescriptors: nil
        ) { _, samples, error in
            
            //Verifica se recebeu de fato um array de HKWorkout e desempacota para garantir que existe e é do tipo certo. Verifica tambem se nao existe erros
            print(samples?.count ?? 0)
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Erro ao buscar workouts da semana")
                return
            }
            
            //percorre todos os workouts e pega um por um
            for workout in workouts {
                let durationSeconds = workout.duration
//                print("A data do treino é: \(workout.endDate)")
                
                // Calorias
                let calories =
                workout.totalEnergyBurned?.doubleValue(for: .kilocalorie())
                ?? 0
                
                // Distância
                let distance =
                workout.totalDistance?.doubleValue(for: .meter()) ?? 0
                
                //Declara a variavel para armazenar a media dos BPM duante todo o workout, inicia com 0
                //Chama a funcao para receber o retorno dela
                
                queryFrequenciaCardiaca(
                    workout: workout,
                    healthStore: self.healthStore
                ) { mediumFrequencyHeartRate in
                    //Declara o sumário do treino, que é uma Struct do tipo Workout, então possui um id, um idWorkoutType, uma duracao, calorias, distancia e frequencyHeart. Dessa forma passa todos os dados necessários para conformar com o Workout
                    let workoutSummary = Workout(
                        id: UUID(),
                        idWorkoutType: Int(
                            workout.workoutActivityType.rawValue
                        ),
                        duration: durationSeconds,
                        calories: Int(calories),
                        distance: Int(distance),
                        frequencyHeart: mediumFrequencyHeartRate,
                        dateWorkout: workout.endDate
                    )
                    
                    DispatchQueue.main.async {
                        self.workouts.append(workoutSummary)
                        self.updateWorkoutsByDay()
                    }
                }
                
            }
        }
        healthStore.execute(query)
    }
}
