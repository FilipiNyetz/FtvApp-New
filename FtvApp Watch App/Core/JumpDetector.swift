
import Foundation

final class JumpDetector: ObservableObject {
    @Published var lastJumpHeight: Double = 0
    @Published var bestJumpHeight: Double = 0
    func start() {}
    func stop() {}
    func reset() { lastJumpHeight = 0; bestJumpHeight = 0 }
}
