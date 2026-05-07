import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';

class TimerAdjustment extends ConsumerWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const TimerAdjustment({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final isDisabled = state.isPlaying;

    return PopupMenuButton<int>(
      initialValue: value,
      tooltip: 'Set timer duration',
      enabled: !isDisabled,
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: AppTheme.xpControlButton(disabled: isDisabled),
        child: Text(
          '${value}s',
          style: TextStyle(
            color: isDisabled
                ? AppTheme.textOnSilver.withValues(alpha: 0.4)
                : AppTheme.textOnSilver,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 5, child: Text('5 seconds')),
        const PopupMenuItem(value: 10, child: Text('10 seconds')),
        const PopupMenuItem(value: 30, child: Text('30 seconds')),
        const PopupMenuItem(value: 60, child: Text('1 minute')),
        const PopupMenuItem(value: 300, child: Text('5 minutes')),
      ],
    );
  }
}
