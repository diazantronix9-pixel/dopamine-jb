import Foundation
import SwiftUI

/// Single source of truth. Persists to UserDefaults as JSON.
final class Store: ObservableObject {
    @Published var hits: [DopamineHit] = []
    @Published var dailyGoal: Int = 5
    @Published var celebrate: Bool = false
    @Published var haptics: Bool = true

    private let saveKey = "dopamine.hits.v1"

    init() { load() }

    // MARK: Actions
    func add(_ flavor: DopamineFlavor) {
        hits.insert(DopamineHit(flavorID: flavor.id), at: 0)
        pulse()
        save()
    }

    func removeLast() {
        guard !hits.isEmpty else { return }
        hits.removeFirst()
        save()
    }

    // MARK: Stats
    var todaysTotal: Int {
        let cal = Calendar.current
        return hits.filter { cal.isDateInToday($0.timestamp) }.count
    }

    var totalAllTime: Int { hits.count }

    var bestStreak: Int { computeStreak() }

    /// Counts consecutive days (ending today or yesterday) with ≥ 1 hit.
    private func computeStreak() -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: Date())
        let todayHasHit = hits.contains { cal.isDate($0.timestamp, inSameDayAs: day) }
        if !todayHasHit { day = cal.date(byAdding: .day, value: -1, to: day)! }
        while true {
            if hits.contains(where: { cal.isDate($0.timestamp, inSameDayAs: day) }) {
                streak += 1
                day = cal.date(byAdding: .day, value: -1, to: day)!
            } else { break }
        }
        return streak
    }

    /// Hits per day for the last 7 days (oldest → newest).
    var last7Days: [Int] {
        let cal = Calendar.current
        var out = [Int]()
        for offset in stride(from: 6, through: 0, by: -1) {
            let day = cal.date(byAdding: .day, value: -offset, to: Date())!
            out.append(hits.filter { cal.isDate($0.timestamp, inSameDayAs: day) }.count)
        }
        return out
    }

    // MARK: Haptics + celebration pulse
    private var cancellables = Set<AnyCancellable>()

    func pulse() {
        celebrate = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.celebrate = false }
        if haptics {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    // MARK: Persistence
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return }
        if let decoded = try? JSONDecoder().decode([DopamineHit].self, from: data) {
            hits = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(hits) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
}