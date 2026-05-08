import 'package:flutter_test/flutter_test.dart';
import 'package:photopresenter/core/entities/gallery_manifest.dart';

void main() {
  group('GalleryManifest', () {
    const testDateStr = '2026-05-08T12:00:00.000Z';
    final testDate = DateTime.parse(testDateStr);

    test('constructor sets fields correctly', () {
      final manifest = GalleryManifest(
        id: 'test-id',
        name: 'Test Gallery',
        user: 'Test User',
        createdAt: testDate,
        imageCount: 5,
        audioCount: 2,
        imagePaths: ['/path/img1.jpg', '/path/img2.jpg'],
        audioPaths: ['/path/audio1.mp3'],
      );

      expect(manifest.id, equals('test-id'));
      expect(manifest.name, equals('Test Gallery'));
      expect(manifest.user, equals('Test User'));
      expect(manifest.createdAt, equals(testDate));
      expect(manifest.imageCount, equals(5));
      expect(manifest.audioCount, equals(2));
      expect(manifest.imagePaths, equals(['/path/img1.jpg', '/path/img2.jpg']));
      expect(manifest.audioPaths, equals(['/path/audio1.mp3']));
      expect(manifest.timerDurationSeconds, isNull);
    });

    test('constructor accepts optional timerDurationSeconds', () {
      final manifest = GalleryManifest(
        id: 'test-id',
        name: 'Test',
        user: 'User',
        createdAt: testDate,
        imageCount: 1,
        audioCount: 0,
        imagePaths: ['/path/img.jpg'],
        audioPaths: [],
        timerDurationSeconds: 60,
      );

      expect(manifest.timerDurationSeconds, equals(60));
    });

    test('toJson and fromJson round-trip correctly', () {
      final original = GalleryManifest(
        id: 'uuid-123',
        name: 'My Gallery',
        user: 'Alice',
        createdAt: testDate,
        imageCount: 3,
        audioCount: 1,
        imagePaths: ['/images/a.jpg', '/images/b.jpg', '/images/c.jpg'],
        audioPaths: ['/audio/song.mp3'],
        timerDurationSeconds: 30,
      );

      final json = original.toJson();
      final restored = GalleryManifest.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.user, equals(original.user));
      expect(restored.createdAt, equals(original.createdAt));
      expect(restored.imageCount, equals(original.imageCount));
      expect(restored.audioCount, equals(original.audioCount));
      expect(restored.imagePaths, equals(original.imagePaths));
      expect(restored.audioPaths, equals(original.audioPaths));
      expect(restored.timerDurationSeconds, equals(original.timerDurationSeconds));
    });

    test('toJson omits timerDurationSeconds when null', () {
      final manifest = GalleryManifest(
        id: 'id',
        name: 'n',
        user: 'u',
        createdAt: testDate,
        imageCount: 0,
        audioCount: 0,
        imagePaths: [],
        audioPaths: [],
      );

      final json = manifest.toJson();
      expect(json.containsKey('timerDurationSeconds'), isFalse);
    });

    test('fromJson handles missing timerDurationSeconds', () {
      final json = {
        'id': 'id',
        'name': 'n',
        'user': 'u',
        'createdAt': testDateStr,
        'imageCount': 0,
        'audioCount': 0,
        'imagePaths': <String>[],
        'audioPaths': <String>[],
      };

      final manifest = GalleryManifest.fromJson(json);
      expect(manifest.timerDurationSeconds, isNull);
    });
  });
}
