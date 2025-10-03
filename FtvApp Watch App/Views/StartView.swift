
import HealthKit
import SwiftUI

struct StartView: View {

    @StateObject var manager = WorkoutManager()
    @StateObject var wcSessionDelegate = WatchWCSessionDelegate()
    @State private var isWorkoutActive = false
    @State private var isCountingDown = false
    @State private var savedWorkout: HKWorkout?
    @State private var selectedWorkoutType: HKWorkoutActivityType? = nil
    @State private var isCalibratingOrigin = false
    @ObservedObject var positionManager = managerPosition.shared

    var workoutTypes: [HKWorkoutActivityType] = [.soccer, .volleyball, .tennis]

    var body: some View {
        NavigationStack {
            if isWorkoutActive {
                SessionPagingView(
                    manager: manager,
                    wcSessionDelegate: wcSessionDelegate
                )
                .onAppear {
                    manager.onWorkoutEnded = { workout in
                        self.savedWorkout = workout
                    }
                }
                .sheet(
                    item: $savedWorkout,
                    onDismiss: {
                        isWorkoutActive = false
                    }
                ) { workout in
                    SummaryView(
                        wcSessionDelegate: wcSessionDelegate,
                        positionManager: positionManager,
                        workout: workout
                    )
                    .environmentObject(manager)
                }
            } else if isCalibratingOrigin {
                CalibrateOriginView(
                    positionManager: positionManager,
                    onCalibrated: {
                        self.isCalibratingOrigin = false
                        self.isCountingDown = true
                    },
                    onCancel: {
                        self.isCalibratingOrigin = false
                        self.selectedWorkoutType = nil
                    }
                )

            } else if isCountingDown, let workoutType = selectedWorkoutType {
                CountdownScreen(onCountdownFinished: {
                    self.isCountingDown = false
                    manager.startWorkout(workoutType: workoutType)
                    isWorkoutActive = true
                })

            } else {
                startScreenContent
            }
        }
    }

    var startScreenContent: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(workoutTypes) { workoutType in
                        GeometryReader { proxy in
                            let scrollY = proxy.frame(in: .global).minY
                            
                            SportCardView(
                                sportName: workoutType.name,
                                sportIcon: workoutType.iconName,
                                color: workoutType.color
                            ) {
                                self.selectedWorkoutType = workoutType
                                self.manager.selectedWorkoutType = workoutType
                                self.isCalibratingOrigin = true
                            }
                            .brightness(calculateBrightness(from: scrollY))
                        }
                        .frame(height: 130)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            manager.requestAuthorization()
            wcSessionDelegate.startSession()
        }
        .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Esportes")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(workoutTypes.first?.color ?? .green)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            
    }
    private func calculateBrightness(from scrollY: CGFloat) -> Double {
        let fadeStart: CGFloat = 75
        let fadeEnd: CGFloat = -50
        let fadeRange = fadeStart - fadeEnd
        let progress = (fadeStart - scrollY) / fadeRange
        let clampedProgress = max(0, min(1, progress))
        return Double(clampedProgress * -0.8)
    }
}

extension HKWorkout: @retroactive Identifiable {
    public var id: UUID { self.uuid }
}

extension HKWorkoutActivityType: @retroactive Identifiable {
    public var id: UInt { rawValue }

    var name: String {
        switch self {
        case .soccer: return "Futevôlei"
        case .volleyball: return "Vôlei de Praia"
        case .tennis: return "Beach Tennis"
        default: return "Treino"
        }
    }
    
    var iconName: String {
        switch self {
        case .soccer: return "figure.taichi"
        case .volleyball: return "figure.volleyball"
        case .tennis: return "figure.tennis"
        default: return "figure.walk"
        }
    }

    var color: Color {
        switch self {
        case .soccer, .volleyball, .tennis: return Color.colorPrimal
        default: return .green
        }
    }
}
