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
        VStack{
            CalendarScreen(showCalendar: $showCalendar, selectedDate: $selectedDate, manager: manager)
        }
    }
}




