import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var timerManager: TimerManager
  @State private var showDurationPicker = false

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Timer")) {
          Button(action: {
            withAnimation {
              showDurationPicker = true
            }
          }) {
            HStack {
              Label("Focus Duration", systemImage: "clock.fill")
                .foregroundColor(.primary)
              Spacer()
              Text("\(timerManager.durationMinutes) min")
                .foregroundColor(.secondary)
              Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
            }
          }
        }
      }
      .navigationTitle("Settings")
      .overlay {
        if showDurationPicker {
          Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
              withAnimation {
                showDurationPicker = false
              }
            }

          VStack(spacing: 25) {
            HStack {
              Text("Focus Duration")
                .font(.title2)
                .fontWeight(.bold)
              Spacer()
            }

            Picker(
              "Duration",
              selection: Binding(
                get: { timerManager.durationMinutes },
                set: { timerManager.updateDuration($0) }
              )
            ) {
              ForEach(1...99, id: \.self) { minute in
                Text("\(minute) min").tag(minute)
              }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)

            Button(action: {
              withAnimation {
                showDurationPicker = false
              }
            }) {
              Text("Done")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
            }
          }
          .padding(30)
          .background(.ultraThinMaterial)
          .cornerRadius(25)
          .shadow(radius: 20)
          .padding(40)
          .transition(.scale.combined(with: .opacity))
        }
      }
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showDurationPicker)
    }
  }
}

#Preview {
  SettingsView()
    .environmentObject(TimerManager())
}
