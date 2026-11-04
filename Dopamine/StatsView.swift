import SwiftUI

/// Bar chart of the last 7 days + breakdown by flavor.
struct StatsView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        VStack(spacing: 24) {
            Text("Estadísticas")
                .font(.system(size: 26, weight: .heavy, design: .rounded))

            // 7-day bar chart
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(store.last7Days.enumerated()), id: \.offset) { offset, count in
                        VStack(spacing: 4) {
                            Capsule()
                                .fill(Color.orange)
                                .frame(height: barHeight(count))
                            Text(dayLabel(offset: offset))
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 120, alignment: .bottom)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.orange.opacity(0.06)))

            // Totals row
            HStack(spacing: 12) {
                StatCard(title: "Hoy", value: "\(store.todaysTotal)", emoji: "📅")
                StatCard(title: "Total", value: "\(store.totalAllTime)", emoji: "🏆")
                StatCard(title: "Racha", value: "\(store.bestStreak)d", emoji: "🔥")
            }
            .padding(.horizontal)

            // Flavor breakdown
            VStack(alignment: .leading, spacing: 10) {
                Text("Por tipo").font(.subheadline.weight(.semibold))
                ForEach(DopamineFlavor.all) { flavor in
                    let count = store.hits.filter { $0.flavorID == flavor.id }.count
                    HStack {
                        Text(flavor.emoji)
                        Text(flavor.name)
                        Spacer()
                        Text("\(count)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.orange)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.orange.opacity(0.06)))

            Spacer()
        }
        .padding()
    }

    private func barHeight(_ count: Int) -> CGFloat {
        let maxCount = max(store.last7Days.max() ?? 1, 1)
        return CGFloat(count) / CGFloat(maxCount) * 100 + 4
    }

    private func dayLabel(offset: Int) -> String {
        let cal = Calendar.current
        let date = cal.date(byAdding: .day, value: -(store.last7Days.count - 1 - offset), to: Date())!
        return cal.shortWeekdaySymbols[cal.component(.weekday, from: date) - 1]
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let emoji: String

    var body: some View {
        VStack(spacing: 4) {
            Text(emoji).font(.title3)
            Text(value)
                .font(.title2.weight(.black, design: .rounded))
                .foregroundStyle(Color.orange)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.orange.opacity(0.08)))
    }
}