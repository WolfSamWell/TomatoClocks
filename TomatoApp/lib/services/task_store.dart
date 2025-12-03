import 'dart:convert';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tomato_task.dart';

final taskStoreProvider =
    AsyncNotifierProvider<TaskStoreNotifier, List<TomatoTask>>(
  TaskStoreNotifier.new,
);

class TaskStoreNotifier extends AsyncNotifier<List<TomatoTask>> {
  static const _storageKey = 'tomato_tasks';
  SharedPreferences? _prefs;

  @override
  FutureOr<List<TomatoTask>> build() async {
    await _ensurePrefsLoaded();
    final saved = _prefs!.getStringList(_storageKey) ?? [];
    final parsedTasks = saved.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return TomatoTask.fromJson(map);
    }).toList();

    final fallbackDate = DateTime.fromMillisecondsSinceEpoch(0);
    parsedTasks.sort((a, b) {
      final left = a.completedDate ?? fallbackDate;
      final right = b.completedDate ?? fallbackDate;
      return right.compareTo(left);
    });

    return parsedTasks;
  }

  Future<void> addTask(TomatoTask task) async {
    await _ensurePrefsLoaded();
    final current = state.valueOrNull ?? [];
    final updated = [task, ...current];
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> deleteTask(String id) async {
    await _ensurePrefsLoaded();
    final current = state.valueOrNull ?? [];
    final updated = current.where((task) => task.id != id).toList();
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> _persist(List<TomatoTask> tasks) async {
    final serialized = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs!.setStringList(_storageKey, serialized);
  }

  Future<void> _ensurePrefsLoaded() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
