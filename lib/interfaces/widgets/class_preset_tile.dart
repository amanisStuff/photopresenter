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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.royalBlue.withValues(alpha: 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.royalBlue,
                  AppTheme.royalBlueDark,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF16162A),
                    const Color(0xFF0F0F1E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$warmUp warm-up, $early early, $mid mid, $finalCount final ($total total)${hasBreak ? ', break at img ${(total/2).floor() + 1}' : ''}',
                          style: const TextStyle(
                            color: Color(0xFF8888A8),
                            fontSize: 12,
                          ),
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
