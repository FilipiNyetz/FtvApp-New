
import SwiftUI
import SwiftData

struct MainView: View {
    @State private var isLoading = true
    @State private var splashOpacity: Double = 1.0
    @State private var startViewOpacity: Double = 0.0
    
    @StateObject var healthManager = HealthManager()
    @EnvironmentObject var userManager: UserManager
    @StateObject var wcSessionDelegate = PhoneWCSessionDelegate()
    
    @State private var container: ModelContainer?

    var body: some View {
        ZStack {
            SplashScreeniOS()
                .opacity(isLoading ? splashOpacity : 0)

            if !isLoading {
                if let container {
                    HomeView(manager: healthManager, wcSessionDelegate: wcSessionDelegate)
                        .environment(\.modelContext, container.mainContext)
                        .opacity(startViewOpacity)
                } else {
                    Text("Erro ao inicializar base de dados")
                }
            }
        }
        .task {
            do {
                container = try ModelContainer(for: JumpEntity.self, WorkoutPathEntity.self, WorkoutExtras.self)
                wcSessionDelegate.container = container
            } catch {
                print("Erro ao criar ModelContainer: \(error)")
            }

            try? await Task.sleep(for: .seconds(0.8))

            withAnimation(.easeInOut(duration: 0.6)) {
                splashOpacity = 0.0
                startViewOpacity = 1.0
            }

            try? await Task.sleep(for: .seconds(0.6))
            isLoading = false
        }
        .onAppear {
            wcSessionDelegate.startSession()
            healthManager.wcSessionDelegate = wcSessionDelegate
        }
    }
}
