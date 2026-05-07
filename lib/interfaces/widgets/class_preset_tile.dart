import 'package:flutter/material.dart';
import '../../shared/theme.dart';

class ClassPresetTile extends StatelessWidget {
  final String name;
  final int warmUp;
  final int early;
  final int mid;
  final int finalCount;
  final bool hasBreak;
  final int breakMinutes;
  final bool isCustom;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ClassPresetTile({
    super.key,
    required this.name,
    required this.warmUp,
    required this.early,
    required this.mid,
    required this.finalCount,
    required this.hasBreak,
    required this.breakMinutes,
    this.isCustom = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final total = warmUp + early + mid + finalCount;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppTheme.tileOuterDecoration,
      child: Row(
        children: [
          Container(width: 4, decoration: AppTheme.tileAccentBarDecoration),
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
                        Text(name, style: AppTheme.cardTitleStyle),
                        const SizedBox(height: 4),
                        Text(
                          '$warmUp warm-up, $early early, $mid mid, $finalCount final ($total total)${hasBreak ? ', break at img ${(total/2).floor() + 1}' : ''}',
                          style: AppTheme.cardSubtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  if (isCustom) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
