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
    @Binding var showCalendar: Bool
    @Binding var selectedDate: Date
    @ObservedObject var manager: HealthManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack{
                Button {
                    withAnimation (){
                        showCalendar.toggle()
                    }
                } label: {
                    Text(selectedDate.formattedPill())
                        .font(.headline.weight(.regular))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.darkGrayBackground)
                        )
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            if showCalendar {
                CalendarView(
                    selectedDate: $selectedDate,
                    manager: manager
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
        }
        .background(Color.clear)
    }
}
