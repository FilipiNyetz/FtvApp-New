
import SwiftUI
import SwiftUI

struct CalendarScreen: View {
    @Binding var showCalendar: Bool
    @Binding var selectedDate: Date
    @ObservedObject var manager: HealthManager
    
    
    var body: some View {
        VStack(spacing: 12) {
            HStack{
                Button {
                    withAnimation (){
                        showCalendar.toggle()
                    }
                } label: {
                }
                Spacer()
            }
            
            if showCalendar {
                CalendarView(
                    selectedDate: $selectedDate,
                    manager: manager
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
        }
        .background(Color.clear)
    }
}
