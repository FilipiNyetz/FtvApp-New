//
//  CountdownCircle.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 23/08/25.
//

import SwiftUI

struct CountdownCircle: View {
    let onComplete: () -> Void
    let totalSeconds: Int = 3
    
    @State private var number: Int = 3
    @State private var progress: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 15)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.colorPrimal, Color.colorSecond]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            Text("\(number)")
                .font(.system(size: 90, weight: .bold))
                .foregroundColor(.colorPrimal)
        }
        .frame(width: 150, height: 150)
        .onAppear {
            startCountdown()
        }
    }
    
    private func startCountdown() {
        number = totalSeconds
        progress = 1.0
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if number > 0 {
                number -= 1
                withAnimation(.linear(duration: 1)) {
                    progress = CGFloat(number) / CGFloat(totalSeconds)
                }
            } else {
                timer.invalidate()
                onComplete()
            }
        }
    }
}
