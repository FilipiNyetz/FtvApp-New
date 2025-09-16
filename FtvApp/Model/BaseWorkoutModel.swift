
import Foundation
import SwiftData

struct PathPoint: Codable {
    let x: Double
    let y: Double
}

var stepCount: Int?

@Model
final class WorkoutExtras: @unchecked Sendable {
    @Attribute(.unique) var workoutID: String   
    var higherJump: Double?                     
    var pointPath: [[Double]]?                  
    var updatedAt: Date
    
    var stepCount: Int?
    
    init(workoutID: String, higherJump: Double? = nil, pointPath: [[Double]]? = nil) {
        self.workoutID = workoutID
        self.higherJump = higherJump
        self.pointPath = pointPath
        self.updatedAt = Date()
        self.stepCount = stepCount
    }
}

@Model
final class JumpEntity {
    @Attribute(.unique) var id: UUID
    var workoutId: UUID        
    var height: Double
    var date: Date
    
    init(height: Double, date: Date, workoutId: UUID) {
        self.id = UUID()
        self.height = height
        self.date = date
        self.workoutId = workoutId
    }
}

@Model
final class WorkoutPathEntity {
    @Attribute(.unique) var id: UUID
    var workoutId: UUID
    var pathData: Data          
    var createdAt: Date
    
    init(workoutId: UUID, path: [PathPoint]) {
        self.id = UUID()
        self.workoutId = workoutId
        self.createdAt = Date()
        
        let encoder = JSONEncoder()
        self.pathData = (try? encoder.encode(path)) ?? Data()
    }
    
    func decodedPath() -> [PathPoint] {
        let decoder = JSONDecoder()
        return (try? decoder.decode([PathPoint].self, from: pathData)) ?? []
    }
}

struct Workout {
    let id: UUID                 
    let idWorkoutType: Int
    let duration: Double
    let calories: Int
    let distance: Int
    let frequencyHeart: Double
    let dateWorkout: Date
    let higherJump: Double?
    let pointsPath: [[Double]]   
    let stepCount: Int
}
