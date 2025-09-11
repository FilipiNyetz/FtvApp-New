import Foundation
import SwiftData
import WatchConnectivity

/// The WCSession delegate on the watch side
class PhoneWCSessionDelegate: NSObject, WCSessionDelegate,ObservableObject {
    
    var container: ModelContainer!
//    @Published var higherJumps: [Double?] = [0.0]
    @Published var number: Int = 0
    @Published var higherJump: Double = 0.0
    @Published var pulos: [Double] = []
    var healthManager: HealthManager?
    
    // Repository para gerenciar dados extras dos workouts
    private lazy var extrasRepository: WorkoutExtrasRepository = {
        WorkoutExtrasRepository(container: container)
    }()
    
    /// Acesso público ao repositório para o HealthManager
    func getExtrasRepository() -> WorkoutExtrasRepository {
        return extrasRepository
    }
    
    /// Assigns this delegate to WCSession and starts the session
    func startSession() {
        guard WCSession.isSupported() else { return }
        print("*** Starting WCSession for phone ***")
        let session = WCSession.default
        session.delegate = self
        print("*** Activating phone WCSession ***")
        session.activate()
    }
    
    /// A delegate function called everytime WCSession is activated
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
    
    /// A delegate function called everytime WCSession recieves an application context update
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("*** WCSession recieved application context on phone ***")
        
    }
    
    /// A delegate function called everytime WCSession becomes inactive
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("*** WCSession became inactive on phone ***")
    }
    
    /// A delegate function called everytime WCSession deactivates
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
            
            // 🔹 Processar higherJump se presente
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
            
            // 🔹 Processar workoutPath se presente
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
        }
    }

    // MARK: - Métodos mantidos para compatibilidade com dados legados
    
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
