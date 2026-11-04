import SwiftUI

/// A Pomodoro-style focus timer. While running, each dopamine hit you log
/// gets a "temptation" badge so you can see how much you resisted.
struct FocusView: View {
    @EnvironmentObject var store: Store
    @State private var minutes: Int = 25
    @State private var remaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var temptationCount = 0
    @State private var lastHitCount = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text("Modo Foco")
                .font(.system(size: 26, weight: .heavy, design: .rounded))

            // Time picker
            HStack(spacing: 0) {
                ForEach([15, 25, 45, 60], id: \.self) { m in
                    Button("\(m)") { minutes = m; if !isRunning { remaining = m * 60 } }
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(minutes == m ? Color.orange : Color.orange.opacity(0.1))
                        .foregroundStyle(minutes == m ? Color.white : Color.orange)
                }
            }
            .clipShape(Capsule())

            // Big countdown
            ZStack {
                Circle()
                    .stroke(Color.orange.opacity(0.12), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.orange)
                    if isRunning {
                        Text("enfocado…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(width: 220, height: 220)

            // Temptation tracker
            HStack(spacing: 12) {
                Label("\(temptationCount)", systemImage: "hand.tap.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.orange)
                Text(temptationCount == 0 ? "sin tentaciones 🏆" : "dopamines mientras te enfocas")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Controls
            HStack(spacing: 16) {
                Button {
                    withAnimation { isRunning.toggle() }
                    if isRunning { remaining = minutes * 60 }
                } label: {
                    Text(isRunning ? "⏸ Pausa" : "▶️ Empezar")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(isRunning ? Color.orange.opacity(0.2) : Color.orange))
                        .foregroundStyle(isRunning ? Color.orange : Color.white)
                }
                Button("↺") {
                    isRunning = false
                    remaining = minutes * 60
                    temptationCount = 0
                    lastHitCount = store.todaysTotal
                }
                .font(.title3)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .onReceive(timer) { _ in
            guard isRunning else { return }
            remaining -= 1
            let current = store.todaysTotal
            if current > lastHitCount {
                temptationCount += (current - lastHitCount)
                lastHitCount = current
            }
            if remaining <= 0 {
                isRunning = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                remaining = minutes * 60
            }
        }
    }

    private var progress: Double {
        Double(remaining) / Double(minutes * 60)
    }

    private var timeString: String {
        String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }
}