import SwiftData
import SwiftUI

struct TimerView: View {
  @EnvironmentObject private var timerManager: TimerManager
  @Environment(\.modelContext) private var modelContext
  @State private var lastCompletionTime: Date?

  var body: some View {
    VStack(spacing: 40) {
      ZStack {
        Circle()
          .stroke(lineWidth: 20)
          .opacity(0.3)
          .foregroundColor(.secondary)

        Circle()
          .trim(from: 0.0, to: CGFloat(min(timerManager.progress, 1.0)))
          .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
          .foregroundColor(.red)
          .rotationEffect(Angle(degrees: 270.0))
          .animation(.linear, value: timerManager.progress)

        Text(formatTime(timerManager.timeRemaining))
          .font(.system(size: 60, weight: .bold, design: .monospaced))
      }
      .padding(40)

      HStack(spacing: 30) {
        Button(action: {
          if timerManager.isRunning {
            timerManager.pause()
            impact(style: .heavy)  // Max vibration
          } else {
            timerManager.start()
            impact(style: .heavy)  // Max vibration
          }
        }) {
          Image(systemName: timerManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
            .resizable()
            .frame(width: 60, height: 60)
            .foregroundColor(.red)
        }

        Button(action: {
          timerManager.reset()
          impact(style: .heavy)  // Max vibration
        }) {
          Image(systemName: "arrow.counterclockwise.circle.fill")
            .resizable()
            .frame(width: 60, height: 60)
            .foregroundColor(.secondary)
        }
      }

      Button("Complete Task") {
        let now = Date()
        if let lastTime = lastCompletionTime, now.timeIntervalSince(lastTime) < 2.0 {
          return
        }
        lastCompletionTime = now
        saveTask()
        timerManager.reset()
        notificationFeedback(type: .success)  // Success pattern is distinct and strong
        impact(style: .heavy)  // Adding heavy impact for extra strength
      }
      .buttonStyle(.borderedProminent)
      .tint(.green)

      Button("Test (10s)") {
        timerManager.startTest()
      }
      .font(.caption)
      .foregroundColor(.secondary)
      .padding(.top, 10)
    }
    .padding()
    .overlay {
      if timerManager.showCompletionModal {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture {
            withAnimation {
              timerManager.showCompletionModal = false
              timerManager.reset()
            }
          }

        VStack(spacing: 20) {
          Image(systemName: "trophy.fill")
            .font(.system(size: 60))
            .foregroundStyle(
              LinearGradient(
                colors: [.yellow, .orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .padding(.bottom, 10)

          Text("Session Complete!")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.primary)

          Text("You're doing great! Keep it up!")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)

          Button(action: {
            withAnimation {
              timerManager.showCompletionModal = false
              timerManager.reset()
            }
          }) {
            Text("Continue")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(15)
          }
          .padding(.top, 10)
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(radius: 20)
        .padding(40)
        .transition(.scale.combined(with: .opacity))
      }
    }
    .animation(
      .spring(response: 0.4, dampingFraction: 0.7), value: timerManager.showCompletionModal)
  }

  private func formatTime(_ totalSeconds: TimeInterval) -> String {
    let minutes = Int(totalSeconds) / 60
    let seconds = Int(totalSeconds) % 60
    return String(format: "%02d:%02d", minutes, seconds)
  }

  private func saveTask() {
    let task = TomatoTask(title: "Focus Session", duration: 25 * 60)
    task.isCompleted = true
    task.completedDate = Date()
    modelContext.insert(task)
  }

  private func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
  }

  private func notificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
  }
}
