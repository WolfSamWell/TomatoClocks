import 'package:uuid/uuid.dart';

class TomatoTask {
  final String id;
  final String title;
  final int durationSeconds;
  final DateTime? completedDate;
  final bool isCompleted;

  TomatoTask({
    required this.id,
    required this.title,
    required this.durationSeconds,
    this.completedDate,
    this.isCompleted = false,
  });

  factory TomatoTask.focusSession({required int durationSeconds}) {
    return TomatoTask(
      id: const Uuid().v4(),
      title: 'Focus Session',
      durationSeconds: durationSeconds,
      completedDate: DateTime.now(),
      isCompleted: true,
    );
  }

  TomatoTask copyWith({
    String? id,
    String? title,
    int? durationSeconds,
    DateTime? completedDate,
    bool? isCompleted,
  }) {
    return TomatoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'durationSeconds': durationSeconds,
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TomatoTask.fromJson(Map<String, dynamic> json) {
    return TomatoTask(
      id: json['id'] as String,
      title: json['title'] as String,
      durationSeconds: json['durationSeconds'] as int,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
