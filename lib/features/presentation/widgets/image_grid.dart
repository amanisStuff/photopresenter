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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.images.length} images',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
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
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => notifier.setCurrentIndex(actualIndex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blueAccent : Colors.transparent,
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
                            image.source == ImageSource.file
                                ? Image.file(File(image.path!), fit: BoxFit.cover)
                                : Image.memory(image.bytes!, fit: BoxFit.cover),
                            
                            // Delete button on hover (simulated with Stack for now)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.white70),
                                onPressed: () => notifier.removeImage(actualIndex),
                                style: IconButton.styleFrom(backgroundColor: Colors.black54),
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
              Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.white38),
              SizedBox(height: 8),
              Text('Add Images', style: TextStyle(color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}
