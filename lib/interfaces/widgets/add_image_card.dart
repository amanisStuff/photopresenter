import 'package:flutter/material.dart';
import '../../shared/theme.dart';

class AddImageCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddImageCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primary.withValues(alpha: 0.12),
                AppTheme.primaryDark.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: AppTheme.primaryLight,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Images',
                style: AppTheme.addImageLabelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
