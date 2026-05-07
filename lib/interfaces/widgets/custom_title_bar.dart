import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';

class CustomTitleBar extends ConsumerWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationProvider);
    final notifier = ref.read(presentationProvider.notifier);

    return DragToMoveArea(
      child: Container(
        height: 36,
        decoration: AppTheme.headerDecoration,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showTitle = constraints.maxWidth > 300;
            return Row(
              children: [
                if (showTitle) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.photo_library, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'PhotoPresenter',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),

                const SizedBox(width: 8),

                _WinXpButton(
                  icon: Icons.remove,
                  onPressed: () => notifier.minimizeWindow(),
                ),
                _WinXpButton(
                  icon: state.isFocusMode
                      ? Icons.fullscreen_exit
                      : Icons.crop_square,
                  onPressed: () => notifier.toggleFocusMode(),
                ),
                _WinXpButton(
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

class _WinXpButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WinXpButton({
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
        hoverColor: isClose
            ? AppTheme.error.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.15),
        child: Container(
          width: 44,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 14,
            color: isClose ? Colors.white : Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
