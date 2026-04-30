import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:win32/win32.dart' as win32;
import '../models/presentation_image.dart';
import '../../../services/service_providers.dart';
import '../../gallery/models/gallery_manifest.dart';

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
    );
  }

  String? get currentAudioPath =>
      audioPaths.isNotEmpty ? audioPaths[audioIndex] : null;

  bool get hasAudio => audioPaths.isNotEmpty;

  PresentationImage? get currentImage =>
      images.isNotEmpty ? images[currentIndex] : null;
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

  void _playSystemNotificationSound() {
    win32.Beep(800, 100);
  }

  void _advanceImage() {
    nextImage();
    if (state.isPlaying && !state.hasAudio) {
      _playSystemNotificationSound();
    }
  }

  void addImages(List<String> paths) {
    final newImages = paths
        .map((path) => PresentationImage.fromPath(path))
        .toList();
    state = state.copyWith(images: [...state.images, ...newImages]);
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
    final path = state.currentAudioPath!;
    final timerSecs = state.timerDuration.inSeconds;

    audioService.getDuration(path).then((audioDuration) {
      if (audioDuration == null) return;

      final audioSecs = audioDuration.inSeconds;
      if (audioSecs <= timerSecs) {
        state = state.copyWith(audioPosition: Duration.zero);
        audioService.playAudio(
          path,
          onComplete: () {
            if (state.isPlaying) {
              nextImage();
              final nextAudioIndex = state.audioPaths.isNotEmpty
                  ? (state.audioIndex + 1) % state.audioPaths.length
                  : 0;
              state = state.copyWith(audioIndex: nextAudioIndex);
              _startAudioPlayback();
            }
          },
        );
      } else {
        final newPosition = Duration(
          seconds: (state.audioPosition.inSeconds + timerSecs) % audioSecs,
        );
        state = state.copyWith(audioPosition: newPosition);
        audioService.playAudio(
          path,
          startPosition: newPosition,
          onComplete: () {
            if (state.isPlaying) {
              nextImage();
              final nextAudioIndex = state.audioPaths.isNotEmpty
                  ? (state.audioIndex + 1) % state.audioPaths.length
                  : 0;
              state = state.copyWith(audioIndex: nextAudioIndex);
              _startAudioPlayback();
            }
          },
        );
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

  Future<List<String>> addImagesFromUrls(List<String> urls) async {
    final cacheDir = await _getImageCacheDir();
    final addedPaths = <String>[];

    for (final url in urls) {
      if (url.trim().isEmpty) continue;
      try {
        final uri = Uri.parse(url.trim());
        if (!uri.isScheme('http') && !uri.isScheme('https')) continue;

        final response = await http.get(uri);
        if (response.statusCode != 200) continue;

        final fileName = _extractFileName(url.trim(), response.headers);
        final filePath = '${cacheDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        addedPaths.add(filePath);
      } catch (e) {
        debugPrint('Failed to download image from $url: $e');
      }
    }

    if (addedPaths.isNotEmpty) {
      addImages(addedPaths);
    }

    return addedPaths;
  }

  Future<Directory> _getImageCacheDir() async {
    final appData = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appData.path}/web_images');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  String _extractFileName(String url, Map<String, String> headers) {
    var name = url.split('?').first.split('/').last;
    if (name.isEmpty || !name.contains('.')) {
      final contentType = headers['content-type'] ?? '';
      final extension = contentType.contains('png')
          ? 'png'
          : contentType.contains('gif')
          ? 'gif'
          : contentType.contains('webp')
          ? 'webp'
          : 'jpg';
      name = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    }
    return name;
  }

  Future<GalleryManifest?> saveGallery(String name) async {
    final imagePaths = state.images
        .where((img) => img.path != null)
        .map((img) => img.path!)
        .toList();
    final audioPaths = List<String>.from(state.audioPaths);

    if (imagePaths.isEmpty && audioPaths.isEmpty) {
      return null;
    }

    final galleryService = ref.read(galleryServiceProvider);
    return await galleryService.saveGallery(
      name: name,
      imagePaths: imagePaths,
      audioPaths: audioPaths,
    );
  }

  Future<void> loadGallery(String galleryId) async {
    _timer?.cancel();
    ref.read(audioServiceProvider).stop();

    final galleryService = ref.read(galleryServiceProvider);
    final manifest = await galleryService.loadGallery(galleryId);

    final validImagePaths = <String>[];
    for (final path in manifest.imagePaths) {
      if (path.isNotEmpty) {
        validImagePaths.add(path);
      }
    }

    final newImages = validImagePaths
        .map((path) => PresentationImage.fromPath(path))
        .toList();

    final validAudioPaths = manifest.audioPaths
        .where((p) => p.isNotEmpty)
        .toList();

    state = PresentationState(
      images: newImages,
      currentIndex: 0,
      isPlaying: false,
      timerDuration: state.timerDuration,
      remainingTime: state.timerDuration,
      isFocusMode: state.isFocusMode,
      audioPaths: validAudioPaths,
      audioIndex: 0,
    );
  }

  Future<List<GalleryManifest>> listGalleries() async {
    final galleryService = ref.read(galleryServiceProvider);
    return await galleryService.listGalleries();
  }
}

final presentationProvider =
    NotifierProvider<PresentationNotifier, PresentationState>(() {
      return PresentationNotifier();
    });
