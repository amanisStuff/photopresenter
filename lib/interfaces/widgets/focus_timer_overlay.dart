import 'package:flutter/material.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';

class FocusTimerOverlay extends StatelessWidget {
  final PresentationState state;

  const FocusTimerOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceOverlay.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                height: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: state.timerDuration.inMilliseconds > 0
                        ? state.remainingTime.inMilliseconds /
                              state.timerDuration.inMilliseconds
                        : 0,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      state.remainingTime.inSeconds <= 5
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${state.remainingTime.inSeconds}s',
                style: TextStyle(
                  color: state.remainingTime.inSeconds <= 5
                      ? AppTheme.error
                      : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
