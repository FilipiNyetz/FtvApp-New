import SwiftUI

struct jumpdata: View {
    let data: [Workout]
    let selectedMetric: String
    
    var body: some View {
        let stats = computeStats(data: data, metric: selectedMetric)
        
        HStack(spacing: 12) {
            StatCard(
                title: Text("MÁX"),
                value: stats.maxValueText,
                unit: stats.unit,
                dateText: stats.maxDateText
            )
            
            StatCard(
                title: Text("MÍN"),
                value: stats.minValueText,
                unit: stats.unit,
                dateText: stats.minDateText
            )
        }
    }
    
    
    
    
    func computeStats(data: [Workout], metric: String) -> (maxValueText: String, minValueText: String, maxDateText: String, minDateText: String, unit: String) {
        guard !data.isEmpty else {
            return ("—", "—", "—", "—", unitFor(metric))
        }
        
        let pairs: [(workout: Workout, value: Double)] = data.map { ($0, valueForMetric($0, metric)) }
        
        guard let maxPair = pairs.max(by: { $0.value < $1.value }),
              let minPair = pairs.min(by: { $0.value < $1.value }) else {
            return ("—", "—", "—", "—", unitFor(metric))
        }
        
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.dateFormat = "dd/MM/yy"
        
        let (maxText, minText) = formattedValues(maxPair.value, minPair.value, for: metric)
        
        let maxDate = fmt.string(from: maxPair.workout.dateWorkout)
        let minDate = fmt.string(from: minPair.workout.dateWorkout)
        
        return (maxText, minText, maxDate, minDate, unitFor(metric))
    }
    
    private func unitFor(_ metric: String) -> String {
        switch metric {
        case "calories":  return "kcal"
        case "distance":  return "m"      
        case "heartRate": return "bpm"
        case "height":    return "cm"
        default:          return ""
        }
    }
    
    private func formattedValues(_ max: Double, _ min: Double, for metric: String) -> (String, String) {
        switch metric {
        case "heartRate": return (String(format: "%.0f", max), String(format: "%.0f", min))
        case "calories":  return (String(format: "%.0f", max), String(format: "%.0f", min))
        case "distance":  return (String(format: "%.0f", max), String(format: "%.0f", min))
        case "height":    return (String(format: "%.0f", max), String(format: "%.0f", min))
        default:          return (String(format: "%.0f", max), String(format: "%.0f", min))
        }
    }
    
}
