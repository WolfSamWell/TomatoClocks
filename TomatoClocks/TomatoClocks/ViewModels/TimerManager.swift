import Combine
import Foundation
import UserNotifications

class TimerManager: ObservableObject {
  @Published var timeRemaining: TimeInterval
  @Published var isRunning: Bool = false
  @Published var progress: Double = 0.0
  @Published var showCompletionModal: Bool = false
  @Published var durationMinutes: Int = 25

  private var timer: AnyCancellable?
  private var totalTime: TimeInterval

  init() {
    let initialTime = TimeInterval(25 * 60)
    self.timeRemaining = initialTime
    self.totalTime = initialTime
  }

  func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      granted, error in
      if granted {
        print("Notification permission granted")
      } else if let error = error {
        print("Notification permission error: \(error.localizedDescription)")
      }
    }
  }

  func start() {
    guard !isRunning else { return }
    isRunning = true

    timer = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.tick()
      }
  }

  func startTest() {
    reset()
    totalTime = 10
    timeRemaining = 10
    start()
  }

  func pause() {
    isRunning = false
    timer?.cancel()
    timer = nil
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }

  func reset() {
    pause()
    totalTime = TimeInterval(durationMinutes * 60)
    timeRemaining = totalTime
    progress = 0.0
  }

  func updateDuration(_ minutes: Int) {
    durationMinutes = minutes
    reset()
  }

  private func tick() {
    if timeRemaining > 0 {
      timeRemaining -= 1
      progress = 1.0 - (timeRemaining / totalTime)
    } else {
      completeTask()
    }
  }

  private func completeTask() {
    pause()
    showCompletionModal = true
    scheduleNotification()
  }

  private func scheduleNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Tomato Clock Finished!"
    content.body = "Great job! Take a break."
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)
  }
}
