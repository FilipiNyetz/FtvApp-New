
import SwiftUI

struct SugestaoCard: View {
    let icone: String
    let titulo: Text
    let descricao: Text
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icone)
                    .foregroundColor(.colorSecond)
                
                titulo
                    .foregroundColor(.white)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            
            descricao
                .font(.subheadline)
                .foregroundColor(.white)
                .foregroundColor(.secondary)
                .fontWeight(.regular)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.progressBarBGDark, Color.progressBarBGDark, Color.progressBarBGDark,Color.progressBarBGLight]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.backgroundProgressBar,lineWidth: 0.3)
                )
        )
        .cornerRadius(10)
    }
}
