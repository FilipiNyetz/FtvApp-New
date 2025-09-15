//
//  DatePickerField.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

/*struct DatePickerField: View {
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
}*/

/*struct DatePickerField: View {
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    @ObservedObject var manager: HealthManager
    
    var body: some View {
        ZStack {
            // Fundo invisível para fechar o calendário ao tocar fora
            if showCalendar {
                Color.black.opacity(0.4) // um leve escurecimento ajuda a indicar modo "aberto"
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showCalendar = false
                        }
                    }
            }
            
            VStack(spacing: 8) {
                // Botão que mostra a data atual e abre o calendário
                Button {
                    withAnimation {
                        showCalendar.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedDate, style: .date) // mostra a data atual
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showCalendar ? 180 : 0))
                            .animation(.easeInOut, value: showCalendar)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Calendário aparece somente quando showCalendar = true
                if showCalendar {
                    CalendarScreen(
                        showCalendar: $showCalendar,
                        selectedDate: $selectedDate,
                        manager: manager
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding()
        }
    }
}*/

struct DatePickerField: View {
    @Binding var selectedDate: Date
    @Binding var showCalendar: Bool
    @ObservedObject var manager: HealthManager
    
    var body: some View {
        ZStack {
            // Fecha o calendário ao tocar fora
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
            
            VStack(spacing: 8) {
                // Indicador clicável sutil
                Button {
                    withAnimation {
                        showCalendar.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedDate, style: .date) // mostra a data atual
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showCalendar ? 180 : 0))
                            .animation(.easeInOut, value: showCalendar)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                }
                
                // Mostra o calendário apenas quando aberto
                if showCalendar {
                    CalendarScreen(
                        showCalendar: $showCalendar,
                        selectedDate: $selectedDate,
                        manager: manager
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}






