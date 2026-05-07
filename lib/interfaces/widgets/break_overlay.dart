import 'package:flutter/material.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';

class BreakOverlay extends StatelessWidget {
  final PresentationState state;

  const BreakOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.breakGradientStart, AppTheme.breakGradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.royalBlue.withValues(alpha: 0.4),
                    AppTheme.royalBlueDark.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.royalBlue.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.coffee,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text('BREAK TIME', style: AppTheme.overlayTitleStyle),
            const SizedBox(height: 4),
            Text(
              'Rest your hand',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.royalBlue.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${state.remainingTime.inMinutes}:${(state.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AppTheme.royalBlueLight,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
