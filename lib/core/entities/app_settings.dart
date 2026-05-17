enum AudioMode {
  audioDriven,
  timerDriven,
}

extension AudioModeExtension on AudioMode {
  String get displayName {
    switch (this) {
      case AudioMode.audioDriven:
        return 'Audio Driven';
      case AudioMode.timerDriven:
        return 'Timer Driven';
    }
  }

  String get description {
    switch (this) {
      case AudioMode.audioDriven:
        return 'Image changes when audio ends';
      case AudioMode.timerDriven:
        return 'Audio starts at random position, image changes when timer ends';
    }
  }
}

class ClassPresetBuilder {
  String _name = 'Custom';
  int _warmUpCount = 0;
  int _earlyStudyCount = 0;
  int _midStudyCount = 0;
  int _finalStudyCount = 0;
  bool _hasBreak = false;
  int _breakMinutes = 3;
  int _breakAfterImage = 0;

  ClassPresetBuilder setName(String name) { _name = name; return this; }
  ClassPresetBuilder setWarmUpCount(int count) { _warmUpCount = count; return this; }
  ClassPresetBuilder setEarlyStudyCount(int count) { _earlyStudyCount = count; return this; }
  ClassPresetBuilder setMidStudyCount(int count) { _midStudyCount = count; return this; }
  ClassPresetBuilder setFinalStudyCount(int count) { _finalStudyCount = count; return this; }
  ClassPresetBuilder setHasBreak(bool hasBreak) { _hasBreak = hasBreak; return this; }
  ClassPresetBuilder setBreakMinutes(int minutes) { _breakMinutes = minutes; return this; }
  ClassPresetBuilder setBreakAfterImage(int image) { _breakAfterImage = image; return this; }

  ClassPreset build() {
    return ClassPreset(
      name: _name,
      warmUpCount: _warmUpCount,
      earlyStudyCount: _earlyStudyCount,
      midStudyCount: _midStudyCount,
      finalStudyCount: _finalStudyCount,
      hasBreak: _hasBreak,
      breakMinutes: _breakMinutes,
      breakAfterImage: _breakAfterImage,
    );
  }
}

class ClassPreset {
  final String name;
  final int warmUpCount;
  final int earlyStudyCount;
  final int midStudyCount;
  final int finalStudyCount;
  final bool hasBreak;
  final int breakMinutes;
  final int breakAfterImage;

  const ClassPreset({
    required this.name,
    this.warmUpCount = 0,
    this.earlyStudyCount = 0,
    this.midStudyCount = 0,
    this.finalStudyCount = 0,
    this.hasBreak = false,
    this.breakMinutes = 3,
    this.breakAfterImage = 0,
  });

  int get totalImages =>
      warmUpCount + earlyStudyCount + midStudyCount + finalStudyCount;

  ClassPreset copyWith({
    String? name,
    int? warmUpCount,
    int? earlyStudyCount,
    int? midStudyCount,
    int? finalStudyCount,
    bool? hasBreak,
    int? breakMinutes,
    int? breakAfterImage,
  }) {
    return ClassPreset(
      name: name ?? this.name,
      warmUpCount: warmUpCount ?? this.warmUpCount,
      earlyStudyCount: earlyStudyCount ?? this.earlyStudyCount,
      midStudyCount: midStudyCount ?? this.midStudyCount,
      finalStudyCount: finalStudyCount ?? this.finalStudyCount,
      hasBreak: hasBreak ?? this.hasBreak,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      breakAfterImage: breakAfterImage ?? this.breakAfterImage,
    );
  }

  static const List<ClassPreset> defaultPresets = [
    ClassPreset(name: '30 Min', warmUpCount: 4, earlyStudyCount: 4, midStudyCount: 2, finalStudyCount: 1),
    ClassPreset(name: '60 Min', warmUpCount: 6, earlyStudyCount: 6, midStudyCount: 4, finalStudyCount: 2, hasBreak: true, breakMinutes: 5, breakAfterImage: 9),
  ];
}

class AppSettings {
  final int timerDurationSeconds;
  final bool autoPlayAudio;
  final bool soundOnTransition;
  final String? transitionSoundPath;
  final double defaultVolume;
  final bool showImageInfo;
  final bool confirmOnClose;
  final int pauseBetweenImagesSeconds;
  final List<ClassPreset> customClassPresets;
  final AudioMode audioMode;
  final bool useViewport3D;
  final bool scatterMode;

  const AppSettings({
    this.timerDurationSeconds = 30,
    this.autoPlayAudio = true,
    this.soundOnTransition = false,
    this.transitionSoundPath,
    this.defaultVolume = 1.0,
    this.showImageInfo = true,
    this.confirmOnClose = false,
    this.pauseBetweenImagesSeconds = 0,
    this.customClassPresets = const [],
    this.audioMode = AudioMode.audioDriven,
    this.useViewport3D = false,
    this.scatterMode = false,
  });

  AppSettings copyWith({
    int? timerDurationSeconds,
    bool? autoPlayAudio,
    bool? soundOnTransition,
    String? transitionSoundPath,
    double? defaultVolume,
    bool? showImageInfo,
    bool? confirmOnClose,
    int? pauseBetweenImagesSeconds,
    List<ClassPreset>? customClassPresets,
    AudioMode? audioMode,
    bool? useViewport3D,
    bool? scatterMode,
  }) {
    return AppSettings(
      timerDurationSeconds: timerDurationSeconds ?? this.timerDurationSeconds,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      soundOnTransition: soundOnTransition ?? this.soundOnTransition,
      transitionSoundPath: transitionSoundPath ?? this.transitionSoundPath,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      showImageInfo: showImageInfo ?? this.showImageInfo,
      confirmOnClose: confirmOnClose ?? this.confirmOnClose,
      pauseBetweenImagesSeconds: pauseBetweenImagesSeconds ?? this.pauseBetweenImagesSeconds,
      customClassPresets: customClassPresets ?? this.customClassPresets,
      audioMode: audioMode ?? this.audioMode,
      useViewport3D: useViewport3D ?? this.useViewport3D,
      scatterMode: scatterMode ?? this.scatterMode,
    );
  }

  static const List<int> timerOptions = [5, 10, 15, 30, 60, 120, 300, 600];
  static const List<int> pauseOptions = [0, 3, 5, 10, 15, 30];
}
