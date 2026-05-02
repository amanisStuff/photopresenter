import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/presentation_image.dart';
import '../models/class_session.dart';
import '../../settings/models/app_settings.dart';
import '../../../services/service_providers.dart';
import '../../settings/providers/settings_provider.dart';

class PresentationState {
  final List<PresentationImage> images;
  final int currentIndex;
  final bool isPlaying;
  final Duration timerDuration;
  final Duration remainingTime;
  final bool isFocusMode;
  final List<String> audioPaths;
  final int audioIndex;
  final Duration audioPosition;
  final Duration audioDuration;
  final bool isClassMode;
  final ClassConfig? classConfig;
  final List<Duration> phaseQueue;
  final int phaseQueueIndex;
  final bool isOnBreak;

  PresentationState({
    List<PresentationImage>? images,
    this.currentIndex = 0,
    this.isPlaying = false,
    this.timerDuration = const Duration(seconds: 30),
    this.remainingTime = const Duration(seconds: 30),
    this.isFocusMode = false,
    List<String>? audioPaths,
    this.audioIndex = 0,
    this.audioPosition = Duration.zero,
    this.audioDuration = Duration.zero,
    this.isClassMode = false,
    this.classConfig,
    this.phaseQueue = const [],
    this.phaseQueueIndex = 0,
    this.isOnBreak = false,
  }) : images = images ?? [],
       audioPaths = audioPaths ?? [];

  PresentationState copyWith({
    List<PresentationImage>? images,
    int? currentIndex,
    bool? isPlaying,
    Duration? timerDuration,
    Duration? remainingTime,
    bool? isFocusMode,
    List<String>? audioPaths,
    int? audioIndex,
    Duration? audioPosition,
    Duration? audioDuration,
    bool? isClassMode,
    ClassConfig? classConfig,
    List<Duration>? phaseQueue,
    int? phaseQueueIndex,
    bool? isOnBreak,
  }) {
    return PresentationState(
      images: images ?? this.images,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      timerDuration: timerDuration ?? this.timerDuration,
      remainingTime: remainingTime ?? this.remainingTime,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      audioPaths: audioPaths ?? this.audioPaths,
      audioIndex: audioIndex ?? this.audioIndex,
      audioPosition: audioPosition ?? this.audioPosition,
      audioDuration: audioDuration ?? this.audioDuration,
      isClassMode: isClassMode ?? this.isClassMode,
      classConfig: classConfig ?? this.classConfig,
      phaseQueue: phaseQueue ?? this.phaseQueue,
      phaseQueueIndex: phaseQueueIndex ?? this.phaseQueueIndex,
      isOnBreak: isOnBreak ?? this.isOnBreak,
    );
  }

  String? get currentAudioPath =>
      audioPaths.isNotEmpty ? audioPaths[audioIndex] : null;

  bool get hasAudio => audioPaths.isNotEmpty;

  PresentationImage? get currentImage =>
      images.isNotEmpty ? images[currentIndex] : null;

  ClassPhase? get currentPhase {
    if (!isClassMode || phaseQueue.isEmpty || phaseQueueIndex >= phaseQueue.length) {
      return null;
    }
    final duration = phaseQueue[phaseQueueIndex];
    if (duration.inSeconds <= 30) return ClassPhase.warmUp;
    if (duration.inSeconds <= 60) return ClassPhase.earlyStudy;
    if (duration.inSeconds <= 300) return ClassPhase.midStudy;
    return ClassPhase.finalStudy;
  }

  int get totalPhaseCount => phaseQueue.length;

  int get imagesRemainingInPhase {
    if (!isClassMode) return 0;
    int count = 0;
    final currentDuration = phaseQueue.isNotEmpty && phaseQueueIndex < phaseQueue.length
        ? phaseQueue[phaseQueueIndex]
        : null;
    if (currentDuration == null) return 0;
    for (int i = phaseQueueIndex; i < phaseQueue.length; i++) {
      if (phaseQueue[i] == currentDuration) {
        count++;
      }
    }
    return count;
  }
}

class PresentationNotifier extends Notifier<PresentationState> {
  Timer? _timer;
  DateTime? _targetTime;

