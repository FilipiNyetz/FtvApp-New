
import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack {
            HStack{
                Spacer()
                
                Image("LogoS") 
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Spacer()
            }

        }
    }
}
