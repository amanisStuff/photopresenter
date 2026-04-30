import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/presentation_provider.dart';
import '../models/presentation_image.dart';

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final currentImage = state.currentImage;

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

    return FadeIn(
      key: ValueKey(currentImage.id),
      duration: const Duration(milliseconds: 500),
      child: Container(
        constraints: const BoxConstraints.expand(),
        child: currentImage.source == ImageSource.file
            ? Image.file(
                File(currentImage.path!),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              )
            : Image.memory(
                currentImage.bytes!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
      ),
    );
  }
}
