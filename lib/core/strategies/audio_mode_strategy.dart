import 'package:flutter/foundation.dart';
import '../../infrastructure/services/audio_service.dart';

sealed class AudioModeStrategy {
  const AudioModeStrategy();

  bool get timerAdvancesImage;

  Future<Duration?> startAudio(
    AudioService audio,
    String path, {
    required VoidCallback onAudioEnd,
    required Duration timerDuration,
  });
}

class AudioDrivenStrategy extends AudioModeStrategy {
  const AudioDrivenStrategy();

  @override
  bool get timerAdvancesImage => false;

  @override
  Future<Duration?> startAudio(
    AudioService audio,
    String path, {
    required VoidCallback onAudioEnd,
    required Duration timerDuration,
  }) async {
    final duration = await audio.getDuration(path);
    if (duration == null) return null;
    audio.playAudio(path, onComplete: onAudioEnd);
    return duration;
  }
}

class TimerDrivenStrategy extends AudioModeStrategy {
  const TimerDrivenStrategy();

  @override
  bool get timerAdvancesImage => true;

  @override
  Future<Duration?> startAudio(
    AudioService audio,
    String path, {
    required VoidCallback onAudioEnd,
    required Duration timerDuration,
  }) async {
    final duration = await audio.getDuration(path);
    if (duration == null) return null;
    if (duration <= timerDuration) {
      audio.playAudio(path, onComplete: onAudioEnd);
    } else {
      audio.playAudio(path);
    }
    return duration;
  }
}
