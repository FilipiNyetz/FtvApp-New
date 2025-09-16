
import Foundation
import SwiftUI
struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let isFuture: Bool
    let hasWorkout: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                if isToday && isSelected {
                    Circle()
                        .fill(Color.colorPrimal)
                        .frame(width: 34, height: 34)
                } else if isSelected && !isToday {
                    Circle()
                        .fill(Color.colorPrimal.opacity(0.1))
                        .frame(width: 34, height: 34)
                }
                if !hasWorkout && !isToday{
                    Text(date.dayNumber())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(white: 0.3))
                        .frame(width: 32, height: 32)
                }else{
                    Text(date.dayNumber())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(textColor)
                        .frame(width: 32, height: 32)
                }
                
                
                if(isToday && isSelected){
                    Circle()
                        .fill(Color.black)
                        .frame(width: 6, height: 6)
                        .opacity(hasWorkout ? 1 : 0)
                        .padding(.top, 24)
                }else{
                    Circle()
                        .fill(Color.colorPrimal.opacity(0.8))
                        .frame(width: 6, height: 6)
                        .opacity(hasWorkout ? 1 : 0)
                        .padding(.top, 24)  
                }
                
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .opacity(isFuture ? 0.5 : 1.0)
    }

    private var textColor: Color {
        if isToday && isSelected { return .black }
        else if isSelected && !isToday { return .colorPrimal }
        else if isToday && !isSelected { return .colorPrimal }
        else if isFuture && !isSelected { return .white.opacity(0.2)}
        else { return .primary }
    }
}
