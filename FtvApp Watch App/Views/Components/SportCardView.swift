import SwiftUI

struct SportCardView: View {
    let sportName: String
    let sportIcon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: sportIcon)
                        .font(.system(size: 32))
                        .foregroundColor(color)

                    Spacer()

                    Image(systemName: "play.fill")
                        .font(.title3)
                        .foregroundColor(color)
                        .padding(.trailing, 8)
                }
                Spacer()

                Text(sportName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()

            }
            .padding()
            .frame(height: 130)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .progressBarBGDark, .progressBarBGDark, .progressBarBGLight,
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous)) 
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack {
            Text("Exercício")
                .font(.title3).bold()
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            SportCardView(
                sportName: "Caminhada ao Ar Livre",
                sportIcon: "figure.walk",
                color: .green,
                action: { }
            )
            .padding(.horizontal)

            SportCardView(
                sportName: "Futevôlei",
                sportIcon: "sportscourt.fill",
                color: .orange,
                action: { }
            )
            .padding(.horizontal)
        }
    }
    .background(Color.black)
}
