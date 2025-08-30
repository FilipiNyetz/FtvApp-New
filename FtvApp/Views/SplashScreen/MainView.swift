
import SwiftUI
import SwiftData



struct MainView: View {
    @State private var isLoading = true
    @State private var splashOpacity: Double = 1.0
    @State private var startViewOpacity: Double = 0.0
    
    // Instâncias dos managers
    @StateObject var healthManager = HealthManager()
    @StateObject var userManager = UserManager()
    @StateObject var wcSessionDelegate = PhoneWCSessionDelegate()
    
    // Criar ModelContainer como State
    @State private var container: ModelContainer?

    var body: some View {
        ZStack {
            SplashScreeniOS()
                .opacity(isLoading ? splashOpacity : 0)

            if !isLoading {
                if let container {
                    HomeView(manager: healthManager, userManager: userManager, wcSessionDelegate: wcSessionDelegate)
                        .environment(\.modelContext, container.mainContext)
                        .opacity(startViewOpacity)
                } else {
                    Text("Erro ao inicializar base de dados")
                }
            }
        }
        .task {
            // Inicializa o ModelContainer de forma segura
            do {
                container = try ModelContainer(for: JumpEntity.self)
                wcSessionDelegate.container = container
            } catch {
                print("Erro ao criar ModelContainer: \(error)")
            }

            // Wait for the splash screen duration
            try? await Task.sleep(for: .seconds(0.8))

            // Animate splash screen fade out and start view fade in
            withAnimation(.easeInOut(duration: 0.6)) {
                splashOpacity = 0.0
                startViewOpacity = 1.0
            }

            // Wait for the animation to complete before changing the state
            try? await Task.sleep(for: .seconds(0.6))
            isLoading = false
        }
        .onAppear {
            wcSessionDelegate.startSession()
            healthManager.wcSessionDelegate = wcSessionDelegate
        }
    }
}
