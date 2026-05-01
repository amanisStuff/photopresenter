class AppSettings {
  final int timerDurationSeconds;
  final bool autoPlayAudio;
  final bool soundOnTransition;
  final String? transitionSoundPath;
  final double defaultVolume;
  final bool showImageInfo;
  final bool confirmOnClose;

  const AppSettings({
    this.timerDurationSeconds = 30,
    this.autoPlayAudio = true,
    this.soundOnTransition = false,
    this.transitionSoundPath,
    this.defaultVolume = 1.0,
    this.showImageInfo = true,
    this.confirmOnClose = false,
  });

  AppSettings copyWith({
    int? timerDurationSeconds,
    bool? autoPlayAudio,
    bool? soundOnTransition,
    String? transitionSoundPath,
    double? defaultVolume,
    bool? showImageInfo,
    bool? confirmOnClose,
  }) {
    return AppSettings(
      timerDurationSeconds: timerDurationSeconds ?? this.timerDurationSeconds,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      soundOnTransition: soundOnTransition ?? this.soundOnTransition,
      transitionSoundPath: transitionSoundPath ?? this.transitionSoundPath,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      showImageInfo: showImageInfo ?? this.showImageInfo,
      confirmOnClose: confirmOnClose ?? this.confirmOnClose,
    );
  }

  static const List<int> timerOptions = [5, 10, 15, 30, 60, 120, 300, 600];
}