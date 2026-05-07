import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/presentation_provider.dart';
import '../../core/entities/app_settings.dart';

class AudioModeToggle extends ConsumerWidget {
  const AudioModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final state = ref.watch(presentationProvider);
    final isTimerDriven = settings.audioMode == AudioMode.timerDriven;
    final isDisabled = state.isPlaying;

    return Tooltip(
      message: isTimerDriven
          ? 'Timer Driven: Audio starts randomly'
          : 'Audio Driven: Image changes when audio ends',
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                final notifier = ref.read(settingsProvider.notifier);
                notifier.setAudioMode(
                  isTimerDriven ? AudioMode.audioDriven : AudioMode.timerDriven,
                );
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDisabled
                  ? [const Color(0xFFC0C0C0), const Color(0xFFD8D8D8)]
                  : (isTimerDriven
                        ? [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0)]
                        : [AppTheme.xpGreen, AppTheme.xpGreenDark]),
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFF808080)
                  : (isTimerDriven ? const Color(0xFF808080) : AppTheme.xpGreenDark),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            isTimerDriven ? 'TMR' : 'AUD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDisabled
                  ? AppTheme.textOnSilver.withValues(alpha: 0.4)
                  : (isTimerDriven ? AppTheme.textOnSilver : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
