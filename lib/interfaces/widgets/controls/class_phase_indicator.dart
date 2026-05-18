import 'package:flutter/material.dart';
import '../../../shared/theme.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../core/entities/class_session.dart';

class ClassPhaseIndicator extends StatelessWidget {
  final PresentationState state;

  const ClassPhaseIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final phase = state.currentPhase;
    final phaseName = state.isOnBreak
        ? 'Break Time'
        : (phase?.displayName ?? 'Unknown');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: state.isOnBreak
                  ? AppTheme.primary.withValues(alpha: 0.2)
                  : AppTheme.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: state.isOnBreak
                    ? AppTheme.primary.withValues(alpha: 0.4)
                    : AppTheme.success.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              phaseName,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.phaseLabelStyle.copyWith(
                color: state.isOnBreak ? AppTheme.primaryLight : AppTheme.success,
              ),
            ),
          ),
        ),
        if (!state.isOnBreak && state.imagesRemainingInPhase > 1) ...[
          const SizedBox(width: 4),
          Text(
            '(${state.imagesRemainingInPhase} left in phase)',
            overflow: TextOverflow.ellipsis,
            style: AppTheme.phaseCountStyle,
          ),
        ],
      ],
    );
  }
}
