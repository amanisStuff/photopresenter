import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopresenter/core/strategies/image_filter_decorator.dart';
import 'package:photopresenter/core/providers/presentation_provider.dart';

void main() {
  group('imageFilterFromMode', () {
    test('none returns NoFilter', () {
      final filter = imageFilterFromMode(ImageFilter.none);
      expect(filter, isA<NoFilter>());
    });

    test('grayscale returns GrayscaleFilter', () {
      final filter = imageFilterFromMode(ImageFilter.grayscale);
      expect(filter, isA<GrayscaleFilter>());
    });

    test('sepia returns SepiaFilter', () {
      final filter = imageFilterFromMode(ImageFilter.sepia);
      expect(filter, isA<SepiaFilter>());
    });

    test('invert returns InvertFilter', () {
      final filter = imageFilterFromMode(ImageFilter.invert);
      expect(filter, isA<InvertFilter>());
    });

    test('brightness returns BrightnessFilter', () {
      final filter = imageFilterFromMode(ImageFilter.brightness);
      expect(filter, isA<BrightnessFilter>());
    });

    test('contrast returns ContrastFilter', () {
      final filter = imageFilterFromMode(ImageFilter.contrast);
      expect(filter, isA<ContrastFilter>());
    });

    test('extremeContrast returns ExtremeContrastFilter', () {
      final filter = imageFilterFromMode(ImageFilter.extremeContrast);
      expect(filter, isA<ExtremeContrastFilter>());
    });

    test('blurEffect returns BlurFilter with default sigma', () {
      final filter = imageFilterFromMode(ImageFilter.blurEffect);
      expect(filter, isA<BlurFilter>());
      expect((filter as BlurFilter).sigma, equals(3));
    });

    test('heavyBlur returns BlurFilter with sigma 8', () {
      final filter = imageFilterFromMode(ImageFilter.heavyBlur);
      expect(filter, isA<BlurFilter>());
      expect((filter as BlurFilter).sigma, equals(8));
    });
  });

  group('NoFilter', () {
    test('apply returns same widget', () {
      const filter = NoFilter();
      final child = const SizedBox(width: 100, height: 100);
      final result = filter.apply(child);

      expect(result, same(child));
    });
  });

  group('GrayscaleFilter', () {
    test('apply wraps child in ColorFiltered', () {
      const filter = GrayscaleFilter();
      final child = const SizedBox(width: 100, height: 100);
      final result = filter.apply(child);

      expect(result, isA<ColorFiltered>());
    });
  });

  group('SepiaFilter', () {
    test('apply wraps child in ColorFiltered', () {
      const filter = SepiaFilter();
      final result = filter.apply(const SizedBox());

      expect(result, isA<ColorFiltered>());
    });
  });

  group('InvertFilter', () {
    test('apply wraps child in ColorFiltered', () {
      const filter = InvertFilter();
      final result = filter.apply(const SizedBox());

      expect(result, isA<ColorFiltered>());
    });
  });

  group('BlurFilter', () {
    test('apply wraps child in ImageFiltered', () {
      const filter = BlurFilter();
      final result = filter.apply(const SizedBox());

      expect(result, isA<ImageFiltered>());
    });

    test('default sigma is 3', () {
      const filter = BlurFilter();
      expect(filter.sigma, equals(3));
    });

    test('custom sigma is stored', () {
      const filter = BlurFilter(sigma: 10);
      expect(filter.sigma, equals(10));
    });
  });

  group('applyFilters', () {
    test('empty filter set returns original widget', () {
      final child = const SizedBox(width: 50, height: 50);
      final result = applyFilters({}, child);

      expect(result, same(child));
    });

    test('single filter wraps child', () {
      final result = applyFilters({ImageFilter.grayscale}, const SizedBox());

      expect(result, isA<ColorFiltered>());
    });

    test('multiple filters nest widgets', () {
      final result = applyFilters(
        {ImageFilter.grayscale, ImageFilter.sepia},
        const SizedBox(),
      );

      expect(result, isA<ColorFiltered>());
    });
  });

  group('ImageFilter enum', () {
    test('all filters have display names', () {
      for (final filter in ImageFilter.values) {
        expect(filter.displayName, isNotEmpty);
      }
    });

    test('none display name is None', () {
      expect(ImageFilter.none.displayName, equals('None'));
    });
  });
}
