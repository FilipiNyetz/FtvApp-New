import Foundation
import SwiftData
import WatchConnectivity

class PhoneWCSessionDelegate: NSObject, WCSessionDelegate,ObservableObject {
    
    var container: ModelContainer!
    @Published var number: Int = 0
    @Published var higherJump: Double = 0.0
    @Published var pulos: [Double] = []
    var healthManager: HealthManager?
    
    private lazy var extrasRepository: WorkoutExtrasRepository = {
        WorkoutExtrasRepository(container: container)
    }()
    
    func getExtrasRepository() -> WorkoutExtrasRepository {
        return extrasRepository
    }
    
    func startSession() {
        guard WCSession.isSupported() else { return }
        print("*** Starting WCSession for phone ***")
        let session = WCSession.default
        session.delegate = self
        print("*** Activating phone WCSession ***")
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("*** Phone WCSession activation error: \(error) ***")
        } else {
            switch activationState {
            case .activated:
                print("*** WCSession activated for phone ***")
                print(session.isPaired)
            case .notActivated:
                print("*** WCSession failed to activate for phone ***")
            case .inactive:
                print("*** WCSession inactive for phone ***")
            @unknown default:
                print("*** WCSession activation result: Unknown, for phone ***")
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("*** WCSession recieved application context on phone ***")
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("*** WCSession became inactive on phone ***")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("*** WCSession deactivated on phone ***")
    }
    
    func reciveMessageByWatch(_ message: String) {
        print("*** Message recieved by watch: \(message) ***")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let workoutIdString = message["workoutId"] as? String else {
            print("❌ workoutId não encontrado na mensagem")
            return
        }
        
        print("📩 Recebendo dados para workoutId \(workoutIdString)")
        
        Task { @MainActor in
            guard self.container != nil else {
                print("❌ Container não inicializado")
                return
            }
            
            if let valor = message["pulo"] as? Double {
                print("📩 Recebido jump \(valor) para workoutId \(workoutIdString)")
                self.higherJump = valor
                self.pulos.append(valor)
                
                do {
                    try await self.extrasRepository.upsertHigherJump(valor, for: workoutIdString)
                } catch {
                    print("❌ Erro ao salvar higherJump: \(error)")
                }
            }
            
            if let rawPath = message["workoutPath"] as? [[String: Double]] {
                let pathPoints: [[Double]] = rawPath.compactMap { dict in
                    if let x = dict["x"], let y = dict["y"] {
                        return [x, y]
                    }
                    return nil
                }
                print("📍 Recebi \(pathPoints.count) pontos do trajeto para workoutId \(workoutIdString)")
                
                do {
                    try await self.extrasRepository.upsertPointPath(pathPoints, for: workoutIdString)
                } catch {
                    print("❌ Erro ao salvar pointPath: \(error)")
                }
            }
            
            if let stepCount = message["customStepCount"] as? Int {
                        print("👣 Recebido stepCount \(stepCount) para workoutId \(workoutIdString)")
                        
                        do {
                            try await self.extrasRepository.upsertStepCount(stepCount, for: workoutIdString)
                        } catch {
                            print("❌ Erro ao salvar stepCount: \(error)")
                        }
                    }
            
            print("🔄 Solicitando atualização dos workouts no HealthManager...")
                self.healthManager?.fetchAllWorkouts()
        }
    }

    
    @MainActor
    func fetchJumps(for workoutId: UUID) async -> [JumpEntity] {
        print("⚠️ fetchJumps legado chamado para workoutId: \(workoutId)")
        guard let container else { return [] }
        let descriptor = FetchDescriptor<JumpEntity>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )
        do {
            return try container.mainContext.fetch(descriptor)
        } catch {
            print("❌ Erro ao buscar jumps legados: \(error)")
            return []
        }
    }

    @MainActor
    func fetchWorkoutPath(for workoutId: UUID) async -> [CGPoint] {
        print("⚠️ fetchWorkoutPath legado chamado para workoutId: \(workoutId)")
        
        guard let container else {
            print("❌ Container não inicializado")
            return []
        }
        
        let descriptor = FetchDescriptor<WorkoutPathEntity>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )
        
        do {
            let results = try container.mainContext.fetch(descriptor)
            
            if let entity = results.first {
                let decoded = entity.decodedPath()
                return decoded.map { CGPoint(x: $0.x, y: $0.y) }
            }
            
        } catch {
            print("❌ Erro ao buscar workoutPath legado: \(error)")
        }
        
        return []
    }

}
