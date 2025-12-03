import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/timer_manager.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _showDurationPicker = false;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timer = ref.read(timerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Focus Duration'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${timerState.durationMinutes} min'),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => setState(() => _showDurationPicker = true),
              ),
            ],
          ),
          if (_showDurationPicker)
            GestureDetector(
              onTap: () => setState(() => _showDurationPicker = false),
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Focus Duration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: timerState.durationMinutes - 1,
                            ),
                            itemExtent: 36,
                            onSelectedItemChanged: (index) {
                              timer.updateDuration(index + 1);
                            },
                            children: List.generate(
                              99,
                              (index) => Center(
                                child: Text('${index + 1} min'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () =>
                                setState(() => _showDurationPicker = false),
                            child: const Text('Done'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
