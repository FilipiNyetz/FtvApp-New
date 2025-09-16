import SwiftUI
import WatchKit

struct CountdownScreen: View {
    @State private var countdownNumber: Int = 0 
    @State private var progress: Double = 0.0 
    @State private var textScale: Double = 1.0 
    @State private var textOpacity: Double = 1.0 
    @State private var circleScale: Double = 1.0 
    var onCountdownFinished: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.colorPrimal.opacity(0.3), lineWidth: 10)
                .frame(width: 140, height: 140)
                .scaleEffect(circleScale)
                .animation(.easeInOut(duration: 0.6), value: circleScale)

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(Color.colorPrimal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 140, height: 140)
                .scaleEffect(circleScale)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
                .animation(.easeInOut(duration: 0.6), value: circleScale)
            
            Text(countdownText)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(textScale)
                .opacity(textOpacity)
                .animation(.easeInOut(duration: 0.4), value: textScale)
                .animation(.easeInOut(duration: 0.4), value: textOpacity)
                .id(countdownNumber)
        }
        .task {
            withAnimation(.easeInOut(duration: 0.6)) {
                progress = 1.0
                circleScale = 1.02 
            }
            try? await Task.sleep(for: .seconds(1.0))

            for i in (1...3).reversed() {
                withAnimation(.easeInOut(duration: 0.2)) {
                    textScale = 0.5
                    textOpacity = 0.0
                }
                try? await Task.sleep(for: .seconds(0.2))
                
                countdownNumber = i
                withAnimation(.easeInOut(duration: 0.3)) {
                    textScale = 1.2 
                    textOpacity = 1.0
                    circleScale = 1.08
                }
                try? await Task.sleep(for: .seconds(0.15))
                
                withAnimation(.easeInOut(duration: 0.15)) {
                    circleScale = 1.0
                }
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    textScale = 1.0
                }
                try? await Task.sleep(for: .seconds(0.1))
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    progress = Double(i - 1) / 3.0 
                }
                try? await Task.sleep(for: .seconds(0.3))
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                textScale = 0.1 
                textOpacity = 0.0
                circleScale = 0.9 
            }
            countdownNumber = -1
            try? await Task.sleep(for: .seconds(0.5))
            
            WKInterfaceDevice.current().play(.start)
            
            onCountdownFinished()
        }
    }
    
    var countdownText: String {
        if countdownNumber == 0 {
            return "Preparar"
        } else if countdownNumber > 0{ 
            return String(countdownNumber)
        }else{
            return ""
        }
    }
    
    private var fontSize: CGFloat {
        return countdownNumber > 0 ? 80 : 30
    }
}
