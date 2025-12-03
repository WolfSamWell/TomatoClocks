import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tomato_task.dart';
import '../services/task_store.dart';
import '../viewmodels/timer_manager.dart';

class TimerView extends ConsumerStatefulWidget {
  const TimerView({super.key});

  @override
  ConsumerState<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends ConsumerState<TimerView> {
  DateTime? _lastCompletionTap;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timer = ref.read(timerProvider.notifier);
    final timeText = _formatTime(timerState.timeRemaining);
    final progress = timerState.progress.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ProgressRing(
                      progress: progress,
                      timeText: timeText,
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CircleAction(
                          icon: timerState.isRunning
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          color: Colors.red,
                          onPressed: () {
                            if (timerState.isRunning) {
                              timer.pause();
                            } else {
                              timer.start();
                            }
                            HapticFeedback.heavyImpact();
                          },
                        ),
                        const SizedBox(width: 28),
                        _CircleAction(
                          icon: Icons.refresh,
                          color: Colors.grey,
                          onPressed: () {
                            timer.reset();
                            HapticFeedback.heavyImpact();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => _completeTask(timer),
                      child: const Text('Complete Task'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: timer.startTest,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.brown,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Test (10s)'),
                    ),
                  ],
                ),
              ),
            ),
            _CompletionModal(
              visible: timerState.showCompletionModal,
              onDismiss: () {
                timer.dismissCompletionModal();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(TimerNotifier timer) async {
    final now = DateTime.now();
    if (_lastCompletionTap != null &&
        now.difference(_lastCompletionTap!) < const Duration(seconds: 2)) {
      return;
    }
    _lastCompletionTap = now;

    final timerState = ref.read(timerProvider);
    final task = TomatoTask.focusSession(
      durationSeconds: timerState.totalDuration.inSeconds,
    );
    await ref.read(taskStoreProvider.notifier).addTask(task);

    timer.reset();
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  String _formatTime(Duration remaining) {
    final minutes = remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.timeText,
  });

  final double progress;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.65;

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 300),
        builder: (context, animatedValue, _) {
          return CustomPaint(
            painter: _RingPainter(progress: animatedValue),
            child: Center(
              child: Text(
                timeText,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 20) / 2;

    final background = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke;

    final foreground = Paint()
      ..color = Colors.red
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, background);

    final sweep = 2 * math.pi * progress;
    final start = -math.pi / 2; // 12 o'clock
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 40,
      child: Icon(
        icon,
        color: color,
        size: 68,
      ),
    );
  }
}

class _CompletionModal extends StatelessWidget {
  const _CompletionModal({
    required this.visible,
    required this.onDismiss,
  });

  final bool visible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: visible
          ? GestureDetector(
              onTap: onDismiss,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.8,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 72,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Session Complete!',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You're doing great! Keep it up!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: onDismiss,
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
