import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/presentation_provider.dart';

class CustomTitleBar extends ConsumerWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return DragToMoveArea(
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showTitle = constraints.maxWidth > 300;
            return Row(
              children: [
                if (showTitle) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.photo_library,
                      size: 18, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'PhotoPresenter',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),

                const SizedBox(width: 16),

                // Window Controls
                _WindowButton(
                  icon: Icons.remove,
                  onPressed: () => notifier.minimizeWindow(),
                ),
                _WindowButton(
                  icon: state.isFocusMode
                      ? Icons.fullscreen_exit
                      : Icons.crop_square,
                  onPressed: () => notifier.toggleFocusMode(),
                ),
                _WindowButton(
                  icon: Icons.close,
                  isClose: true,
                  onPressed: () => windowManager.close(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onPressed,
        hoverColor: isClose ? Colors.red.withValues(alpha: 0.8) : Colors.white10,
        child: Container(
          width: 46,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: Colors.white70),
        ),
      ),
    );
  }
}
