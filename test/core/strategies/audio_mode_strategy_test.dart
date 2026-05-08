import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopresenter/core/strategies/audio_mode_strategy.dart';
import 'package:photopresenter/infrastructure/services/audio_service.dart';

class FakeAudioService extends AudioService {
  String? _playedPath;
  void Function()? _onComplete;

  @override
  Future<Duration?> getDuration(String path) async {
    if (path == 'short.mp3') return const Duration(seconds: 10);
    if (path == 'long.mp3') return const Duration(seconds: 60);
    return null;
  }

  @override
  Future<Duration?> playAudio(
    String path, {
    void Function()? onComplete,
    Duration? startPosition,
  }) async {
    _playedPath = path;
    _onComplete = onComplete;
    return const Duration(seconds: 30);
  }

  void triggerComplete() => _onComplete?.call();

  String? get playedPath => _playedPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall call) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall call) async {
        if (call.method == 'create') return 'player-id';
        return null;
      },
    );
  });

  group('AudioDrivenStrategy', () {
    test('timerAdvancesImage is false', () {
      const strategy = AudioDrivenStrategy();
      expect(strategy.timerAdvancesImage, isFalse);
    });

    test('startAudio plays audio and returns duration', () async {
      const strategy = AudioDrivenStrategy();
      final audio = FakeAudioService();
      bool audioEnded = false;

      final duration = await strategy.startAudio(
        audio,
        'short.mp3',
        onAudioEnd: () => audioEnded = true,
        timerDuration: const Duration(seconds: 30),
      );

      expect(duration, equals(const Duration(seconds: 10)));
      expect(audio.playedPath, equals('short.mp3'));
    });

    test('startAudio triggers onComplete callback', () async {
      const strategy = AudioDrivenStrategy();
      final audio = FakeAudioService();
      bool audioEnded = false;

      await strategy.startAudio(
        audio,
        'short.mp3',
        onAudioEnd: () => audioEnded = true,
        timerDuration: const Duration(seconds: 30),
      );

      audio.triggerComplete();
      expect(audioEnded, isTrue);
    });
  });

  group('TimerDrivenStrategy', () {
    test('timerAdvancesImage is true', () {
      const strategy = TimerDrivenStrategy();
      expect(strategy.timerAdvancesImage, isTrue);
    });

    test('startAudio with short audio (within timer) plays with onComplete', () async {
      const strategy = TimerDrivenStrategy();
      final audio = FakeAudioService();
      bool audioEnded = false;

      await strategy.startAudio(
        audio,
        'short.mp3',
        onAudioEnd: () => audioEnded = true,
        timerDuration: const Duration(seconds: 30),
      );

      expect(audio.playedPath, equals('short.mp3'));
      audio.triggerComplete();
      expect(audioEnded, isTrue);
    });

    test('startAudio with long audio (exceeds timer) plays without onComplete', () async {
      const strategy = TimerDrivenStrategy();
      final audio = FakeAudioService();
      bool audioEnded = false;

      await strategy.startAudio(
        audio,
        'long.mp3',
        onAudioEnd: () => audioEnded = true,
        timerDuration: const Duration(seconds: 30),
      );

      expect(audio.playedPath, equals('long.mp3'));
    });

    test('startAudio returns null when duration cannot be determined', () async {
      const strategy = TimerDrivenStrategy();
      final audio = FakeAudioService();

      final duration = await strategy.startAudio(
        audio,
        'nonexistent.mp3',
        onAudioEnd: () {},
        timerDuration: const Duration(seconds: 30),
      );

      expect(duration, isNull);
    });
  });

  group('AudioModeStrategy sealed class', () {
    test('both strategies are subtypes of AudioModeStrategy', () {
      const audioDriven = AudioDrivenStrategy();
      const timerDriven = TimerDrivenStrategy();

      expect(audioDriven, isA<AudioModeStrategy>());
      expect(timerDriven, isA<AudioModeStrategy>());
    });
  });
}
