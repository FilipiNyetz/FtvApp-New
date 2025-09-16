
import SwiftUI

struct SplashScreeniOS: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            HStack {
                Spacer()
                Image("logo7S")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: 8) 
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("SETE")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundColor(Color("ColorPrimal"))
                    .tracking(4)
                    .textCase(.uppercase)
                    .offset(x: -4) 
                Spacer()
            }
                
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
