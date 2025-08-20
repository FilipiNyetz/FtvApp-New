//
//  DatePickerField.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

struct DatePickerField: View {
    @Binding var selectedDate: Date
    @ObservedObject var manager: HealthManager
    
    var body: some View {
        VStack{
            CalendarScreen(selectedDate: $selectedDate, manager: manager)
        }
    }
}




