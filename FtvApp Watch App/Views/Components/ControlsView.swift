//
//  ControlsView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

struct ControlsView: View {
    var body: some View {
        VStack(spacing: 15){
            HStack{
                VStack{
                    Button{
                        //terminar partida
                    }label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
                    .font(.title2)
                    Text("Fim")
                }
                VStack{
                    Button{
                        // toggle pause
                    }label: {
                        Image(systemName: "pause") // : "play"
                    }
                    .tint(.yellow)
                    .font(.title2)
                    Text("Pausar") // : "resume"
                }
                
            }
            Button{
                //salar e reiniciar
            }label: {
                Image(systemName: "forward.fill")
            }
            .tint(.green)
            .font(.title2)
            Text("Próxima partida")
        }
    }
}

#Preview {
    ControlsView()
}
