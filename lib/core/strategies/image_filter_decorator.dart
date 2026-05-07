import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../providers/presentation_provider.dart';

abstract class ImageFilterDecorator {
  const ImageFilterDecorator();
  Widget apply(Widget child);
}

class NoFilter extends ImageFilterDecorator {
  const NoFilter();
  @override
  Widget apply(Widget child) => child;
}

class GrayscaleFilter extends ImageFilterDecorator {
  const GrayscaleFilter();
  @override
  Widget apply(Widget child) => ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    child: child,
  );
}

class SepiaFilter extends ImageFilterDecorator {
  const SepiaFilter();
  @override
  Widget apply(Widget child) => ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    child: child,
  );
}

class InvertFilter extends ImageFilterDecorator {
  const InvertFilter();
  @override
  Widget apply(Widget child) => ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]),
    child: child,
  );
}

class BrightnessFilter extends ImageFilterDecorator {
  const BrightnessFilter();
  @override
  Widget apply(Widget child) => ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      1.3, 0, 0, 0, 0,
      0, 1.3, 0, 0, 0,
      0, 0, 1.3, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    child: child,
  );
}

class ContrastFilter extends ImageFilterDecorator {
  const ContrastFilter();
  @override
  Widget apply(Widget child) => ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      1.6, 0, 0, 0, -128 * 0.6,
      0, 1.6, 0, 0, -128 * 0.6,
      0, 0, 1.6, 0, -128 * 0.6,
      0, 0, 0, 1, 0,
    ]),
    child: child,
  );
}

class ExtremeContrastFilter extends ImageFilterDecorator {
  const ExtremeContrastFilter();
  @override
  Widget apply(Widget child) => ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      2.5, 0, 0, 0, -200,
      0, 2.5, 0, 0, -200,
      0, 0, 2.5, 0, -200,
      0, 0, 0, 1, 0,
    ]),
    child: child,
  );
}

class BlurFilter extends ImageFilterDecorator {
  final double sigma;
  const BlurFilter({this.sigma = 3});
  @override
  Widget apply(Widget child) => ImageFiltered(
    imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    child: child,
  );
}

ImageFilterDecorator imageFilterFromMode(ImageFilter mode) {
  return switch (mode) {
    ImageFilter.none => const NoFilter(),
    ImageFilter.grayscale => const GrayscaleFilter(),
    ImageFilter.sepia => const SepiaFilter(),
    ImageFilter.invert => const InvertFilter(),
    ImageFilter.brightness => const BrightnessFilter(),
    ImageFilter.contrast => const ContrastFilter(),
    ImageFilter.extremeContrast => const ExtremeContrastFilter(),
    ImageFilter.blurEffect => const BlurFilter(),
    ImageFilter.heavyBlur => const BlurFilter(sigma: 8),
  };
}

Widget applyFilters(Set<ImageFilter> filters, Widget child) {
  var result = child;
  for (final filter in filters) {
    result = imageFilterFromMode(filter).apply(result);
  }
  return result;
}
