import SwiftUI
import SwiftData

struct TaskListView: View {
    @Query(sort: \TomatoTask.completedDate, order: .reverse) private var tasks: [TomatoTask]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                HStack {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)
                        if let date = task.completedDate {
                            Text(date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("History")
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(tasks[index])
            }
        }
    }
}
