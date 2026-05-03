import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  void setTimerDuration(int seconds) {
    state = state.copyWith(timerDurationSeconds: seconds);
  }

  void setAutoPlayAudio(bool value) {
    state = state.copyWith(autoPlayAudio: value);
  }

  void setSoundOnTransition(bool value) {
    state = state.copyWith(soundOnTransition: value);
  }

  void setTransitionSoundPath(String? path) {
    state = state.copyWith(transitionSoundPath: path);
  }

  void setDefaultVolume(double value) {
    state = state.copyWith(defaultVolume: value);
  }

  void setShowImageInfo(bool value) {
    state = state.copyWith(showImageInfo: value);
  }

  void setConfirmOnClose(bool value) {
    state = state.copyWith(confirmOnClose: value);
  }

  void addCustomClassPreset(ClassPreset preset) {
    state = state.copyWith(
      customClassPresets: [...state.customClassPresets, preset],
    );
  }

  void updateCustomClassPreset(int index, ClassPreset preset) {
    final presets = List<ClassPreset>.from(state.customClassPresets);
    if (index >= 0 && index < presets.length) {
      presets[index] = preset;
      state = state.copyWith(customClassPresets: presets);
    }
  }

  void removeCustomClassPreset(int index) {
    final presets = List<ClassPreset>.from(state.customClassPresets);
    if (index >= 0 && index < presets.length) {
      presets.removeAt(index);
      state = state.copyWith(customClassPresets: presets);
    }
  }

  void setAudioMode(AudioMode mode) {
    state = state.copyWith(audioMode: mode);
  }

  void resetToDefaults() {
    state = const AppSettings();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});