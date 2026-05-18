import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/viewport_controls_provider.dart';
import 'timer_status_section.dart';
import 'playback_section.dart';
import 'viewport_controls_section.dart';
import 'actions_section.dart';
import 'options_section.dart';

class PresentationControls extends ConsumerWidget {
  const PresentationControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final vpState = ref.watch(viewportProvider);

    return Container(
      height: double.infinity,
      decoration: AppTheme.controlsBar,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const TimerStatusSection(),

            const SizedBox(height: 12),
            Container(height: 1, color: AppTheme.border),
            const SizedBox(height: 12),

            const PlaybackSection(),

            if (settings.useViewport3D) ...[
              const SizedBox(height: 12),
              Container(height: 1, color: AppTheme.border),
              const SizedBox(height: 12),

              const ViewportControlsSection(),
            ],

            const SizedBox(height: 12),
            Container(height: 1, color: AppTheme.border),
            const SizedBox(height: 12),

            const ActionsSection(),

            if (settings.useViewport3D &&
                vpState.activeOptionsPanel != ActiveOptionsPanel.none) ...[
              const SizedBox(height: 8),
              const OptionsSection(),
            ],
          ],
        ),
      ),
    );
  }
}
