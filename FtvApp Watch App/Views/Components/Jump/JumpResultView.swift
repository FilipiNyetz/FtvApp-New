
import HealthKit
import SwiftUI

struct JumpResultView: View {
    
    @ObservedObject var jumpDetector: JumpDetector
    let bestJump: Int
    
    var onStart: () -> Void
    var onRedo: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text("Seu maior pulo foi")
                    .font(.headline)
                    .foregroundStyle(Color.colorPrimal)
                    .padding(.top, 12)
                
                Text("\(bestJump)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("cm")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.top, -8)
            }

            Button(action: {
                onStart()
            }) {
                Text("Jogar")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .frame(width: 160, height: 45)
                    .background(Color.colorPrimal)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(.plain)

            Button(action: {
                onRedo()
            }) {
                Text("Refazer pulo")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 160, height: 45)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.colorPrimal, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
            
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    .gradiente1, .gradiente2, .gradiente2, .gradiente2,
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()
        )
    }
}
