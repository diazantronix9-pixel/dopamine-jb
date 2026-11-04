import SwiftUI

/// Main "tap to log" screen: goal ring + grid of dopamine hits.
struct DashboardView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Dopamine")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                Spacer()
                Text("🎯")
            }

            // Goal ring
            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.15), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5), value: progress)
                VStack {
                    Text("\(store.todaysTotal)")
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(Color.orange)
                    Text("de \(store.dailyGoal) hoy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 170, height: 170)
            .padding(.top, 8)

            // Streak chip
            Label("\(store.bestStreak) días de racha", systemImage: "flame.fill")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.orange.opacity(0.15)))
                .foregroundStyle(Color.orange)

            // Flavor grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(DopamineFlavor.all) { flavor in
                        Button {
                            withAnimation { store.add(flavor) }
                        } label: {
                            VStack(spacing: 6) {
                                Text(flavor.emoji)
                                    .font(.system(size: 34))
                                Text(flavor.name)
                                    .font(.footnote.weight(.medium))
                            }
                            .frame(maxWidth: .infinity, minHeight: 90)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.orange.opacity(0.08))
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Undo + celebration banner
            if store.celebrate {
                Text("🎉 ¡Dopamine! +1")
                    .font(.headline)
                    .padding()
                    .background(Capsule().fill(Color.orange))
                    .transition(.scale.combined(with: .opacity))
            } else {
                if store.todaysTotal > 0 {
                    Button("↩︎ Deshacer") { store.removeLast() }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    private var progress: Double {
        min(Double(store.todaysTotal) / Double(store.dailyGoal), 1.0)
    }
}