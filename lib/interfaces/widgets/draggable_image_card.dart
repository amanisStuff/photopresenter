import 'dart:io';
import 'package:flutter/material.dart';
import '../../shared/theme.dart';
import '../../core/entities/presentation_image.dart';

class GridImage extends StatefulWidget {
  final PresentationImage image;

  const GridImage({super.key, required this.image});

  @override
  State<GridImage> createState() => _GridImageState();
}

class _GridImageState extends State<GridImage> {
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

class DraggableImage extends StatelessWidget {
  final PresentationImage image;
  final int actualIndex;
  final bool isSelected;
  final bool isDragging;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final void Function(int, int) onReorder;
  final int imagesLength;

  const DraggableImage({
    super.key,
    required this.image,
    required this.actualIndex,
    required this.isSelected,
    required this.isDragging,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onTap,
    required this.onRemove,
    required this.onReorder,
    required this.imagesLength,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<int>(
      data: actualIndex,
      delay: const Duration(milliseconds: 200),
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 180,
          height: 180,
          child: _buildImageCard(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildImageCard(context),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) => details.data != actualIndex,
        onAcceptWithDetails: (details) {
          onReorder(details.data, actualIndex);
        },
        builder: (context, candidateData, rejectedData) {
          final isDropTarget = candidateData.isNotEmpty;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDropTarget
                        ? AppTheme.primary
                        : isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GridImage(image: image),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white70,
                        ),
                        onPressed: onRemove,
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
    );
  }

  Widget _buildImageCard(BuildContext context, {bool isDragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDragging ? AppTheme.primary : Colors.transparent,
          width: 3,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GridImage(image: image),
          if (isDragging)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Icon(Icons.drag_indicator, color: Colors.white70, size: 40),
              ),
            ),
        ],
      ),
    );
  }
}
