import 'package:flutter/material.dart';
import '../../../shared/theme.dart';

class ClassModeButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const ClassModeButton({
    super.key,
    required this.isActive,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.pillButton(active: isActive),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isActive ? onStop : onStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school,
                  size: 14,
                  color: isActive ? AppTheme.textOnDark : AppTheme.onSurface,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Class' : 'Class Mode',
                  style: AppTheme.classLabelStyle.copyWith(
color: isActive ? AppTheme.textOnDark : AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
