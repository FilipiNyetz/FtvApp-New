import SwiftUI

struct CardWithoutWorkout: View {
    var body: some View {
        VStack (alignment: .center){
            Spacer()
            
            Text("Você ainda não tem jogos")
                .font(.headline)
                .foregroundColor(.white)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.top, 66)
                .padding(.bottom, 20)// margem lateral para quebrar bem
            
            Text("Use o SETE na sua partida e veja suas métricas após")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.colorPrimal)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)
                .padding(.bottom, 66)
            
            Spacer()
        }
        .frame(width: 361, height: 216)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.progressBarBGLight, .progressBarBGDark]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(16)
        )
    }
}

#Preview {
    CardWithoutWorkout()
}
