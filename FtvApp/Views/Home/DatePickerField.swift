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
                    }
            }
        }
    }
}




