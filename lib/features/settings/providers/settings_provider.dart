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

  void resetToDefaults() {
    state = const AppSettings();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});