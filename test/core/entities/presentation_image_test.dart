import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopresenter/core/entities/presentation_image.dart';

void main() {
  group('PresentationImage', () {
    test('fromPath creates image with file source', () {
      final image = PresentationImage.fromPath('/home/user/photos/test.jpg');

      expect(image.id, equals('/home/user/photos/test.jpg'));
      expect(image.path, equals('/home/user/photos/test.jpg'));
      expect(image.source, equals(ImageSource.file));
      expect(image.name, equals('test.jpg'));
      expect(image.bytes, isNull);
      expect(image.url, isNull);
    });

    test('fromPath with Windows-style path extracts name correctly', () {
      final image = PresentationImage.fromPath(r'C:\Users\test\image.png');

      expect(image.name, equals('image.png'));
      expect(image.path, equals(r'C:\Users\test\image.png'));
    });

    test('fromBytes creates image with memory source', () {
      final bytes = Uint8List.fromList([0, 1, 2, 3]);
      final image = PresentationImage.fromBytes(bytes, 'clipboard_img');

      expect(image.bytes, equals(bytes));
      expect(image.name, equals('clipboard_img'));
      expect(image.source, equals(ImageSource.memory));
      expect(image.path, isNull);
      expect(image.url, isNull);
    });

    test('fromUrl creates image with url source', () {
      final image = PresentationImage.fromUrl(
        'https://example.com/photos/sunset.jpg',
      );

      expect(image.url, equals('https://example.com/photos/sunset.jpg'));
      expect(image.id, equals('https://example.com/photos/sunset.jpg'));
      expect(image.source, equals(ImageSource.url));
      expect(image.name, equals('sunset'));
      expect(image.path, isNull);
      expect(image.bytes, isNull);
    });

    test('fromUrl extracts name from URL without extension', () {
      final image = PresentationImage.fromUrl('https://example.com/image');

      expect(image.name, equals('image'));
    });

    test('fromUrl uses fallback name for URL without path segments', () {
      final image = PresentationImage.fromUrl('https://example.com');

      expect(image.name, equals('web_image'));
    });

    test('multiple fromPath calls create independent instances', () {
      final image1 = PresentationImage.fromPath('/a/1.jpg');
      final image2 = PresentationImage.fromPath('/b/2.jpg');

      expect(image1.id, isNot(equals(image2.id)));
      expect(image1.name, equals('1.jpg'));
      expect(image2.name, equals('2.jpg'));
    });
  });
}
