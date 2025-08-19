//
//  CalendarScreen.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 18/08/25.
//

import SwiftUI

// MARK: - Tela principal do calendário

import SwiftUI

struct CalendarScreen: View {
    @State private var showCalendar = false
    @Binding var selectedDate: Date
    
    private let calendarData = SampleData.createCalendarData()
    
    var body: some View {
        VStack(spacing: 16) {
            // Pílula da data ( fixa a esquerda)
            HStack{
                Button {
                    withAnimation (){
                        showCalendar.toggle()
                    }
                } label: {
                    Text(selectedDate.formattedPill())
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.tertiaryLabel).opacity(0.35))
                        )
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            
            // Calendário (aparece/desaparece)
            if showCalendar {
                CalendarView(
                    selectedDate: $selectedDate,
                    calendarData: calendarData
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Spacer()
        }
        //.padding()
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    CalendarScreen(selectedDate: .constant(Date()))
        .preferredColorScheme(.dark) // opcional
}