  @override
  PresentationState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return PresentationState();
  }

  final AudioPlayer _beepPlayer = AudioPlayer();

  void _playSystemNotificationSound() async {
    final settings = ref.read(settingsProvider);
    if (!settings.soundOnTransition) return;

    if (settings.transitionSoundPath != null) {
      await _beepPlayer.setSource(DeviceFileSource(settings.transitionSoundPath!));
    } else {
      await _beepPlayer.setSource(AssetSource('beep.wav'));
    }
    await _beepPlayer.resume();
  }

  void _advanceImage() {
    if (state.isClassMode && !state.isOnBreak) {
      _advanceClassPhase();
    } else {
      nextImage();
      if (state.isPlaying && !state.hasAudio) {
        _playSystemNotificationSound();
      }
    }
  }

  void addImages(List<String> paths) {
    final filePaths = paths.where((p) => !_isUrl(p)).toList();
    final urlPaths = paths.where((p) => _isUrl(p)).toList();

    final newImages = filePaths
        .map((path) => PresentationImage.fromPath(path))
        .toList();

    state = state.copyWith(images: [...state.images, ...newImages]);

    for (final url in urlPaths) {
      _downloadUrlImage(url);
    }
  }

  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  Future<void> _downloadUrlImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final name = Uri.parse(url).pathSegments.isNotEmpty
            ? Uri.parse(url).pathSegments.last.split('.').first
            : 'Web Image';
        addMemoryImage(bytes, name);
      }
    } catch (e) {
      // Silently fail for now
    }
  }

  void addMemoryImage(dynamic bytes, String name) {
    final image = PresentationImage.fromBytes(bytes, name);
    state = state.copyWith(images: [...state.images, image]);
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.images.length) return;
    final newImages = List<PresentationImage>.from(state.images)
      ..removeAt(index);
    int newIndex = state.currentIndex;
    if (newImages.isEmpty) {
      newIndex = 0;
    } else if (newIndex >= newImages.length) {
      newIndex = newImages.length - 1;
    }
    state = state.copyWith(images: newImages, currentIndex: newIndex);
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index >= state.images.length) return;
    final nextAudioIndex = state.audioPaths.isNotEmpty
        ? (state.audioIndex + 1) % state.audioPaths.length
        : 0;
    state = state.copyWith(
      currentIndex: index,
      remainingTime: state.timerDuration,
      audioIndex: nextAudioIndex,
    );
    if (state.isPlaying && state.hasAudio) {
      _startAudioPlayback();
    }
  }

  void nextImage() {
    if (state.images.isEmpty) return;
    final nextIndex = (state.currentIndex + 1) % state.images.length;
    final nextAudioIndex = state.audioPaths.isNotEmpty
        ? (state.audioIndex + 1) % state.audioPaths.length
        : 0;
    _targetTime = DateTime.now().add(state.timerDuration);
    state = state.copyWith(
      currentIndex: nextIndex,
      remainingTime: state.timerDuration,
      audioIndex: nextAudioIndex,
    );
    if (state.isPlaying && state.hasAudio) {
      _startAudioPlayback();
    }
  }

  void previousImage() {
    if (state.images.isEmpty) return;
    final prevIndex =
        (state.currentIndex - 1 + state.images.length) % state.images.length;
    final nextAudioIndex = state.audioPaths.isNotEmpty
        ? (state.audioIndex - 1 + state.audioPaths.length) %
              state.audioPaths.length
        : 0;
    _targetTime = DateTime.now().add(state.timerDuration);
    state = state.copyWith(
      currentIndex: prevIndex,
      remainingTime: state.timerDuration,
      audioIndex: nextAudioIndex,
    );
    if (state.isPlaying && state.hasAudio) {
      _startAudioPlayback();
    }
  }

  void togglePlay() {
    if (state.images.isEmpty) return;
    final newState = !state.isPlaying;
    state = state.copyWith(isPlaying: newState);

    if (newState) {
      if (state.audioPaths.isNotEmpty) {
        _startAudioPlayback();
      }
      _startTimer();
    } else {
      _timer?.cancel();
      ref.read(audioServiceProvider).stop();
    }
  }

  void _startAudioPlayback() {
    final audioService = ref.read(audioServiceProvider);
    final settings = ref.read(settingsProvider);
    final path = state.currentAudioPath!;
    final timerSecs = state.timerDuration.inSeconds;
    final isTimerDriven = settings.audioMode == AudioMode.timerDriven;

    audioService.getDuration(path).then((audioDuration) {
      if (audioDuration == null) return;

      state = state.copyWith(audioDuration: audioDuration);

      final audioSecs = audioDuration.inSeconds;
      final bool audioIsCountdown = audioSecs <= timerSecs;

      if (audioIsCountdown) {
        state = state.copyWith(audioPosition: Duration.zero);
        audioService.playAudio(
          path,
          onComplete: () {
            if (state.isPlaying) {
              nextImage();
              final nextAudioIndex = state.audioPaths.isNotEmpty
                  ? (state.audioIndex + 1) % state.audioPaths.length
                  : 0;
              state = state.copyWith(audioIndex: nextAudioIndex, audioPosition: Duration.zero);
              _startAudioPlayback();
            }
          },
        );
      } else if (!isTimerDriven) {
        state = state.copyWith(audioPosition: Duration.zero);
        audioService.playAudio(
          path,
          onComplete: () {
            if (state.isPlaying) {
              nextImage();
              final nextAudioIndex = state.audioPaths.isNotEmpty
                  ? (state.audioIndex + 1) % state.audioPaths.length
                  : 0;
              state = state.copyWith(audioIndex: nextAudioIndex, audioPosition: Duration.zero);
              _startAudioPlayback();
            }
          },
        );
      } else {
        state = state.copyWith(audioPosition: Duration.zero);
        audioService.playAudio(path);
      }
    });
  }

  Future<void> pickAudio() async {
    final fileService = ref.read(fileServiceProvider);
    final paths = await fileService.pickAudioFiles();
    if (paths.isNotEmpty) {
      state = state.copyWith(
        audioPaths: [...state.audioPaths, ...paths],
        audioIndex: 0,
      );
    }
  }

  void clearAudio() {
    ref.read(audioServiceProvider).stop();
    state = state.copyWith(audioPaths: [], audioIndex: 0);
  }

  void setTimerDuration(Duration duration) {
    state = state.copyWith(timerDuration: duration, remainingTime: duration);
    if (state.isPlaying) {
      _targetTime = DateTime.now().add(duration);
    }
  }

  void _startTimer() {
    final settings = ref.read(settingsProvider);
    final isAudioDriven = settings.audioMode == AudioMode.audioDriven;
    final audioLonger = state.hasAudio && state.audioDuration.inSeconds > state.timerDuration.inSeconds;

    _timer?.cancel();
    _targetTime = DateTime.now().add(state.remainingTime);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_targetTime == null || !state.isPlaying) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final difference = _targetTime!.difference(now);

      if (difference.inMilliseconds <= 0) {
        if (isAudioDriven && audioLonger) {
          return;
        }
        _advanceImage();
      } else {
        if (difference.inSeconds != (state.remainingTime.inSeconds - 1)) {
          state = state.copyWith(
            remainingTime: Duration(seconds: difference.inSeconds + 1),
          );
        }
      }
    });
  }

  Future<void> toggleFocusMode() async {
    final windowService = ref.read(windowServiceProvider);
    final newMode = !state.isFocusMode;

    if (newMode) {
      await windowService.enterFocusMode();
    } else {
      await windowService.exitFocusMode();
    }

    state = state.copyWith(isFocusMode: newMode);
  }

  Future<void> minimizeWindow() async {
    await ref.read(windowServiceProvider).minimize();
  }

  Future<void> pasteFromClipboard() async {
    final clipboard = ref.read(clipboardServiceProvider);
    final files = await clipboard.getClipboardFiles();
    if (files.isNotEmpty) {
      addImages(files);
      return;
    }

    final imageBytes = await clipboard.getClipboardImage();
    if (imageBytes != null) {
      addMemoryImage(imageBytes, "Clipboard Image ${DateTime.now()}");
    }
  }

  Future<void> pickFiles() async {
    final fileService = ref.read(fileServiceProvider);
    final paths = await fileService.pickImages();
    if (paths.isNotEmpty) {
      addImages(paths);
    }
  }

  Future<String?> exportCurrentImage() async {
    final image = state.currentImage;
    if (image == null) return null;

    if (image.source == ImageSource.file && image.path != null) {
      final fileService = ref.read(fileServiceProvider);
      return await fileService.exportImages([
        MapEntry(image.path!, image.name),
      ]);
    }

    return 'Cannot export in-memory images';
  }

  Future<String?> exportAllImages() async {
    if (state.images.isEmpty) return null;

    final fileImages = state.images
        .where((img) => img.source == ImageSource.file && img.path != null)
        .map((img) => MapEntry(img.path!, img.name))
        .toList();

    if (fileImages.isEmpty) {
      return 'No file-based images to export';
    }

    final fileService = ref.read(fileServiceProvider);
    return await fileService.exportImages(fileImages);
  }

  Future<String?> saveGallery(String name) async {
    if (state.images.isEmpty) return null;

    final fileImages = state.images
        .where((img) => img.source == ImageSource.file && img.path != null)
        .map((img) => MapEntry(img.path!, img.name))
        .toList();

    if (fileImages.isEmpty) {
      return 'No file-based images to save';
    }

    final fileService = ref.read(fileServiceProvider);
    return await fileService.saveGallery(
      galleryName: name,
      imagePaths: fileImages,
      timerDurationSeconds: state.timerDuration.inSeconds,
      audioPaths: state.audioPaths.isNotEmpty ? state.audioPaths : null,
    );
  }

  void startClassMode(ClassConfig config) {
    final queue = config.generatePhaseQueue();
    if (queue.isEmpty) return;

    final firstDuration = queue.first;
    state = state.copyWith(
      isClassMode: true,
      classConfig: config,
      phaseQueue: queue,
      phaseQueueIndex: 0,
      timerDuration: firstDuration,
      remainingTime: firstDuration,
      isOnBreak: false,
    );
  }

  void stopClassMode() {
    _timer?.cancel();
    state = state.copyWith(
      isClassMode: false,
      classConfig: null,
      phaseQueue: [],
      phaseQueueIndex: 0,
      isOnBreak: false,
      timerDuration: const Duration(seconds: 30),
      remainingTime: const Duration(seconds: 30),
    );
  }

  void _advanceClassPhase() {
    final nextIndex = state.phaseQueueIndex + 1;

    if (state.classConfig != null && state.classConfig!.hasBreak) {
      final totalImages = state.phaseQueue.length;
      final breakPoint = state.classConfig!.breakAfterImage > 0
          ? state.classConfig!.breakAfterImage
          : (totalImages / 2).floor(); // Default to 50% if not specified
      if (nextIndex == breakPoint && !state.isOnBreak) {
        _startBreak();
        return;
      }
    }

    if (nextIndex >= state.phaseQueue.length) {
      _endClassSession();
      return;
    }

    final nextDuration = state.phaseQueue[nextIndex];
    final nextIndex_ = (state.currentIndex + 1) % state.images.length;
    final nextAudioIndex = state.audioPaths.isNotEmpty
        ? (state.audioIndex + 1) % state.audioPaths.length
        : 0;

    _targetTime = DateTime.now().add(nextDuration);
    state = state.copyWith(
      phaseQueueIndex: nextIndex,
      currentIndex: nextIndex_,
      timerDuration: nextDuration,
      remainingTime: nextDuration,
      audioIndex: nextAudioIndex,
    );

    if (state.isPlaying && state.hasAudio) {
      _startAudioPlayback();
    }

    if (state.isPlaying && !state.hasAudio) {
      _playSystemNotificationSound();
    }
  }

  void _startBreak() {
    final breakDuration = Duration(
      minutes: state.classConfig?.breakMinutes ?? 5,
    );
    _timer?.cancel();

    state = state.copyWith(
      isOnBreak: true,
      remainingTime: breakDuration,
      timerDuration: breakDuration,
    );

    _targetTime = DateTime.now().add(breakDuration);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_targetTime == null || !state.isPlaying || !state.isOnBreak) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final difference = _targetTime!.difference(now);

      if (difference.inMilliseconds <= 0) {
        _endBreak();
      } else {
        if (difference.inSeconds != (state.remainingTime.inSeconds - 1)) {
          state = state.copyWith(
            remainingTime: Duration(seconds: difference.inSeconds + 1),
          );
        }
      }
    });
  }

  void _endBreak() {
    final nextIndex = state.phaseQueueIndex + 1;
    if (nextIndex >= state.phaseQueue.length) {
      _endClassSession();
      return;
    }

    final nextDuration = state.phaseQueue[nextIndex];
    final nextIndex_ = (state.currentIndex + 1) % state.images.length;
    final nextAudioIndex = state.audioPaths.isNotEmpty
        ? (state.audioIndex + 1) % state.audioPaths.length
        : 0;

    _targetTime = DateTime.now().add(nextDuration);
    state = state.copyWith(
      isOnBreak: false,
      phaseQueueIndex: nextIndex,
      currentIndex: nextIndex_,
      timerDuration: nextDuration,
      remainingTime: nextDuration,
      audioIndex: nextAudioIndex,
    );

    _playSystemNotificationSound();

    if (state.isPlaying && state.hasAudio) {
      _startAudioPlayback();
    }
  }

  void _endClassSession() {
    _timer?.cancel();
    state = state.copyWith(
      isPlaying: false,
      isClassMode: false,
      isOnBreak: false,
    );
  }

  void cleanup() {
    _timer?.cancel();
    _beepPlayer.dispose();
  }
}

final presentationProvider =
    NotifierProvider<PresentationNotifier, PresentationState>(() {
      return PresentationNotifier();
    });
