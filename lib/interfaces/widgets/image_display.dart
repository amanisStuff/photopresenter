import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/providers/presentation_provider.dart';
import '../../core/entities/presentation_image.dart';

ColorFilter? _getColorFilterMatrix(ImageFilter filter) {
  switch (filter) {
    case ImageFilter.none:
      return null;
    case ImageFilter.grayscale:
      return const ColorFilter.matrix([
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case ImageFilter.sepia:
      return const ColorFilter.matrix([
        0.393, 0.769, 0.189, 0, 0,
        0.349, 0.686, 0.168, 0, 0,
        0.272, 0.534, 0.131, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case ImageFilter.invert:
      return const ColorFilter.matrix([
        -1, 0, 0, 0, 255,
        0, -1, 0, 0, 255,
        0, 0, -1, 0, 255,
        0, 0, 0, 1, 0,
      ]);
    case ImageFilter.brightness:
      return const ColorFilter.matrix([
        1.3, 0, 0, 0, 0,
        0, 1.3, 0, 0, 0,
        0, 0, 1.3, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    case ImageFilter.contrast:
      return const ColorFilter.matrix([
        1.6, 0, 0, 0, -128 * 0.6,
        0, 1.6, 0, 0, -128 * 0.6,
        0, 0, 1.6, 0, -128 * 0.6,
        0, 0, 0, 1, 0,
      ]);
    case ImageFilter.extremeContrast:
      return const ColorFilter.matrix([
        2.5, 0, 0, 0, -200,
        0, 2.5, 0, 0, -200,
        0, 0, 2.5, 0, -200,
        0, 0, 0, 1, 0,
      ]);
    case ImageFilter.blurEffect:
    case ImageFilter.heavyBlur:
      return null;
  }
}

Widget _applyFilters(Set<ImageFilter> filters, Widget child) {
  Widget result = child;
  
  for (final filter in filters) {
    if (filter == ImageFilter.blurEffect) {
      result = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: result,
      );
    } else if (filter == ImageFilter.heavyBlur) {
      result = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: result,
      );
    } else {
      final colorFilter = _getColorFilterMatrix(filter);
      if (colorFilter != null) {
        result = ColorFiltered(colorFilter: colorFilter, child: result);
      }
    }
  }
  return result;
}

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final currentImage = state.currentImage;
    final activeFilters = state.activeFilters;

    if (currentImage == null) {
      return Center(
        child: FadeIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 80,
                color: Colors.white24,
              ),
              const SizedBox(height: 16),
              Text(
                'Drag & Drop images or Paste (Ctrl+V)',
                style: TextStyle(color: Colors.white38, fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(presentationProvider.notifier).pickFiles(),
                icon: const Icon(Icons.file_open),
                label: const Text('Pick Images'),
              ),
            ],
          ),
        ),
      );
    }

    Widget imageWidget;
    if (currentImage.source == ImageSource.file) {
      imageWidget = Image.file(
        File(currentImage.path!),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        frameBuilder: (context, child, frame, loaded) {
          if (loaded) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    } else if (currentImage.bytes != null) {
      imageWidget = Image.memory(
        currentImage.bytes!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        frameBuilder: (context, child, frame, loaded) {
          if (loaded) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    } else {
      imageWidget = _buildError();
    }

    return FadeIn(
      key: ValueKey(currentImage.id),
      duration: const Duration(milliseconds: 500),
      child: Container(
        constraints: const BoxConstraints.expand(),
        child: _applyFilters(activeFilters, imageWidget),
      ),
    );
  }

  Widget _buildError() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.white24),
          SizedBox(height: 8),
          Text('Failed to load image', style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}
