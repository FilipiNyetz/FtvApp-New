
import SwiftUI

struct CardWithoutWorkout: View {
    var body: some View {

        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.gradiente1, .progressBarBGDark, .progressBarBGDark]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .shadow(
                    color: Color.black, 
                    radius: 6, 
                    x: 0,
                    y: 2
                )

            Image("logo7S")
                .resizable()
                .scaledToFit()
                .opacity(0.1)
                .frame(width: 250, height: 250)
                .offset(x: 130, y: 10)

            VStack(alignment: .center, spacing: 10) {

                Text("Você ainda não tem treinos registrados")
                    .font(.headline)
                    .foregroundColor(.colorPrimal)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)

                Text(
                    "Use o SETE na partida e visualize seus resultados logo depois do jogo!"
                )
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

                HStack {
                    Image(systemName: "applewatch")
                    Image(systemName: "arrow.up.and.down")
                    Image(systemName: "heart.fill")
                    Image(systemName: "flame.fill")
                    Image(systemName: "location.fill")
                }
                .frame(width: 30, height: 30)
                .foregroundStyle(.colorPrimal)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 15)) 
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.backgroundProgressBar, lineWidth: 0.3)
        )
        .clipped()

    }
}

#Preview {
    CardWithoutDayWorkout()
}
