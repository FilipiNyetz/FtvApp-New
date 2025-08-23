//
//  DatePickerField.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

struct DatePickerField: View {
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    @ObservedObject var manager: HealthManager
    
    var body: some View {
        ZStack {
            // Background invisível para detectar toques fora do calendário
            if showCalendar {
                Color.clear
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onTapGesture {
                        withAnimation {
                            showCalendar = false
                        }
                    }
                    .ignoresSafeArea()
            }
            
            VStack{
                CalendarScreen(showCalendar: $showCalendar, selectedDate: $selectedDate, manager: manager)
                    .onTapGesture {
                        // Impede que toques no calendário sejam propagados para o background
                    }
            }
        }
    }
}




