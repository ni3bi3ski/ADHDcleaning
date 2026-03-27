import SwiftUI
import Charts

struct WeeklyStatsView: View {
    @ObservedObject var vm: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showResetAlert = false

    var weeklyStats: [DailyStats] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        return vm.dailyStats.filter { $0.date >= sevenDaysAgo }
    }
    var totalTasks: Int { weeklyStats.reduce(0) { $0 + $1.tasksCompleted } }
    var totalExp: Int   { weeklyStats.reduce(0) { $0 + $1.expEarned } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Stat Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatsCardView(title: "Zadania",   value: "\(totalTasks)",
                                      icon: "checkmark.circle.fill", colors: [.green, .teal])
                        StatsCardView(title: "XP zdobyte", value: "\(totalExp)",
                                      icon: "bolt.fill",              colors: [.blue, .purple])
                        StatsCardView(title: "Poziom",     value: "\(vm.level)",
                                      icon: "star.fill",              colors: [.purple, .indigo])
                        StatsCardView(title: "Śr. / dzień",
                                      value: String(format: "%.1f", Double(totalTasks) / 7.0),
                                      icon: "chart.line.uptrend.xyaxis", colors: [.orange, .red])
                    }
                    .padding(.horizontal)

                    // MARK: - Wykresy lub empty state
                    if weeklyStats.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                            Text("Jeszcze brak statystyk")
                                .font(.title3).bold()
                            Text("Zacznij wykonywać zadania,\naby zobaczyć swoje postępy!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        // Wykres zadań
                        ChartCardView(title: "Zadania w tygodniu",
                                      icon: "checkmark.circle", iconColor: .green) {
                            Chart(weeklyStats) { stat in
                                BarMark(
                                    x: .value("Dzień", stat.date, unit: .day),
                                    y: .value("Zadania", stat.tasksCompleted)
                                )
                                .foregroundStyle(
                                    LinearGradient(colors: [.green, .teal],
                                                   startPoint: .bottom, endPoint: .top)
                                )
                                .cornerRadius(6)
                            }
                            .frame(height: 180)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color.secondary.opacity(0.3))
                                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color.secondary.opacity(0.3))
                                    AxisValueLabel()
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Wykres XP
                        ChartCardView(title: "XP w tygodniu",
                                      icon: "bolt.fill", iconColor: .blue) {
                            Chart(weeklyStats) { stat in
                                AreaMark(
                                    x: .value("Dzień", stat.date, unit: .day),
                                    y: .value("XP", stat.expEarned)
                                )
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue.opacity(0.3), .clear],
                                                   startPoint: .top, endPoint: .bottom)
                                )
                                LineMark(
                                    x: .value("Dzień", stat.date, unit: .day),
                                    y: .value("XP", stat.expEarned)
                                )
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .purple],
                                                   startPoint: .leading, endPoint: .trailing)
                                )
                                .lineStyle(StrokeStyle(lineWidth: 2.5))
                                .symbol(.circle)
                                .symbolSize(30)
                            }
                            .frame(height: 180)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color.secondary.opacity(0.3))
                                    AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(Color.secondary.opacity(0.3))
                                    AxisValueLabel()
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Historia tygodni
                    if !vm.weekHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.indigo)
                                    .font(.subheadline)
                                Text("Historia tygodni")
                                    .font(.headline)
                            }
                            ForEach(vm.weekHistory) { week in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Tydzień \(week.weekNumber)")
                                            .font(.subheadline).bold()
                                        Text(week.startDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(week.tasksCompleted) zadań")
                                            .font(.subheadline).bold()
                                            .foregroundColor(.green)
                                        Text("\(week.expEarned) XP")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Reset
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Zresetuj wszystkie dane")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color.red.opacity(0.25), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Statystyki")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zamknij") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .alert("Zresetować dane?", isPresented: $showResetAlert) {
                Button("Anuluj", role: .cancel) {}
                Button("Zresetuj", role: .destructive) {
                    vm.resetAll()
                    dismiss()
                }
            } message: {
                Text("Spowoduje to usunięcie wszystkich zadań, XP, poziomu, serii i statystyk. Ta operacja jest nieodwracalna.")
            }
        }
    }
}

// MARK: - Stats Card
private struct StatsCardView: View {
    let title: String
    let value: String
    let icon: String
    let colors: [Color]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline).bold()
                    .foregroundStyle(
                        LinearGradient(colors: colors,
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: colors.first?.opacity(0.12) ?? .clear, radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(colors: colors.map { $0.opacity(0.2) },
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Chart Card Container
private struct ChartCardView<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.subheadline)
                Text(title)
                    .font(.headline)
            }
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}
