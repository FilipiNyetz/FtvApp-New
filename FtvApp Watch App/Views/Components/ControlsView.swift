//
//  ControlsView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

struct ControlsView: View {
    
    @ObservedObject var manager: WorkoutManager
    var onNextMatch: (() -> Void)?
    var onResume: (() -> Void)?
    
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
                VStack {
                    Button {
                        if manager.session?.state == .running {
                            manager.pause()
                        } else if manager.session?.state == .paused {
                            manager.resume()
                            onResume?()
                        }
                    } label: {
                        Image(
                            systemName: manager.running ? "pause" : "play"
                        )
                    }
                    .tint(.yellow)
                    .font(.title2)
                    Text(
                        manager.running ? "Pausar" : "Retomar"
                    )
                }
            }
            
            VStack {
                Button {
                    manager.endWorkout(shouldShowSummary: false) {
                        self.manager.startWorkout(workoutType: .soccer)
                        self.onNextMatch?()
                    }
                } label: {
                    Image(systemName: "forward.fill")
                }
                .tint(.colorPrimal)
                .font(.title2)
                Text("Próxima partida")
            }
        }
    }
}
