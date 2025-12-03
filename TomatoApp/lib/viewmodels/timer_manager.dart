import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_service.dart';

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);

class TimerState {
  const TimerState({
    required this.totalDuration,
    required this.timeRemaining,
    required this.isRunning,
    required this.showCompletionModal,
    required this.durationMinutes,
  });

  final Duration totalDuration;
  final Duration timeRemaining;
  final bool isRunning;
  final bool showCompletionModal;
  final int durationMinutes;

  double get progress {
    if (totalDuration.inSeconds == 0) return 0;
    return 1 - (timeRemaining.inSeconds / totalDuration.inSeconds);
  }

  TimerState copyWith({
    Duration? totalDuration,
    Duration? timeRemaining,
    bool? isRunning,
    bool? showCompletionModal,
    int? durationMinutes,
  }) {
    return TimerState(
      totalDuration: totalDuration ?? this.totalDuration,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isRunning: isRunning ?? this.isRunning,
      showCompletionModal: showCompletionModal ?? this.showCompletionModal,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;

  NotificationService get _notificationService =>
      ref.read(notificationServiceProvider);

  @override
  TimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    const initialMinutes = 25;
    return TimerState(
      totalDuration: const Duration(minutes: initialMinutes),
      timeRemaining: const Duration(minutes: initialMinutes),
      isRunning: false,
      showCompletionModal: false,
      durationMinutes: initialMinutes,
    );
  }

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    state = state.copyWith(isRunning: false);
    _ticker?.cancel();
    _ticker = null;
  }

  void reset() {
    pause();
    final total = Duration(minutes: state.durationMinutes);
    state = state.copyWith(
      totalDuration: total,
      timeRemaining: total,
      showCompletionModal: false,
    );
  }

  void updateDuration(int minutes) {
    state = state.copyWith(durationMinutes: minutes);
    reset();
  }

  void startTest() {
    pause();
    const total = Duration(seconds: 10);
    state = state.copyWith(
      totalDuration: total,
      timeRemaining: total,
      showCompletionModal: false,
    );
    start();
  }

  void dismissCompletionModal() {
    state = state.copyWith(showCompletionModal: false);
    reset();
  }

  void _tick() {
    if (state.timeRemaining.inSeconds > 0) {
      final nextRemaining = state.timeRemaining - const Duration(seconds: 1);
      state = state.copyWith(timeRemaining: nextRemaining);
      if (nextRemaining.inSeconds == 0) {
        _completeTask();
      }
    } else {
      _completeTask();
    }
  }

  void _completeTask() {
    pause();
    state = state.copyWith(
      timeRemaining: Duration.zero,
      showCompletionModal: true,
    );
    _notificationService.showCompletionNotification();
  }
}
