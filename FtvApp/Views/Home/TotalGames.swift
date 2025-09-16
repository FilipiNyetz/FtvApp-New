
import SwiftUI

struct TotalGames: View {
    var manager: HealthManager
    @EnvironmentObject var userManager: UserManager
    var totalWorkouts: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            VStack(alignment: .leading, spacing: 4){
                Text("Total de jogos")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("Jogue suas partidas e conquiste insígnias")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                ProgressBarView(manager: manager)
            }
            
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.vertical)
    }
}
