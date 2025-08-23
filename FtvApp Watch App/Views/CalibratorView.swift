//
//  calibrator.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 23/08/25.
//

import SwiftUI

struct CalibratorView: View {
    @State private var countdown: Int = 3
    @State private var isCountingDown = false
    @State private var showStartButton = false
    @State private var progress: CGFloat = 1.0
    
    var onCalibrationComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if !isCountingDown && !showStartButton {
                Text("Vá ao centro da quadra e olhe para a rede")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Calibrar") {
                    showStartButton = true
                }
                .foregroundColor(.white)
                .frame(width: 160, height: 56)
                .background(Color.blue)
                .cornerRadius(12)
                
            } else if showStartButton {
                Text("O Watch está calibrado e pronto para começar")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Iniciar") {
                    startCountdown()
                }
                .foregroundColor(.black)
                .frame(width: 160, height: 56)
                .background(Color.green)
                .cornerRadius(12)
                
            } else if isCountingDown {
                CountdownCircle(onComplete: {
                    onCalibrationComplete()
                })
                .transition(.scale)
            }
        }
        .onChange(of: countdown) { newValue in
            if newValue == 0 {
                onCalibrationComplete()
            } else {
                progress = CGFloat(newValue) / 3.0 // Normaliza para 0...1
            }
        }
        .animation(.easeInOut, value: countdown)
    }
    
    private func startCountdown() {
        isCountingDown = true
        countdown = 3
        progress = 1.0
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
