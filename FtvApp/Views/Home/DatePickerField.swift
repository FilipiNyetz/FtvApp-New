
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
            
            VStack(spacing: 8) {
                Button {
                    withAnimation {
                        showCalendar.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedDate, style: .date) 
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
