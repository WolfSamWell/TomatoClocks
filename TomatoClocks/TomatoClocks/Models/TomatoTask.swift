import Foundation
import SwiftData

@Model
final class TomatoTask {
    var id: UUID
    var title: String
    var duration: TimeInterval
    var completedDate: Date?
    var isCompleted: Bool
    
    init(title: String, duration: TimeInterval = 25 * 60) {
        self.id = UUID()
        self.title = title
        self.duration = duration
        self.completedDate = nil
        self.isCompleted = false
    }
}



