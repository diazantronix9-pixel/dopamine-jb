import SwiftUI

/// Goal setting, haptics toggle, data export/reset.
struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var showResetConfirm = false
    @State private var showExportAlert = false

    var body: some View {
        Form {
            Section("Meta diaria") {
                Stepper("Dopamines por día: \(store.dailyGoal)", value: $store.dailyGoal, in: 1...20)
            }

            Section("Haptics") {
                Toggle("Vibrar al registrar", isOn: $store.haptics)
            }

            Section("Datos") {
                Button { showExportAlert = true } label: {
                    Label("Exportar datos", systemImage: "square.and.arrow.up")
                }
                .tint(.orange)

                Button(role: .destructive) { showResetConfirm = true } label: {
                    Label("Borrar todo", systemImage: "trash")
                }
            }

            Section {
                Text("Dopamine — tu tracker de hitos dopaminérgicos.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .confirmationDialog("¿Borrar todo?", isPresented: $showResetConfirm) {
            Button("Borrar", role: .destructive) { store.hits.removeAll(); store.save() }
        }
        .alert("Datos exportados", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text("Hoy: \(store.todaysTotal) · Total: \(store.totalAllTime) · Racha: \(store.bestStreak)")
        }
    }
}