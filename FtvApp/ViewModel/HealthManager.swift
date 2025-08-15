//
//  HealthManager.swift
//  BeActiv
//
//  Created by Filipi Romão on 10/08/25.
//

import Foundation
import HealthKit

extension Date {
    
    static var startOfYear: Int{
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        return currentYear
    }
    
    static var endOfYear: Date{
        let currentDate = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year], from: currentDate)
        components.year! += 1
        return calendar.date(from: components)!
    }
    
    static var startOfMonth: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        let currentDate = Date()
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        return calendar.date(from: components)!
    }
    
    static var endOfMonth: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        var components = DateComponents()
        components.month = 1
        let currentDate = Date()
        let date = calendar.date(byAdding: components, to: currentDate)!
        return calendar.date(byAdding: .second, value: -1, to: date)!
    }
    
    static var startOfWeek: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Domingo
        let currentDate = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        return calendar.date(from: components)!
    }
    
    static var endOfWeek: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Domingo
        let start = Date.startOfWeek
        return calendar.date(byAdding: .day, value: 7, to: start)!
    }
    
    static var startOfToday: Date {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.startOfDay(for: Date())
        return start
    }
    
    static var endOfToday: Date {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: 1, to: start)!
    }
    
    
    
    
    
    
}

class HealthManager: ObservableObject {
    
    //Instancia a classe que controla do DB do healthKit, criando o objeto capaz de acessar e gerenciar os dados no healthKit
    let healthStore = HKHealthStore()
    
    //Variavel que aramazena um array de workouts e pode ser acessada pela view
    @Published var workouts: [Workout] = []
    @Published var mediaBatimentosCardiacos: Double = 0.0
    
    init(){
        //Inicia a classe manager declarando quais serão as variaveis e os tipos de dados solicitados ao HealthKit
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let typeWorkouts = HKObjectType.workoutType()
        let hearthRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        
        //Seta um array com todos os valores que precisam ser solicitados para permissao do usuario
        let healthTypes:Set = [steps, calories, typeWorkouts, hearthRate, distance]
        
        
        Task{
            do{
                //Realiza um pedido para o usuario permitir compartilhar os dados
                try await healthStore.requestAuthorization(toShare: healthTypes, read: healthTypes)
                
            } catch {
                print("Error fetching data")
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
            adjustedEndDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
                .addingTimeInterval(-1)
            
        case "week":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: adjustedEndDate)!
            
        case "month":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .month, value: -1, to: adjustedEndDate)!
            
        case "year":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .year, value: -1, to: adjustedEndDate)!
            
        default:
            return
        }
        
        print("Start: \(startDate)")
        print("End: \(adjustedEndDate)")
        
        
        DispatchQueue.main.async {
            self.workouts.removeAll()
        }
        
        let workoutType = HKObjectType.workoutType()
        
        // Predicados para semana e tipo de treino(filtros)
        let timePredicate = HKQuery.predicateForSamples(withStart: startDate, end: adjustedEndDate)
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        
        // Query principal de workouts, baseando se nos filtros
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 50, sortDescriptors: nil) { _, samples, error in
            
            //Verifica se recebeu de fato um array de HKWorkout e desempacota para garantir que existe e é do tipo certo. Verifica tambem se nao existe erros
            print(samples?.count ?? 0)
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Erro ao buscar workouts da semana")
                return
            }
            
            //percorre todos os workouts e pega um por um
            for workout in workouts {
                let durationMinutes = Int(workout.duration) / 60
                
                // Calorias
                let calories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                
                // Distância
                let distance = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
                
                //                //Declara a variavel para armazenar a media dos BPM duante todo o workout, inicia com 0
                //Chama a funcao para receber o retorno dela
                //                let mediaHeartRate: Double = queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore, completionHandler: mediaFrequencia)
                
                
                
                queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore){mediumFrequencyHeartRate in
                    print("A frequência média é: \(mediumFrequencyHeartRate)")
                    //Declara o sumário do treino, que é uma Struct do tipo Workout, então possui um id, um idWorkoutType, uma duracao, calorias, distancia e frequencyHeart. Dessa forma passa todos os dados necessários para conformar com o Workout
                    let workoutSummary = Workout(
                        id: UUID(),
                        idWorkoutType: Int(workout.workoutActivityType.rawValue),
                        duration: durationMinutes,
                        calories: Int(calories),
                        distance: Int(distance),
                        frequencyHeart: mediumFrequencyHeartRate
                    )
                    DispatchQueue.main.async {
                        self.workouts.append(workoutSummary)
                    }
                }
                
                
            }
        }
        healthStore.execute(query)
    }
    
}




