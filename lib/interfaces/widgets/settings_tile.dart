import 'package:flutter/material.dart';
import '../../shared/theme.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.tileOuterDecoration,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppTheme.tileContentDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTheme.tileTitleStyle),
                        const SizedBox(height: 2),
                        Text(subtitle, style: AppTheme.tileSubtitleStyle),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: trailing,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
