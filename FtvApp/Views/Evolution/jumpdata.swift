import SwiftUI

struct jumpdata: View {
    let data: [Workout]
    let selectedMetric: String

    var body: some View {
        let stats = computeStats(data: data, metric: selectedMetric)

        HStack(spacing: 12) {
            // Card Máx
            statCard(
                title: "MÁX",
                value: stats.maxValueText,
                unit: stats.unit,
                dateText: stats.maxDateText
            )

            // Card Mín
            statCard(
                title: "MÍN",
                value: stats.minValueText,
                unit: stats.unit,
                dateText: stats.minDateText
            )
        }
    }

    // MARK: - Views

    @ViewBuilder
    private func statCard(title: String, value: String, unit: String, dateText: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(dateText) // dd/MM/yy
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .fontWeight(.semibold)
                    .font(.title)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(height: 76)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }

    // MARK: - Lógica

    private func computeStats(data: [Workout], metric: String) -> (maxValueText: String, minValueText: String, maxDateText: String, minDateText: String, unit: String) {
        guard !data.isEmpty else {
            // Sem dados
            return ("—", "—", "—", "—", unitFor(metric))
        }

        // Valores conforme a métrica
        let pairs: [(workout: Workout, value: Double)] = data.map { ($0, valueForMetric($0, metric)) }

        guard let maxPair = pairs.max(by: { $0.value < $1.value }),
              let minPair = pairs.min(by: { $0.value < $1.value }) else {
            return ("—", "—", "—", "—", unitFor(metric))
        }

        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.dateFormat = "dd/MM/yy"

        // Formata números por métrica
        let (maxText, minText) = formattedValues(maxPair.value, minPair.value, for: metric)

        let maxDate = fmt.string(from: maxPair.workout.dateWorkout)
        let minDate = fmt.string(from: minPair.workout.dateWorkout)

        return (maxText, minText, maxDate, minDate, unitFor(metric))
    }

    private func unitFor(_ metric: String) -> String {
        switch metric {
        case "Caloria":   return "kcal"
        case "Distância": return "m"      // ajuste se usar km
        case "Batimento": return "bpm"
        default:          return ""
        }
    }

    private func formattedValues(_ max: Double, _ min: Double, for metric: String) -> (String, String) {
        switch metric {
        case "Batimento":
            return (String(format: "%.0f", max), String(format: "%.0f", min))
        case "Caloria", "Distância":
            return (String(format: "%.0f", max), String(format: "%.0f", min))
        default:
            return (String(format: "%.0f", max), String(format: "%.0f", min))
        }
    }
}

#Preview {
    // Preview com dados fake
    let now = Date()
    let fake: [Workout] = [
        Workout(id: UUID(), idWorkoutType: 0, duration: 0, calories: 230, distance: 800, frequencyHeart: 120, dateWorkout: now.addingTimeInterval(-2*86400)),
        Workout(id: UUID(), idWorkoutType: 0, duration: 0, calories: 450, distance: 1200, frequencyHeart: 150, dateWorkout: now.addingTimeInterval(-1*86400)),
        Workout(id: UUID(), idWorkoutType: 0, duration: 0, calories: 300, distance: 600, frequencyHeart: 110, dateWorkout: now)
    ]
    return jumpdata(data: fake, selectedMetric: "Batimento")
        .preferredColorScheme(.dark)
}
