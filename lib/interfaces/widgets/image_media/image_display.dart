import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../shared/theme.dart';
import '../../../shared/theme/theme_notifier.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/strategies/image_filter_decorator.dart';
import '../../../core/entities/presentation_image.dart';

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeProvider);
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
                color: AppTheme.textOnDarkSubtle,
              ),
              const SizedBox(height: 16),
              Text(
                'Drag & Drop images or Paste (Ctrl+V)',
                style: AppTheme.emptyStateTextStyle,
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
        child: applyFilters(activeFilters, imageWidget),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image, size: 64, color: AppTheme.textOnDarkSubtle),
          const SizedBox(height: 8),
          Text('Failed to load image', style: AppTheme.errorTextStyle),
        ],
      ),
    );
  }
}
