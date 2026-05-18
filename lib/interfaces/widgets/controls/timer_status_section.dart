import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/entities/app_settings.dart';
import 'audio_mode_toggle.dart';
import 'timer_adjustment.dart';
import 'class_mode_button.dart';
import 'class_mode_dialog.dart';

class TimerStatusSection extends ConsumerWidget {
  const TimerStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (state.hasAudio) ...[
              Icon(
                Icons.audiotrack,
                size: 16,
                color: state.isPlaying ? AppTheme.success : AppTheme.surfaceMuted,
              ),
              const AudioModeToggle(),
            ],
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: state.isPlaying ? AppTheme.primary : AppTheme.surfaceMuted,
            ),
            Builder(
              builder: (context) {
                final settings = ref.watch(settingsProvider);
                final isAudioDrivenMode =
                    settings.audioMode == AudioMode.audioDriven;

                final bool shouldShowAudioCountdown =
                    state.hasAudio &&
                    state.isPlaying &&
                    state.audioDuration.inSeconds > 0 &&
                    (isAudioDrivenMode || state.isClassMode);

                final int remainingTimerSeconds = shouldShowAudioCountdown
                    ? (state.audioDuration.inSeconds -
                          state.audioPosition.inSeconds)
                    : state.remainingTime.inSeconds;

                final bool isLowRemainingTime =
                    !shouldShowAudioCountdown && remainingTimerSeconds <= 5;

                return Text(
                  state.isPaused
                      ? '${remainingTimerSeconds}s (Paused)'
                      : '${remainingTimerSeconds}s',
                  style: AppTheme.timerDisplayStyle.copyWith(
                    color: shouldShowAudioCountdown
                        ? AppTheme.success
                        : (isLowRemainingTime ? AppTheme.error : AppTheme.onSurface),
                  ),
                );
              },
            ),
            if (state.isPlaying)
              Builder(
                builder: (context) {
                  final settings = ref.watch(settingsProvider);
                  final isAudioDrivenMode =
                      settings.audioMode == AudioMode.audioDriven;
                  final shouldShowAudioProgress =
                      state.hasAudio &&
                      state.audioDuration.inMilliseconds > 0 &&
                      (isAudioDrivenMode || state.isClassMode);

                  final double currentProgress = shouldShowAudioProgress
                      ? (state.audioDuration.inMilliseconds > 0
                            ? (state.audioDuration.inMilliseconds -
                                      state
                                          .audioPosition
                                          .inMilliseconds) /
                                  state.audioDuration.inMilliseconds
                            : 0.0)
                      : (state.timerDuration.inMilliseconds > 0
                            ? state.remainingTime.inMilliseconds /
                                  state.timerDuration.inMilliseconds
                            : 0.0);

                  return SizedBox(
                    width: double.infinity,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: currentProgress,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation(
                          shouldShowAudioProgress
                              ? AppTheme.success
                              : (state.remainingTime.inSeconds <= 5
                                    ? AppTheme.error
                                    : AppTheme.success),
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (!state.isClassMode)
              TimerAdjustment(
                value: state.timerDuration.inSeconds,
                onChanged: (value) =>
                    ref.read(presentationProvider.notifier).setTimerDuration(Duration(seconds: value)),
              ),
            if (state.isClassMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${state.timerDuration.inSeconds}s',
                  style: AppTheme.timerValueStyle,
                ),
              ),
            ClassModeButton(
              isActive: state.isClassMode,
              onStart: () => showClassModeDialog(context, ref),
              onStop: () => ref.read(presentationProvider.notifier).stopClassMode(),
            ),
          ],
        ),
      ],
    );
  }
}
