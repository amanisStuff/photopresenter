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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDisabled
                ? [const Color(0xFFC0C0C0), const Color(0xFFD8D8D8)]
                : [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF808080), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
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
