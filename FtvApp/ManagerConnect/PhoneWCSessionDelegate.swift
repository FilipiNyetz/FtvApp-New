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
        guard let valor = message["pulo"] as? Double,
              let workoutIdString = message["workoutId"] as? String,
              let workoutId = UUID(uuidString: workoutIdString) else { return }
        
        print("📩 Recebido jump \(valor) para workoutId \(workoutId)")
        
        // 🔹 Recebendo o path
        var workoutPath: [CGPoint] = []
        if let rawPath = message["workoutPath"] as? [[String: Double]] {
            workoutPath = rawPath.compactMap { dict in
                if let x = dict["x"], let y = dict["y"] {
                    return CGPoint(x: x, y: y)
                }
                return nil
            }
            print("📍 Recebi \(workoutPath.count) pontos do trajeto para workoutId \(workoutId)")
        }

        DispatchQueue.main.async {
            self.higherJump = valor
            self.pulos.append(valor)

            Task { @MainActor in
                guard self.container != nil else {
                    print("❌ Container não inicializado")
                    return
                }

                // 🔹 Salvar apenas dados extras
                await self.saveJump(value: valor, workoutId: workoutId)
                await self.saveWorkoutPath(path: workoutPath, workoutId: workoutId)
            }
        }
    }

    @MainActor
    func saveJump(value: Double, workoutId: UUID) async {
        guard let container else { return }
        
        let jump = JumpEntity(height: value, date: Date(), workoutId: workoutId)
        container.mainContext.insert(jump)
        
        do {
            try container.mainContext.save()
            print("✅ Jump salvo: \(value) para workoutId \(workoutId)")
        } catch {
            print("❌ Erro ao salvar jump: \(error)")
        }
    }

    @MainActor
    func fetchJumps(for workoutId: UUID) async -> [JumpEntity] {
        print("Funcao fetchJump")
        guard let container else { return [] }
        let descriptor = FetchDescriptor<JumpEntity>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )
        do {
            return try container.mainContext.fetch(descriptor)
        } catch {
            print("❌ Erro ao buscar jumps: \(error)")
            return []
        }
    }

    @MainActor
    func saveWorkoutPath(path: [CGPoint], workoutId: UUID) async {
        guard let container else { return }
        
        // Converte CGPoint -> PathPoint
        let points = path.map { PathPoint(x: Double($0.x), y: Double($0.y)) }
        
        // Verifica se já existe entidade para esse workout
        let descriptor = FetchDescriptor<WorkoutPathEntity>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )
        
        if let existing = try? container.mainContext.fetch(descriptor).first {
            existing.pathData = (try? JSONEncoder().encode(points)) ?? Data()
            existing.createdAt = Date()
            print("♻️ Atualizado WorkoutPathEntity existente com \(points.count) pontos")
        } else {
            let workoutPathEntity = WorkoutPathEntity(workoutId: workoutId, path: points)
            container.mainContext.insert(workoutPathEntity)
            print("🆕 Criado WorkoutPathEntity com \(points.count) pontos")
        }
        
        do {
            try container.mainContext.save()
            print("✅ WorkoutPath salvo para workoutId \(workoutId)")
        } catch {
            print("❌ Erro ao salvar pontos: \(error)")
        }
    }

    @MainActor
    func fetchWorkoutPath(for workoutId: UUID) async -> [CGPoint] {
        print("🔹 Iniciando fetchWorkoutPath para workoutId: \(workoutId)")
        
        guard let container else {
            print("❌ Container não inicializado")
            return []
        }
        
        let descriptor = FetchDescriptor<WorkoutPathEntity>(
            predicate: #Predicate { $0.workoutId == workoutId }
        )
        
        do {
            let results = try container.mainContext.fetch(descriptor)
            print("📦 Encontrados \(results.count) WorkoutPathEntity para workoutId: \(workoutId)")
            
            if let entity = results.first {
                let decoded = entity.decodedPath()
                print("⚡ Decodificado \(decoded.count) pontos do path: \(decoded)")
                return decoded.map { CGPoint(x: $0.x, y: $0.y) }
            } else {
                print("⚠️ Nenhum WorkoutPathEntity encontrado para workoutId: \(workoutId)")
            }
            
        } catch {
            print("❌ Erro ao buscar workoutPath: \(error)")
        }
        
        return []
    }



}
