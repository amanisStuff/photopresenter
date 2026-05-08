import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopresenter/core/providers/settings_provider.dart';
import 'package:photopresenter/core/entities/app_settings.dart';

void main() {
  group('SettingsNotifier', () {
    test('initial state has default values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);

      expect(settings.timerDurationSeconds, equals(30));
      expect(settings.audioMode, equals(AudioMode.audioDriven));
      expect(settings.customClassPresets, isEmpty);
    });

    test('setTimerDuration updates timer duration', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setTimerDuration(60);
      final settings = container.read(settingsProvider);

      expect(settings.timerDurationSeconds, equals(60));
    });

    test('setAutoPlayAudio toggles auto play', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setAutoPlayAudio(false);
      expect(container.read(settingsProvider).autoPlayAudio, isFalse);

      container.read(settingsProvider.notifier).setAutoPlayAudio(true);
      expect(container.read(settingsProvider).autoPlayAudio, isTrue);
    });

    test('setSoundOnTransition toggles sound', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setSoundOnTransition(true);
      expect(container.read(settingsProvider).soundOnTransition, isTrue);
    });

    test('setTransitionSoundPath updates path', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setTransitionSoundPath('/path/sound.wav');
      expect(container.read(settingsProvider).transitionSoundPath, equals('/path/sound.wav'));
    });

    test('setTransitionSoundPath can clear a previously set path', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setTransitionSoundPath(null);
      expect(container.read(settingsProvider).transitionSoundPath, isNull);
    });

    test('setDefaultVolume updates volume', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setDefaultVolume(0.5);
      expect(container.read(settingsProvider).defaultVolume, equals(0.5));
    });

    test('setShowImageInfo toggles image info', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setShowImageInfo(false);
      expect(container.read(settingsProvider).showImageInfo, isFalse);
    });

    test('setConfirmOnClose toggles confirm on close', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setConfirmOnClose(true);
      expect(container.read(settingsProvider).confirmOnClose, isTrue);
    });

    test('addCustomClassPreset adds preset to list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const preset = ClassPreset(name: 'Custom 1', warmUpCount: 5);
      container.read(settingsProvider.notifier).addCustomClassPreset(preset);

      final presets = container.read(settingsProvider).customClassPresets;
      expect(presets.length, equals(1));
      expect(presets.first.name, equals('Custom 1'));
    });

    test('updateCustomClassPreset modifies existing preset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const preset1 = ClassPreset(name: 'A', warmUpCount: 2);
      const preset2 = ClassPreset(name: 'B', warmUpCount: 3);
      container.read(settingsProvider.notifier).addCustomClassPreset(preset1);
      container.read(settingsProvider.notifier).addCustomClassPreset(preset2);

      const updated = ClassPreset(name: 'B Updated', warmUpCount: 10);
      container.read(settingsProvider.notifier).updateCustomClassPreset(1, updated);

      final presets = container.read(settingsProvider).customClassPresets;
      expect(presets.length, equals(2));
      expect(presets[1].name, equals('B Updated'));
      expect(presets[1].warmUpCount, equals(10));
    });

    test('updateCustomClassPreset with invalid index does nothing', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const preset = ClassPreset(name: 'A');
      container.read(settingsProvider.notifier).addCustomClassPreset(preset);

      const updated = ClassPreset(name: 'B');
      container.read(settingsProvider.notifier).updateCustomClassPreset(5, updated);

      expect(container.read(settingsProvider).customClassPresets.length, equals(1));
    });

    test('removeCustomClassPreset removes preset at index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const preset1 = ClassPreset(name: 'A');
      const preset2 = ClassPreset(name: 'B');
      container.read(settingsProvider.notifier).addCustomClassPreset(preset1);
      container.read(settingsProvider.notifier).addCustomClassPreset(preset2);

      container.read(settingsProvider.notifier).removeCustomClassPreset(0);

      final presets = container.read(settingsProvider).customClassPresets;
      expect(presets.length, equals(1));
      expect(presets.first.name, equals('B'));
    });

    test('removeCustomClassPreset with invalid index does nothing', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const preset = ClassPreset(name: 'A');
      container.read(settingsProvider.notifier).addCustomClassPreset(preset);

      container.read(settingsProvider.notifier).removeCustomClassPreset(5);

      expect(container.read(settingsProvider).customClassPresets.length, equals(1));
    });

    test('setAudioMode switches between modes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setAudioMode(AudioMode.timerDriven);
      expect(container.read(settingsProvider).audioMode, equals(AudioMode.timerDriven));

      container.read(settingsProvider.notifier).setAudioMode(AudioMode.audioDriven);
      expect(container.read(settingsProvider).audioMode, equals(AudioMode.audioDriven));
    });

    test('resetToDefaults restores all defaults', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setTimerDuration(120);
      container.read(settingsProvider.notifier).setSoundOnTransition(true);
      container.read(settingsProvider.notifier).setAudioMode(AudioMode.timerDriven);

      container.read(settingsProvider.notifier).resetToDefaults();

      final settings = container.read(settingsProvider);
      expect(settings.timerDurationSeconds, equals(30));
      expect(settings.soundOnTransition, isFalse);
      expect(settings.audioMode, equals(AudioMode.audioDriven));
    });
  });
}
