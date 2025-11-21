import SwiftUI

struct ContentView: View {
  @StateObject private var timerManager = TimerManager()
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    TabView {
      TimerView()
        .tabItem {
          Label("Timer", systemImage: "timer")
        }

      NavigationView {
        TaskListView()
      }
      .tabItem {
        Label("History", systemImage: "list.bullet")
      }

      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
    .environmentObject(timerManager)
    .onChange(of: colorScheme) { newScheme in
      print("Theme changed to: \(newScheme == .dark ? "Dark" : "Light")")
      // Uncomment the line below if you have configured Info.plist for manual switching
      // IconManager.shared.updateAppIcon(for: newScheme)
    }
  }
}
