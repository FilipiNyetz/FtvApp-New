
import SwiftUI

struct CalibrateOriginView: View {
    @ObservedObject var positionManager: managerPosition
    var onCalibrated: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Calibrar origem")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            Text("Fique parado no centro da linha de fundo da quadra \n para usar como origem do mapa de calor.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                positionManager.setOrigem()
                onCalibrated()
            }) {
                Text("Definir origem")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .frame(width: 160, height: 40)
                    .background(Color.colorPrimal)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.gradiente1, .gradiente2, .gradiente2]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()
        )
    }
}
