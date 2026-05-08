import 'package:flutter_test/flutter_test.dart';
import 'package:photopresenter/core/entities/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('default values are correct', () {
      const settings = AppSettings();

      expect(settings.timerDurationSeconds, equals(30));
      expect(settings.autoPlayAudio, isTrue);
      expect(settings.soundOnTransition, isFalse);
      expect(settings.transitionSoundPath, isNull);
      expect(settings.defaultVolume, equals(1.0));
      expect(settings.showImageInfo, isTrue);
      expect(settings.confirmOnClose, isFalse);
      expect(settings.customClassPresets, isEmpty);
      expect(settings.audioMode, equals(AudioMode.audioDriven));
    });

    test('copyWith updates only specified fields', () {
      const original = AppSettings(
        timerDurationSeconds: 30,
        autoPlayAudio: false,
        defaultVolume: 0.5,
      );

      final modified = original.copyWith(
        timerDurationSeconds: 60,
        defaultVolume: 0.8,
      );

      expect(modified.timerDurationSeconds, equals(60));
      expect(modified.defaultVolume, equals(0.8));
      expect(modified.autoPlayAudio, isFalse);
      expect(modified.soundOnTransition, isFalse);
    });

    test('copyWith with no arguments returns equal object', () {
      const original = AppSettings(timerDurationSeconds: 60);
      final copied = original.copyWith();

      expect(copied.timerDurationSeconds, equals(60));
    });

    test('timerOptions contains expected values', () {
      expect(
        AppSettings.timerOptions,
        equals([5, 10, 15, 30, 60, 120, 300, 600]),
      );
    });

    test('audioMode can be set to timerDriven', () {
      const settings = AppSettings(audioMode: AudioMode.timerDriven);
      expect(settings.audioMode, equals(AudioMode.timerDriven));
    });

    test('customClassPresets are stored correctly', () {
      const preset = ClassPreset(name: 'Test', warmUpCount: 3);
      const settings = AppSettings(customClassPresets: [preset]);

      expect(settings.customClassPresets.length, equals(1));
      expect(settings.customClassPresets.first.name, equals('Test'));
    });
  });

  group('AudioMode', () {
    test('audioDriven displayName is correct', () {
      expect(AudioMode.audioDriven.displayName, equals('Audio Driven'));
    });

    test('timerDriven displayName is correct', () {
      expect(AudioMode.timerDriven.displayName, equals('Timer Driven'));
    });

    test('audioDriven description mentions audio end', () {
      expect(
        AudioMode.audioDriven.description,
        contains('audio ends'),
      );
    });

    test('timerDriven description mentions timer end', () {
      expect(
        AudioMode.timerDriven.description,
        contains('timer ends'),
      );
    });
  });

  group('ClassPreset', () {
    test('default values are correct', () {
      const preset = ClassPreset(name: 'Test');

      expect(preset.name, equals('Test'));
      expect(preset.warmUpCount, equals(0));
      expect(preset.earlyStudyCount, equals(0));
      expect(preset.midStudyCount, equals(0));
      expect(preset.finalStudyCount, equals(0));
      expect(preset.hasBreak, isFalse);
      expect(preset.breakMinutes, equals(3));
      expect(preset.breakAfterImage, equals(0));
    });

    test('totalImages sums all counts', () {
      const preset = ClassPreset(
        name: 'Test',
        warmUpCount: 4,
        earlyStudyCount: 4,
        midStudyCount: 2,
        finalStudyCount: 1,
      );

      expect(preset.totalImages, equals(11));
    });

    test('totalImages with zero counts returns zero', () {
      const preset = ClassPreset(name: 'Empty');
      expect(preset.totalImages, equals(0));
    });

    test('copyWith creates modified copy', () {
      const original = ClassPreset(name: 'Original', warmUpCount: 2);
      final modified = original.copyWith(name: 'Modified', warmUpCount: 5);

      expect(modified.name, equals('Modified'));
      expect(modified.warmUpCount, equals(5));
      expect(modified.earlyStudyCount, equals(original.earlyStudyCount));
    });

    test('defaultPresets contains 30 Min and 60 Min', () {
      expect(ClassPreset.defaultPresets.length, equals(2));
      expect(ClassPreset.defaultPresets[0].name, equals('30 Min'));
      expect(ClassPreset.defaultPresets[1].name, equals('60 Min'));
    });

    test('30 Min preset has correct values', () {
      final preset = ClassPreset.defaultPresets[0];

      expect(preset.warmUpCount, equals(4));
      expect(preset.earlyStudyCount, equals(4));
      expect(preset.midStudyCount, equals(2));
      expect(preset.finalStudyCount, equals(1));
      expect(preset.totalImages, equals(11));
      expect(preset.hasBreak, isFalse);
    });

    test('60 Min preset has break configured', () {
      final preset = ClassPreset.defaultPresets[1];

      expect(preset.warmUpCount, equals(6));
      expect(preset.earlyStudyCount, equals(6));
      expect(preset.midStudyCount, equals(4));
      expect(preset.finalStudyCount, equals(2));
      expect(preset.totalImages, equals(18));
      expect(preset.hasBreak, isTrue);
      expect(preset.breakMinutes, equals(5));
      expect(preset.breakAfterImage, equals(9));
    });
  });

  group('ClassPresetBuilder', () {
    test('builds ClassPreset with default values', () {
      final preset = ClassPresetBuilder().build();

      expect(preset.name, equals('Custom'));
      expect(preset.warmUpCount, equals(0));
      expect(preset.hasBreak, isFalse);
    });

    test('builds ClassPreset with custom values', () {
      final preset = ClassPresetBuilder()
          .setName('My Preset')
          .setWarmUpCount(5)
          .setEarlyStudyCount(3)
          .setMidStudyCount(2)
          .setFinalStudyCount(1)
          .setHasBreak(true)
          .setBreakMinutes(10)
          .setBreakAfterImage(7)
          .build();

      expect(preset.name, equals('My Preset'));
      expect(preset.warmUpCount, equals(5));
      expect(preset.earlyStudyCount, equals(3));
      expect(preset.midStudyCount, equals(2));
      expect(preset.finalStudyCount, equals(1));
      expect(preset.totalImages, equals(11));
      expect(preset.hasBreak, isTrue);
      expect(preset.breakMinutes, equals(10));
      expect(preset.breakAfterImage, equals(7));
    });

    test('builder methods return this for chaining', () {
      final builder = ClassPresetBuilder();
      expect(builder.setName('Test'), same(builder));
      expect(builder.setWarmUpCount(1), same(builder));
      expect(builder.setHasBreak(true), same(builder));
    });
  });
}
