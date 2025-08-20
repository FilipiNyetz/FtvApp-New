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
    @ObservedObject var manager: HealthManager   // <-- referência direta
    
    @State private var currentMonth: Date
    
    init(selectedDate: Binding<Date>, manager: HealthManager) {
        self._selectedDate = selectedDate
        self.manager = manager
        self._currentMonth = State(initialValue: selectedDate.wrappedValue.startOfMonth)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Cabeçalho com mês/ano e setas de navegação
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            // Cabeçalho dos dias da semana
            weekHeader
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            // Grid com os dias do mês
            monthGrid
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
//            // Linha separadora (se houver jogos)
//            if selectedDayHasGames {
//                Divider()
//                    .background(Color.gray.opacity(0.3))
//                    .padding(.horizontal, 16)
//                    .padding(.top, 8)
//            }
//            
//            // Componente de jogos
//            gameSection
//                .padding(.horizontal, 16)
//                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
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
                withAnimation {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .padding(.trailing, 8)
            
            Button {
                withAnimation {
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
            ForEach(["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SÁB"], id: \.self) { day in
                Text(day + ".")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var monthGrid: some View {
            let days = getDaysInMonth()
            let today = Date()
            
            return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(0..<getLeadingBlanks(), id: \.self) { _ in Color.clear.frame(height: 44) }
                
                ForEach(days, id: \.self) { day in
                    let isFuture = day > today && !day.isSameDay(as: today)
                    let hasWorkout = manager.workoutsByDay[Calendar.current.startOfDay(for: day)]?.isEmpty == false
                    
                    DayCell(
                        date: day,
                        isToday: day.isSameDay(as: today),
                        isSelected: day.isSameDay(as: selectedDate),
                        isFuture: isFuture,
                        hasWorkout: hasWorkout
                    )
                    .onTapGesture {
                        if !isFuture { selectedDate = day }
                    }
                }
            }
        }
    
//    private var gameSection: some View {
//        Group {
//            if selectedDayHasGames, let gameTimes = selectedDayInfo?.gameTimes {
//                
//                VStack(alignment: .leading, spacing: 8) {
//                    NavigationLink(destination: GamesView()) {
//                        HStack {
//                            Text("Meus Jogos")
//                                .font(.title3)
//
//                            Spacer()
//
//                            Image(systemName: "chevron.right")
//                        }
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(12)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .padding()
//                .background(Color(.secondarySystemBackground))
//                .cornerRadius(12)
//                .frame(height: 56)
//                .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//    }
    // MARK: - Funções auxiliares
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "LLLL 'de' yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
//    private var selectedDayInfo: DayInfo? {
//        return calendarData[normalizeDate(selectedDate)]
//    }
//    
//    private var selectedDayHasGames: Bool {
//        return selectedDayInfo?.hasGames == true
//    }
    
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
        return (weekday + 6) % 7  // Converte domingo=1 para domingo=0
    }
}
