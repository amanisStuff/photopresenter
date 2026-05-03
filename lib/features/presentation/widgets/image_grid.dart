import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/presentation_provider.dart';
import '../models/presentation_image.dart';

class ImageGrid extends ConsumerWidget {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.images.length} images',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: state.images.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _AddCard(onTap: () => notifier.pickFiles());
                  }

                  final actualIndex = index - 1;
                  final image = state.images[actualIndex];
                  final isSelected = state.currentIndex == actualIndex;

                  return MouseRegion(
                    key: ValueKey(image.path ?? image.name),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => notifier.setCurrentIndex(actualIndex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _GridImage(image: image),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                                onPressed: () =>
                                    notifier.removeImage(actualIndex),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridImage extends StatefulWidget {
  final PresentationImage image;

  const _GridImage({required this.image});

  @override
  State<_GridImage> createState() => _GridImageState();
}

class _GridImageState extends State<_GridImage> {
  late final ImageProvider _imageProvider;
  bool _loaded = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _imageProvider =
        widget.image.source == ImageSource.file && widget.image.path != null
        ? FileImage(File(widget.image.path!))
        : widget.image.source == ImageSource.memory &&
              widget.image.bytes != null
        ? MemoryImage(widget.image.bytes!)
        : const NetworkImage('about:blank');

    _imageProvider
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener(
             (imageInfo, synchronousCall) {
               if (mounted) setState(() => _loaded = true);
             },
            onError: (error, stackTrace) {
              if (mounted) setState(() => _error = true);
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white38),
      );
    }

    if (!_loaded) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Image(
      image: _imageProvider,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Icon(Icons.broken_image, color: Colors.white38)),
    );
  }
}

class _AddCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12, style: BorderStyle.solid),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: Colors.white38,
              ),
              SizedBox(height: 8),
              Text('Add Images', style: TextStyle(color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}
