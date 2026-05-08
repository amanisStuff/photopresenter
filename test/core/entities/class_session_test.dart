import 'package:flutter_test/flutter_test.dart';
import 'package:photopresenter/core/entities/class_session.dart';
import 'package:photopresenter/core/entities/app_settings.dart';

void main() {
  group('ClassPhase', () {
    test('displayName values are correct', () {
      expect(ClassPhase.warmUp.displayName, equals('Warm-up'));
      expect(ClassPhase.earlyStudy.displayName, equals('Early Study'));
      expect(ClassPhase.midStudy.displayName, equals('Mid Study'));
      expect(ClassPhase.finalStudy.displayName, equals('Final Study'));
      expect(ClassPhase.breakTime.displayName, equals('Break Time'));
    });

    test('defaultDuration values are correct', () {
      expect(ClassPhase.warmUp.defaultDuration, equals(const Duration(seconds: 30)));
      expect(ClassPhase.earlyStudy.defaultDuration, equals(const Duration(minutes: 1)));
      expect(ClassPhase.midStudy.defaultDuration, equals(const Duration(minutes: 5)));
      expect(ClassPhase.finalStudy.defaultDuration, equals(const Duration(minutes: 10)));
      expect(ClassPhase.breakTime.defaultDuration, equals(const Duration(minutes: 3)));
    });
  });

  group('ClassLength', () {
    test('displayName values are correct', () {
      expect(ClassLength.thirtyMinutes.displayName, equals('30 Minutes'));
      expect(ClassLength.sixtyMinutes.displayName, equals('60 Minutes'));
      expect(ClassLength.custom.displayName, equals('Custom'));
    });

    test('totalMinutes values are correct', () {
      expect(ClassLength.thirtyMinutes.totalMinutes, equals(30));
      expect(ClassLength.sixtyMinutes.totalMinutes, equals(60));
      expect(ClassLength.custom.totalMinutes, equals(0));
    });
  });

  group('ClassConfig', () {
    test('fromPreset thirtyMinutes creates correct config', () {
      final config = ClassConfig.fromPreset(ClassLength.thirtyMinutes);

      expect(config.length, equals(ClassLength.thirtyMinutes));
      expect(config.warmUpCount, equals(4));
      expect(config.earlyStudyCount, equals(4));
      expect(config.midStudyCount, equals(2));
      expect(config.finalStudyCount, equals(1));
      expect(config.totalImages, equals(11));
      expect(config.hasBreak, isFalse);
    });

    test('fromPreset sixtyMinutes creates correct config', () {
      final config = ClassConfig.fromPreset(ClassLength.sixtyMinutes);

      expect(config.length, equals(ClassLength.sixtyMinutes));
      expect(config.warmUpCount, equals(6));
      expect(config.earlyStudyCount, equals(6));
      expect(config.midStudyCount, equals(4));
      expect(config.finalStudyCount, equals(2));
      expect(config.totalImages, equals(18));
      expect(config.hasBreak, isTrue);
      expect(config.breakMinutes, equals(5));
      expect(config.breakAfterImage, equals(9));
    });

    test('fromPreset custom creates empty config', () {
      final config = ClassConfig.fromPreset(ClassLength.custom);

      expect(config.length, equals(ClassLength.custom));
      expect(config.totalImages, equals(0));
    });

    test('generatePhaseQueue creates correct number of phases for 30 min', () {
      final config = ClassConfig.fromPreset(ClassLength.thirtyMinutes);
      final queue = config.generatePhaseQueue();

      expect(queue.length, equals(11));
      expect(queue[0], equals(const Duration(seconds: 30)));
      expect(queue[3], equals(const Duration(seconds: 30)));
      expect(queue[4], equals(const Duration(minutes: 1)));
      expect(queue[7], equals(const Duration(minutes: 1)));
      expect(queue[8], equals(const Duration(minutes: 5)));
      expect(queue[9], equals(const Duration(minutes: 5)));
      expect(queue[10], equals(const Duration(minutes: 10)));
    });

    test('generatePhaseQueue creates correct number of phases for 60 min', () {
      final config = ClassConfig.fromPreset(ClassLength.sixtyMinutes);
      final queue = config.generatePhaseQueue();

      expect(queue.length, equals(18));
      for (int i = 0; i < 6; i++) {
        expect(queue[i], equals(const Duration(seconds: 30)));
      }
      for (int i = 6; i < 12; i++) {
        expect(queue[i], equals(const Duration(minutes: 1)));
      }
      for (int i = 12; i < 16; i++) {
        expect(queue[i], equals(const Duration(minutes: 5)));
      }
      for (int i = 16; i < 18; i++) {
        expect(queue[i], equals(const Duration(minutes: 10)));
      }
    });

    test('generatePhaseQueue returns empty for custom config', () {
      final config = ClassConfig.fromPreset(ClassLength.custom);
      expect(config.generatePhaseQueue(), isEmpty);
    });

    test('copyWith creates modified copy', () {
      final original = ClassConfig.fromPreset(ClassLength.thirtyMinutes);
      final modified = original.copyWith(warmUpCount: 10, earlyStudyCount: 5);

      expect(modified.warmUpCount, equals(10));
      expect(modified.earlyStudyCount, equals(5));
      expect(modified.midStudyCount, equals(original.midStudyCount));
      expect(modified.length, equals(ClassLength.thirtyMinutes));
    });

    test('custom config with values generates correct queue', () {
      final config = ClassConfig(
        length: ClassLength.custom,
        warmUpCount: 2,
        earlyStudyCount: 1,
        midStudyCount: 1,
        finalStudyCount: 1,
      );

      expect(config.totalImages, equals(5));
      final queue = config.generatePhaseQueue();
      expect(queue.length, equals(5));
      expect(queue[0], equals(const Duration(seconds: 30)));
      expect(queue[1], equals(const Duration(seconds: 30)));
      expect(queue[2], equals(const Duration(minutes: 1)));
      expect(queue[3], equals(const Duration(minutes: 5)));
      expect(queue[4], equals(const Duration(minutes: 10)));
    });
  });

  group('ClassPresetToConfig', () {
    test('converts ClassPreset to ClassConfig correctly', () {
      const preset = ClassPreset(
        name: 'Custom',
        warmUpCount: 3,
        earlyStudyCount: 3,
        midStudyCount: 2,
        finalStudyCount: 2,
      );

      final config = preset.toConfig();

      expect(config.length, equals(ClassLength.custom));
      expect(config.warmUpCount, equals(3));
      expect(config.earlyStudyCount, equals(3));
      expect(config.midStudyCount, equals(2));
      expect(config.finalStudyCount, equals(2));
      expect(config.totalImages, equals(10));
    });
  });
}
