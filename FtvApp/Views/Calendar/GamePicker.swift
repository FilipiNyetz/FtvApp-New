////
////  GamePicker.swift
////  FtvApp
////
////  Created by Joao pedro Leonel on 18/08/25.
////
//
//import Foundation
//import SwiftUICore
//import SwiftUI
//
//// MARK: - Seletor de jogos
//
//struct GamePicker: View {
//    let gameTimes: [String]
//    @State private var selectedIndex = 0
//    
//    var body: some View {
//        Menu {
//            ForEach(gameTimes.indices, id: \.self) { index in
//                Button {
//                    selectedIndex = index
//                } label: {
//                    HStack {
//                        Text("\(index + 1)º jogo")
//                        Spacer()
//                        Text(gameTimes[index])
//                    }
//                }
//            }
//        } label: {
//            HStack(spacing: 6) {
//                Text("\(selectedIndex + 1)º")
//                    .foregroundStyle(.gray)
//                
//                Image(systemName: "chevron.up.chevron.down")
//                    .font(.caption)
//                    .foregroundStyle(.gray)
//            }
//            .padding(.vertical, 10)
//            .padding(.horizontal, 12)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color(.tertiarySystemFill))
//            )
//        }
//    }
//}
//
//#Preview {
//    GamePicker(gameTimes: ["09:12", "11:46", "19:23"])
//        .padding()
//}
//
