import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopresenter/core/entities/presentation_image.dart';
import 'package:photopresenter/core/entities/class_session.dart';
import 'package:photopresenter/core/providers/presentation_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall call) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall call) async {
        if (call.method == 'create') return 'player-id';
        return null;
      },
    );
  });

  group('PresentationState', () {
    test('initial state has empty images and default values', () {
      final state = PresentationState();

      expect(state.images, isEmpty);
      expect(state.currentIndex, equals(0));
      expect(state.isPlaying, isFalse);
      expect(state.timerDuration, equals(Duration(seconds: 30)));
      expect(state.remainingTime, equals(Duration(seconds: 30)));
      expect(state.isFocusMode, isFalse);
      expect(state.audioPaths, isEmpty);
      expect(state.isClassMode, isFalse);
      expect(state.activeFilters, isEmpty);
    });

    test('currentImage returns null when images is empty', () {
      final state = PresentationState();
      expect(state.currentImage, isNull);
    });

    test('currentImage returns image at currentIndex', () {
      final image = PresentationImage.fromPath('/test.jpg');
      final state = PresentationState(
        images: [image],
        currentIndex: 0,
      );

      expect(state.currentImage, same(image));
    });

    test('currentAudioPath returns null when audioPaths is empty', () {
      final state = PresentationState();
      expect(state.currentAudioPath, isNull);
    });

    test('currentAudioPath returns path at audioIndex', () {
      final state = PresentationState(
        audioPaths: ['/audio1.mp3', '/audio2.mp3'],
        audioIndex: 1,
      );

      expect(state.currentAudioPath, equals('/audio2.mp3'));
    });

    test('hasAudio returns true when audioPaths is not empty', () {
      final state = PresentationState(audioPaths: ['/audio.mp3']);
      expect(state.hasAudio, isTrue);
    });

    test('hasAudio returns false when audioPaths is empty', () {
      final state = PresentationState();
      expect(state.hasAudio, isFalse);
    });

    test('currentPhase returns null when not in class mode', () {
      final state = PresentationState();
      expect(state.currentPhase, isNull);
    });

    test('currentPhase returns null when phaseQueue is empty', () {
      final state = PresentationState(isClassMode: true);
      expect(state.currentPhase, isNull);
    });

    test('currentPhase warms up for 30-second phases', () {
      final state = PresentationState(
        isClassMode: true,
        phaseQueue: [Duration(seconds: 30)],
        phaseQueueIndex: 0,
      );

      expect(state.currentPhase, equals(ClassPhase.warmUp));
    });

    test('currentPhase early study for 60-second phases', () {
      final state = PresentationState(
        isClassMode: true,
        phaseQueue: [Duration(minutes: 1)],
        phaseQueueIndex: 0,
      );

      expect(state.currentPhase, equals(ClassPhase.earlyStudy));
    });

    test('currentPhase mid study for 5-minute phases', () {
      final state = PresentationState(
        isClassMode: true,
        phaseQueue: [Duration(minutes: 5)],
        phaseQueueIndex: 0,
      );

      expect(state.currentPhase, equals(ClassPhase.midStudy));
    });

    test('currentPhase final study for 10-minute phases', () {
      final state = PresentationState(
        isClassMode: true,
        phaseQueue: [Duration(minutes: 10)],
        phaseQueueIndex: 0,
      );

      expect(state.currentPhase, equals(ClassPhase.finalStudy));
    });

    test('copyWith updates only specified fields', () {
      final state = PresentationState();
      final modified = state.copyWith(
        isPlaying: true,
        currentIndex: 5,
      );

      expect(modified.isPlaying, isTrue);
      expect(modified.currentIndex, equals(5));
      expect(modified.images, isEmpty);
      expect(modified.audioPaths, isEmpty);
    });
  });

  group('PresentationNotifier state management', () {
    test('initial state is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(presentationProvider);

      expect(state.images, isEmpty);
      expect(state.isPlaying, isFalse);
      expect(state.currentIndex, equals(0));
    });

    test('addImages adds file-based images', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(presentationProvider.notifier).addImages(['/path/img1.jpg', '/path/img2.png']);
      final state = container.read(presentationProvider);

      expect(state.images.length, equals(2));
      expect(state.images[0].name, equals('img1.jpg'));
      expect(state.images[1].name, equals('img2.png'));
      expect(state.images[0].source, equals(ImageSource.file));
    });

    test('addMemoryImage adds bytes-based image', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final bytes = Uint8List.fromList([1, 2, 3]);
      container.read(presentationProvider.notifier).addMemoryImage(bytes, 'test_img');
      final state = container.read(presentationProvider);

      expect(state.images.length, equals(1));
      expect(state.images[0].name, equals('test_img'));
      expect(state.images[0].source, equals(ImageSource.memory));
      expect(state.images[0].bytes, equals(bytes));
    });

    test('removeImage removes at valid index and adjusts currentIndex', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg', '/c.jpg']);
      notifier.setCurrentIndex(2);

      notifier.removeImage(1);
      final state = container.read(presentationProvider);

      expect(state.images.length, equals(2));
      expect(state.images[0].name, equals('a.jpg'));
      expect(state.images[1].name, equals('c.jpg'));
      expect(state.currentIndex, equals(1));
    });

    test('removeImage with out-of-range index does nothing', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg']);

      notifier.removeImage(5);
      expect(container.read(presentationProvider).images.length, equals(1));
    });

    test('removeImage on single image results in empty state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg']);

      notifier.removeImage(0);
      final state = container.read(presentationProvider);

      expect(state.images, isEmpty);
      expect(state.currentIndex, equals(0));
    });

    test('reorderImages moves item and updates currentIndex', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg', '/c.jpg']);

      notifier.reorderImages(0, 2);
      final state = container.read(presentationProvider);

      expect(state.images[0].name, equals('b.jpg'));
      expect(state.images[1].name, equals('c.jpg'));
      expect(state.images[2].name, equals('a.jpg'));
    });

    test('reorderImages with same old/new index does nothing', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg']);

      notifier.reorderImages(0, 0);
      expect(container.read(presentationProvider).images.length, equals(2));
    });

    test('nextImage advances index cyclically', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg']);

      notifier.nextImage();
      expect(container.read(presentationProvider).currentIndex, equals(1));

      notifier.nextImage();
      expect(container.read(presentationProvider).currentIndex, equals(0));
    });

    test('previousImage goes back cyclically', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg', '/c.jpg']);

      notifier.previousImage();
      expect(container.read(presentationProvider).currentIndex, equals(2));

      notifier.previousImage();
      expect(container.read(presentationProvider).currentIndex, equals(1));
    });

    test('setCurrentIndex sets valid index', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg', '/c.jpg']);

      notifier.setCurrentIndex(1);
      expect(container.read(presentationProvider).currentIndex, equals(1));
    });

    test('setCurrentIndex with out-of-range index does nothing', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg']);

      notifier.setCurrentIndex(10);
      expect(container.read(presentationProvider).currentIndex, equals(0));
    });

    test('nextImage does nothing when images is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(presentationProvider.notifier).nextImage();

      expect(container.read(presentationProvider).currentIndex, equals(0));
    });

    test('previousImage does nothing when images is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(presentationProvider.notifier).previousImage();

      expect(container.read(presentationProvider).currentIndex, equals(0));
    });

    test('togglePlay starts and stops playback', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg']);

      notifier.togglePlay();
      expect(container.read(presentationProvider).isPlaying, isTrue);

      notifier.togglePlay();
      expect(container.read(presentationProvider).isPlaying, isFalse);
    });

    test('togglePlay does nothing when images is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(presentationProvider.notifier).togglePlay();

      expect(container.read(presentationProvider).isPlaying, isFalse);
    });

    test('toggleFilter toggles filter on and off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);

      notifier.toggleFilter(ImageFilter.grayscale);
      expect(container.read(presentationProvider).activeFilters, contains(ImageFilter.grayscale));

      notifier.toggleFilter(ImageFilter.grayscale);
      expect(container.read(presentationProvider).activeFilters, isEmpty);
    });

    test('clearFilters removes all filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.toggleFilter(ImageFilter.grayscale);
      notifier.toggleFilter(ImageFilter.sepia);

      notifier.clearFilters();
      expect(container.read(presentationProvider).activeFilters, isEmpty);
    });

    test('toggleShuffle shuffles and unshuffles images', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(['/a.jpg', '/b.jpg', '/c.jpg', '/d.jpg']);

      notifier.toggleShuffle();
      final shuffledState = container.read(presentationProvider);

      expect(shuffledState.isShuffled, isTrue);
      expect(shuffledState.images.length, equals(4));
      expect(shuffledState.originalOrder, isNotNull);

      notifier.toggleShuffle();
      final unshuffledState = container.read(presentationProvider);

      expect(unshuffledState.isShuffled, isFalse);
    });

    test('toggleShuffle does nothing when images is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(presentationProvider.notifier).toggleShuffle();

      expect(container.read(presentationProvider).isShuffled, isFalse);
    });

    test('setTimerDuration updates timer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(presentationProvider.notifier).setTimerDuration(Duration(seconds: 60));
      final state = container.read(presentationProvider);

      expect(state.timerDuration, equals(Duration(seconds: 60)));
      expect(state.remainingTime, equals(Duration(seconds: 60)));
    });

    test('startClassMode sets up class phase queue', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(List.generate(11, (i) => '/img$i.jpg'));

      final config = ClassConfig.fromPreset(ClassLength.thirtyMinutes);
      notifier.startClassMode(config);
      final state = container.read(presentationProvider);

      expect(state.isClassMode, isTrue);
      expect(state.classConfig?.totalImages, equals(11));
      expect(state.phaseQueue.length, equals(11));
      expect(state.phaseQueueIndex, equals(0));
      expect(state.isOnBreak, isFalse);
    });

    test('startClassMode does nothing with empty queue', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      final config = ClassConfig.fromPreset(ClassLength.custom);

      notifier.startClassMode(config);
      expect(container.read(presentationProvider).isClassMode, isFalse);
    });

    test('stopClassMode resets class mode state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages(List.generate(11, (i) => '/img$i.jpg'));

      final config = ClassConfig.fromPreset(ClassLength.thirtyMinutes);
      notifier.startClassMode(config);
      notifier.stopClassMode();
      final state = container.read(presentationProvider);

      expect(state.isClassMode, isFalse);
      expect(state.classConfig, isNull);
      expect(state.phaseQueue, isEmpty);
      expect(state.isOnBreak, isFalse);
      expect(state.timerDuration, equals(Duration(seconds: 30)));
    });

    test('imagesRemainingInPhase counts remaining in current phase', () {
      final state = PresentationState(
        isClassMode: true,
        images: [PresentationImage.fromPath('/a.jpg')],
        phaseQueue: [
          Duration(seconds: 30),
          Duration(seconds: 30),
          Duration(seconds: 30),
          Duration(seconds: 30),
          Duration(minutes: 1),
          Duration(minutes: 1),
        ],
        phaseQueueIndex: 1,
      );

      expect(state.imagesRemainingInPhase, equals(3));
    });

    test('totalPhaseCount returns phase queue length', () {
      final state = PresentationState(
        isClassMode: true,
        phaseQueue: [Duration(seconds: 30), Duration(minutes: 1)],
      );

      expect(state.totalPhaseCount, equals(2));
    });
  });

  group('PresentationNotifier URL filtering', () {
    test('addImages filters URLs and delegates to download', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(presentationProvider.notifier);
      notifier.addImages([
        '/local/img.jpg',
        'https://example.com/photo.png',
        '/local/img2.png',
      ]);

      final state = container.read(presentationProvider);
      expect(state.images.length, equals(2));
      expect(state.images[0].name, equals('img.jpg'));
      expect(state.images[1].name, equals('img2.png'));
    });
  });
}
