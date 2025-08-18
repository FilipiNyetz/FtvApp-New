//
//  CalendarScreen.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 18/08/25.
//

import SwiftUI

// MARK: - Extensões para facilitar o trabalho com datas

extension Date {
    // Verifica se duas datas são do mesmo dia
    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: other)
    }
    
    // Retorna o primeiro dia do mês
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // Adiciona dias à data
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    // Formata a data para exibir na pílula (ex: "12 de ago. de 2025")
    func formattedPill() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d 'de' MMM 'de' yyyy"
        return formatter.string(from: self)
    }
    
    // Retorna apenas o número do dia
    func dayNumber() -> String {
        let day = Calendar.current.component(.day, from: self)
        return String(day)
    }
}

// MARK: - Cores personalizadas

extension Color {
    static let brandPink = Color(red: 201/255, green: 0/255, blue: 68/255)
    static let dayDot = Color.primary.opacity(0.35)
    static let cardBackground = Color(.secondarySystemBackground)
}

// MARK: - Modelo de dados para cada dia

struct DayInfo {
    var hasCompletedTraining: Bool = false  // Se o usuário finalizou treino/jogo neste dia
    var gameTimes: [String] = []           // Horários dos jogos (ex: ["09:12", "11:46"])
    
    var hasGames: Bool {
        return !gameTimes.isEmpty
    }
}

// MARK: - Dados de exemplo

struct SampleData {
    static func createCalendarData() -> [Date: DayInfo] {
        var data: [Date: DayInfo] = [:]
        let calendar = Calendar.current
        
        // Exemplo para agosto de 2025
        let exampleMonth = calendar.date(from: DateComponents(year: 2025, month: 8, day: 1))!
        
        // Dias com treinos finalizados
        let trainingDays = [3, 4, 5, 6, 8, 11, 13]
        for day in trainingDays {
            let date = calendar.date(bySetting: .day, value: day, of: exampleMonth)!
            data[date] = DayInfo(hasCompletedTraining: true)
        }
        
        // Dia 8 com jogos
        let dayWithGames = calendar.date(bySetting: .day, value: 8, of: exampleMonth)!
        data[dayWithGames] = DayInfo(
            hasCompletedTraining: true,
            gameTimes: ["09:12", "11:46", "19:23", "20:57"]
        )
        
        return data
    }
}

// MARK: - Célula de cada dia do calendário

struct DayCell: View {
    let date: Date
    let dayInfo: DayInfo?
    let isToday: Bool
    let isSelected: Bool
    let isFuture: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Fundo do dia atual selecionado (rosa)
                if isToday && isSelected {
                    Circle()
                        .fill(Color.brandPink)
                        .frame(width: 32, height: 32)
                }
                // Fundo do dia selecionado (branco)
                else if isSelected && !isToday {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                }
                
                // Número do dia
                Text(date.dayNumber())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(textColor)
                    .frame(width: 32, height: 32)
            }
            
            // Bolinha indicando treino finalizado
            Circle()
                .fill(Color.dayDot)
                .frame(width: 6, height: 6)
                .opacity(dayInfo?.hasCompletedTraining == true ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .opacity(isFuture ? 0.5 : 1.0)  // Dias futuros ficam mais transparentes
    }
    
    private var textColor: Color {
        if isToday && isSelected {
            return .white  // Texto branco no fundo rosa
        } else if isSelected && !isToday {
            return .black  // Texto preto no fundo branco
        } else if isToday && !isSelected {
            return .brandPink  // Texto rosa para o dia atual
        } else if isFuture && !isSelected {
            return .gray  // Texto cinza para dias futuros
        } else {
            return .primary  // Texto normal
        }
    }
}

// MARK: - Calendário principal

struct CalendarView: View {
    @Binding var selectedDate: Date
    let calendarData: [Date: DayInfo]
    
    @State private var currentMonth: Date
    
    init(selectedDate: Binding<Date>, calendarData: [Date: DayInfo]) {
        self._selectedDate = selectedDate
        self.calendarData = calendarData
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
            
            // Linha separadora (se houver jogos)
            if selectedDayHasGames {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
            
            // Componente de jogos
            gameSection
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
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
            // Espaços vazios no início do mês
            ForEach(0..<getLeadingBlanks(), id: \.self) { _ in
                Color.clear.frame(height: 44)
            }
            
            // Dias do mês
            ForEach(days, id: \.self) { day in
                let dayInfo = calendarData[normalizeDate(day)]
                let isFuture = day > today && !day.isSameDay(as: today)
                
                DayCell(
                    date: day,
                    dayInfo: dayInfo,
                    isToday: day.isSameDay(as: today),
                    isSelected: day.isSameDay(as: selectedDate),
                    isFuture: isFuture
                )
                .onTapGesture {
                    // Só permite clique se não for dia futuro
                    if !isFuture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedDate = day
                        }
                    }
                }
            }
        }
    }
    
    private var gameSection: some View {
        Group {
            if selectedDayHasGames, let games = selectedDayInfo?.gameTimes {
                HStack {
                    Text("Jogo")
                        .font(.headline)
                    
                    Spacer()
                    
                    GamePicker(gameTimes: games)
                }
                .frame(height: 56)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    // MARK: - Funções auxiliares
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "LLLL 'de' yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
    private var selectedDayInfo: DayInfo? {
        return calendarData[normalizeDate(selectedDate)]
    }
    
    private var selectedDayHasGames: Bool {
        return selectedDayInfo?.hasGames == true
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
        return (weekday + 6) % 7  // Converte domingo=1 para domingo=0
    }
}

// MARK: - Seletor de jogos

struct GamePicker: View {
    let gameTimes: [String]
    @State private var selectedIndex = 0
    
    var body: some View {
        Menu {
            ForEach(gameTimes.indices, id: \.self) { index in
                Button {
                    selectedIndex = index
                } label: {
                    HStack {
                        Text("\(index + 1)º jogo")
                        Spacer()
                        Text(gameTimes[index])
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text("\(selectedIndex + 1)º")
                    .foregroundStyle(.gray)
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemFill))
            )
        }
    }
}

// MARK: - Tela principal do calendário

struct CalendarScreen: View {
    @State private var showCalendar = false
    @Binding var selectedDate: Date
    
    private let calendarData = SampleData.createCalendarData()
    
    var body: some View {
        VStack(spacing: 16) {
            // Pílula da data (fixa na esquerda)
            HStack {
                Button {
                    withAnimation {
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
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }
}
