import SwiftUI

struct PreferencesView: View {
    @AppStorage("maxHistoryItems") private var maxHistoryItems = 1000
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    
    var body: some View {
        Form {
            Section("History") {
                Stepper("Maximum items: \(maxHistoryItems)", value: $maxHistoryItems, in: 100...5000, step: 100)
                
                Button("Clear All History") {
                    // Clear history
                }
                .foregroundColor(.red)
            }
            
            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                
                Text("Hotkey: Cmd+Shift+V")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
