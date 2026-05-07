import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../entities/app_settings.dart';
import 'audio_mode_strategy.dart';

final audioModeStrategyProvider = Provider<AudioModeStrategy>((ref) {
  final settings = ref.watch(settingsProvider);
  return switch (settings.audioMode) {
    AudioMode.audioDriven => const AudioDrivenStrategy(),
    AudioMode.timerDriven => const TimerDrivenStrategy(),
  };
});
