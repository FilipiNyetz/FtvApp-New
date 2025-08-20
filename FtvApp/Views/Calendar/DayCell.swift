//
//  DayCell.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 18/08/25.
//

import Foundation
import SwiftUICore

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
                        .fill(Color.brandGreen)
                        .frame(width: 32, height: 32)
                }
                // Fundo do dia selecionado (branco)
                else if isSelected && !isToday {
                    Circle()
                        .fill(Color.brandGreen.opacity(0.1))
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
                .fill(Color.brandGreen.opacity(0.8))
                .frame(width: 6, height: 6)
                .opacity(dayInfo?.hasCompletedTraining == true ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .opacity(isFuture ? 0.5 : 1.0)  // Dias futuros ficam mais transparentes
    }
    
    private var textColor: Color {
        if isToday && isSelected {
            return .black  // Texto branco no fundo rosa
        } else if isSelected && !isToday {
            return .brandGreen  // Texto preto no fundo branco
        } else if isToday && !isSelected {
            return .brandGreen  // Texto rosa para o dia atual
        } else if isFuture && !isSelected {
            return .gray  // Texto cinza para dias futuros
        } else {
            return .primary  // Texto normal
        }
    }
}
