//
//  ControlsView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

struct ControlsView: View {
    
    @ObservedObject var manager: WorkoutManager
    
    var body: some View {
        VStack(spacing: 15){
            HStack{
                VStack{
                    Button{
                        manager.endWorkout()
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
                manager.startWorkout(workoutType: .soccer)
            }label: {
                Image(systemName: "forward.fill")
            }
            .tint(.green)
            .font(.title2)
            Text("Próxima partida")
        }
    }
}


