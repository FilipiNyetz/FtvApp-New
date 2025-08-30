//
//  CalendarView.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 18/08/25.
//

import Foundation
import SwiftUICore
import SwiftUI

// MARK: - Calendário principal

struct CalendarView: View {
    @Binding var selectedDate: Date
    @ObservedObject var manager: HealthManager
    @State private var currentMonth: Date
    @State private var transitionDirection: TransitionDirection = .forward
    
    private enum TransitionDirection {
        case forward, backward
    }
    
    init(selectedDate: Binding<Date>, manager: HealthManager) {
        self._selectedDate = selectedDate
        self.manager = manager
        self._currentMonth = State(initialValue: selectedDate.wrappedValue.startOfMonth)
    }
    
    var body: some View {
        let transition = AnyTransition.asymmetric(
            insertion: .move(edge: transitionDirection == .forward ? .trailing : .leading),
            removal: .move(edge: transitionDirection == .forward ? .leading : .trailing)
        )
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .transition(transition)
                .id(currentMonth)
            
            weekHeader
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(transition)
                .id(currentMonth)
            
            monthGrid
                .padding(.horizontal, 16)
                .transition(transition)
                .id(currentMonth)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkGrayBackground)
        )
    }
    
    // MARK: - Subviews
    
    private var header: some View {
        HStack {
            Text(monthTitle)
                .font(.title3)
                .bold()
            
            Spacer()
            
            Button {
                transitionDirection = .backward
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .padding(.trailing, 12)
            
            Button {
                transitionDirection = .forward
                withAnimation(.easeInOut(duration: 0.5)) {
                                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.primary)
    }
    
    private var weekHeader: some View {
        HStack {
            ForEach([NSLocalizedString("DOM", comment: ""),
                     NSLocalizedString("SEG", comment: ""),
                     NSLocalizedString("TER", comment: ""),
                     NSLocalizedString("QUA", comment: ""),
                     NSLocalizedString("QUA", comment: ""),
                     NSLocalizedString("SEX", comment: ""),
                     NSLocalizedString("SÁB", comment: "")], id: \.self) { day in
                Text(day + ".")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    var monthGrid: some View {
        let days = getDaysInMonth()
        let today = Date()
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
            ForEach(0..<getLeadingBlanks(), id: \.self) { _ in
                Color.clear.frame(height: 22)
            }
            
            ForEach(days, id: \.self) { day in
                let isToday = day.isSameDay(as: today)
                let isFuture = day > today && !isToday
                let hasWorkout = manager.workoutsByDay[Calendar.current.startOfDay(for: day)]?.isEmpty == false
                
                DayCell(
                    date: day,
                    isToday: isToday,
                    isSelected: day.isSameDay(as: selectedDate),
                    isFuture: isFuture,
                    hasWorkout: hasWorkout
                )
                .foregroundColor(
                    (!hasWorkout && !isToday) ? .gray : .primary
                )
                .onTapGesture {
                    if !isFuture && (hasWorkout || isToday) {
                        selectedDate = day
                    }
                }
                .allowsHitTesting(hasWorkout || isToday)
            }
        }
    }


    

    // MARK: - Funções auxiliares
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL 'de' yyyy"
        return formatter.string(from: currentMonth)
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let startDate = currentMonth.startOfMonth
        
        var days: [Date] = []
        for i in 0..<range.count {
            days.append(startDate.adding(days: i))
        }
        return days
    }
    
    private func getLeadingBlanks() -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentMonth.startOfMonth)
        return (weekday + 6) % 7  
    }
}
