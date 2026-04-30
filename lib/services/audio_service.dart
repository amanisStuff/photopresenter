import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Service for handling audio playback with completion callbacks.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _subscription;
  void Function()? _onComplete;
  Duration? _lastDuration;
  String? _lastPath;

  /// Loads and plays an audio file from a specific position.
  /// Returns the duration of the audio.
  Future<Duration?> playAudio(
    String path, {
    void Function()? onComplete,
    Duration? startPosition,
  }) async {
    await stop();
    _onComplete = onComplete;

    await _player.setSource(DeviceFileSource(path));
    final duration = await _player.getDuration();
    _lastDuration = duration;
    _lastPath = path;

    if (startPosition != null && duration != null && startPosition < duration) {
      await _player.seek(startPosition);
    }

    await _player.resume();

    _subscription = _player.onPlayerComplete.listen((_) {
      _onComplete?.call();
    });

    return duration;
  }

  /// Gets/caches duration of an audio file.
  Future<Duration?> getDuration(String path) async {
    if (_lastPath == path && _lastDuration != null) {
      return _lastDuration;
    }
    final player = AudioPlayer();
    await player.setSource(DeviceFileSource(path));
    final duration = await player.getDuration();
    await player.dispose();
    _lastDuration = duration;
    _lastPath = path;
    return duration;
  }

  /// Gets the last known duration.
  Duration? get lastDuration => _lastDuration;

  /// Stops current playback.
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _player.stop();
  }

  /// Pauses current playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Resumes paused playback.
  Future<void> resume() async {
    await _player.resume();
  }

  /// Checks if audio is currently playing.
  bool get isPlaying => _player.state == PlayerState.playing;

  void dispose() {
    _subscription?.cancel();
    _player.dispose();
  }
}
