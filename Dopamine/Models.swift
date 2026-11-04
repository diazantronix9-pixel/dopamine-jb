import Foundation

/// One type of "dopamine hit" the user can log.
struct DopamineFlavor: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    /// Hex-ish tint used in the UI.
    let colorHex: String
}

extension DopamineFlavor {
    static let all: [DopamineFlavor] = [
        .init(id: "music",    name: "Música",     emoji: "🎧", colorHex: "FF7A00"),
        .init(id: "food",     name: "Comida",     emoji: "🍜", colorHex: "FF3B30"),
        .init(id: "move",     name: "Mover",      emoji: "🏃", colorHex: "34C759"),
        .init(id: "social",   name: "Social",     emoji: "💬", colorHex: "0A84FF"),
        .init(id: "learn",    name: "Aprender",   emoji: "📚", colorHex: "AF52DE"),
        .init(id: "relax",    name: "Relax",      emoji: "🧘", colorHex: "00C7BE"),
    ]
}

/// A single logged hit.
struct DopamineHit: Identifiable, Codable {
    var id: UUID = UUID()
    var flavorID: String
    var timestamp: Date = Date()

    var flavor: DopamineFlavor {
        DopamineFlavor.all.first { $0.id == flavorID } ?? DopamineFlavor.all[0]
    }
}

/// Aggregated counters shown on the dashboard.
struct DayStats: Codable {
    var total: Int = 0
    var streakDays: Int = 0
    var byFlavor: [String: Int] = [:]
}