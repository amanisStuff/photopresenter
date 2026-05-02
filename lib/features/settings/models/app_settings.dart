enum AudioMode {
  audioDriven,    // 1. Audio plays start to end, image changes when audio ends
  timerDriven,   // 2. Audio starts at random position, changes when timer ends
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

class ClassPreset {
  final String name;
  final int warmUpCount;
  final int earlyStudyCount;
  final int midStudyCount;
  final int finalStudyCount;
  final bool hasBreak;
  final int breakMinutes;
  final int breakAfterImage; // 0 = auto (at 50%), otherwise specific image number

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
  final List<ClassPreset> customClassPresets;
  final AudioMode audioMode;

  const AppSettings({
    this.timerDurationSeconds = 30,
    this.autoPlayAudio = true,
    this.soundOnTransition = false,
    this.transitionSoundPath,
    this.defaultVolume = 1.0,
    this.showImageInfo = true,
    this.confirmOnClose = false,
    this.customClassPresets = const [],
    this.audioMode = AudioMode.audioDriven,
  });

  AppSettings copyWith({
    int? timerDurationSeconds,
    bool? autoPlayAudio,
    bool? soundOnTransition,
    String? transitionSoundPath,
    double? defaultVolume,
    bool? showImageInfo,
    bool? confirmOnClose,
    List<ClassPreset>? customClassPresets,
    AudioMode? audioMode,
  }) {
    return AppSettings(
      timerDurationSeconds: timerDurationSeconds ?? this.timerDurationSeconds,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      soundOnTransition: soundOnTransition ?? this.soundOnTransition,
      transitionSoundPath: transitionSoundPath ?? this.transitionSoundPath,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      showImageInfo: showImageInfo ?? this.showImageInfo,
      confirmOnClose: confirmOnClose ?? this.confirmOnClose,
      customClassPresets: customClassPresets ?? this.customClassPresets,
      audioMode: audioMode ?? this.audioMode,
    );
  }

  static const List<int> timerOptions = [5, 10, 15, 30, 60, 120, 300, 600];
}