import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/task_store.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskStoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: tasksAsync.when(
        data: (tasks) => tasks.isEmpty
            ? const Center(child: Text('No history yet'))
            : ListView.separated(
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final subtitle = task.completedDate != null
                      ? DateFormat('yMMMd HH:mm').format(task.completedDate!)
                      : null;

                  return Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) =>
                        ref.read(taskStoreProvider.notifier).deleteTask(task.id),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: subtitle != null ? Text(subtitle) : null,
                      trailing: task.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: tasks.length,
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Failed to load: $err'),
        ),
      ),
    );
  }
}
