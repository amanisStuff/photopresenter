enum ClassPhase {
  warmUp,
  earlyStudy,
  midStudy,
  finalStudy,
  breakTime,
}

extension ClassPhaseExtension on ClassPhase {
  String get displayName {
    switch (this) {
      case ClassPhase.warmUp:
        return 'Warm-up';
      case ClassPhase.earlyStudy:
        return 'Early Study';
      case ClassPhase.midStudy:
        return 'Mid Study';
      case ClassPhase.finalStudy:
        return 'Final Study';
      case ClassPhase.breakTime:
        return 'Break Time';
    }
  }

  Duration get defaultDuration {
    switch (this) {
      case ClassPhase.warmUp:
        return const Duration(seconds: 30);
      case ClassPhase.earlyStudy:
        return const Duration(minutes: 1);
      case ClassPhase.midStudy:
        return const Duration(minutes: 5);
      case ClassPhase.finalStudy:
        return const Duration(minutes: 10);
      case ClassPhase.breakTime:
        return const Duration(minutes: 3);
    }
  }
}

enum ClassLength {
  thirtyMinutes,
  sixtyMinutes,
  custom,
}

extension ClassLengthExtension on ClassLength {
  String get displayName {
    switch (this) {
      case ClassLength.thirtyMinutes:
        return '30 Minutes';
      case ClassLength.sixtyMinutes:
        return '60 Minutes';
      case ClassLength.custom:
        return 'Custom';
    }
  }

  int get totalMinutes {
    switch (this) {
      case ClassLength.thirtyMinutes:
        return 30;
      case ClassLength.sixtyMinutes:
        return 60;
      case ClassLength.custom:
        return 0;
    }
  }
}

class ClassConfig {
  final ClassLength length;
  final int warmUpCount;
  final int earlyStudyCount;
  final int midStudyCount;
  final int finalStudyCount;
  final int breakMinutes;
  final bool hasBreak;
  final int breakAfterImage;

  const ClassConfig({
    required this.length,
    this.warmUpCount = 0,
    this.earlyStudyCount = 0,
    this.midStudyCount = 0,
    this.finalStudyCount = 0,
    this.breakMinutes = 3,
    this.hasBreak = false,
    this.breakAfterImage = 0,
  });

  factory ClassConfig.fromPreset(ClassLength preset) {
    switch (preset) {
      case ClassLength.thirtyMinutes:
        return const ClassConfig(
          length: ClassLength.thirtyMinutes,
          warmUpCount: 4,
          earlyStudyCount: 4,
          midStudyCount: 2,
          finalStudyCount: 1,
          hasBreak: false,
        );
      case ClassLength.sixtyMinutes:
        return const ClassConfig(
          length: ClassLength.sixtyMinutes,
          warmUpCount: 6,
          earlyStudyCount: 6,
          midStudyCount: 4,
          finalStudyCount: 2,
          breakMinutes: 5,
          hasBreak: true,
          breakAfterImage: 9,
        );
      case ClassLength.custom:
        return const ClassConfig(
          length: ClassLength.custom,
        );
    }
  }

  int get totalImages =>
      warmUpCount + earlyStudyCount + midStudyCount + finalStudyCount;

  List<Duration> generatePhaseQueue() {
    final queue = <Duration>[];
    for (int i = 0; i < warmUpCount; i++) {
      queue.add(ClassPhase.warmUp.defaultDuration);
    }
    for (int i = 0; i < earlyStudyCount; i++) {
      queue.add(ClassPhase.earlyStudy.defaultDuration);
    }
    for (int i = 0; i < midStudyCount; i++) {
      queue.add(ClassPhase.midStudy.defaultDuration);
    }
    for (int i = 0; i < finalStudyCount; i++) {
      queue.add(ClassPhase.finalStudy.defaultDuration);
    }
    return queue;
  }

  ClassConfig copyWith({
    ClassLength? length,
    int? warmUpCount,
    int? earlyStudyCount,
    int? midStudyCount,
    int? finalStudyCount,
    int? breakMinutes,
    bool? hasBreak,
    int? breakAfterImage,
  }) {
    return ClassConfig(
      length: length ?? this.length,
      warmUpCount: warmUpCount ?? this.warmUpCount,
      earlyStudyCount: earlyStudyCount ?? this.earlyStudyCount,
      midStudyCount: midStudyCount ?? this.midStudyCount,
      finalStudyCount: finalStudyCount ?? this.finalStudyCount,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      hasBreak: hasBreak ?? this.hasBreak,
      breakAfterImage: breakAfterImage ?? this.breakAfterImage,
    );
  }
}
