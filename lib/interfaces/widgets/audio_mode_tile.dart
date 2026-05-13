import 'package:flutter/material.dart';
import '../../shared/theme.dart';
import '../../core/entities/app_settings.dart';

class AudioModeTile extends StatelessWidget {
  final AudioMode currentMode;
  final ValueChanged<AudioMode> onChanged;

  const AudioModeTile({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.tileOuterDecoration,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.tileContentDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AudioMode.values.map((mode) {
                  final isSelected = mode == currentMode;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                      onTap: () => onChanged(mode),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppTheme.primary : AppTheme.textOnDark.withValues(alpha: 0.4),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mode.displayName,
                                    style: AppTheme.tileTitleStyle.copyWith(
                                      color: isSelected ? AppTheme.primary : AppTheme.textOnDark,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    mode.description,
                                    style: AppTheme.tileSubtitleStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
