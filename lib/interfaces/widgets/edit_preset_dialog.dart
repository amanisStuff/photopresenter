import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/entities/app_settings.dart';
import 'number_input_row.dart';

Future<void> showEditPresetDialog(
  BuildContext context,
  WidgetRef ref,
  int editIndex,
  ClassPreset? existingPreset,
) async {
  final notifier = ref.read(settingsProvider.notifier);
  final nameController = TextEditingController(
    text: existingPreset?.name ?? '',
  );
  int warmUp = existingPreset?.warmUpCount ?? 4;
  int early = existingPreset?.earlyStudyCount ?? 4;
  int mid = existingPreset?.midStudyCount ?? 2;
  int finalCount = existingPreset?.finalStudyCount ?? 1;
  bool hasBreak = existingPreset?.hasBreak ?? false;
  int breakMinutes = existingPreset?.breakMinutes ?? 3;
  int breakAfterImage = existingPreset?.breakAfterImage ?? 0;
  final breakAfterController = TextEditingController(text: breakAfterImage > 0 ? '$breakAfterImage' : '');

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final totalImages = warmUp + early + mid + finalCount;
        final autoBreakPos = totalImages > 0 ? (totalImages / 2).floor() + 1 : 1;
        final breakPos = breakAfterImage > 0 ? breakAfterImage : autoBreakPos;

         return AlertDialog(
           backgroundColor: AppTheme.surfaceOverlay,
          title: Text(
            existingPreset == null ? 'Add Custom Class' : 'Edit Class',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Class Name',
                        labelStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 13),
                        hintText: 'e.g., Quick 15 Min',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  NumberInputRow(label: 'Warm-up (30s)', value: warmUp, onChanged: (v) => setState(() => warmUp = v)),
                  NumberInputRow(label: 'Early Study (1m)', value: early, onChanged: (v) => setState(() => early = v)),
                  NumberInputRow(label: 'Mid Study (5m)', value: mid, onChanged: (v) => setState(() => mid = v)),
                  NumberInputRow(label: 'Final Study (10m)', value: finalCount, onChanged: (v) => setState(() => finalCount = v)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Checkbox(
                          value: hasBreak,
                          onChanged: (v) => setState(() => hasBreak = v ?? false),
                          activeColor: AppTheme.primary,
                          checkColor: Colors.white,
                        ),
                        const Text('Break', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        if (hasBreak) ...[
                          SizedBox(
                            width: 75,
                            child: DropdownButton<int>(
                              value: breakMinutes,
                              isDense: true,
                              dropdownColor: AppTheme.surfaceDropdown,
                              underline: const SizedBox(),
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                              items: [3, 5, 10, 15].map((m) => DropdownMenuItem(
                                value: m,
                                child: Text('$m min', style: const TextStyle(color: Colors.white70)),
                              )).toList(),
                              onChanged: (v) { if (v != null) setState(() => breakMinutes = v); },
                            ),
                          ),
                          const Text('at img', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          SizedBox(
                            width: 50,
                            height: 32,
                            child: TextField(
                              controller: breakAfterController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                                ),
                              ),
                              onChanged: (v) {
                                final num = int.tryParse(v);
                                if (num != null && num >= 1 && num <= totalImages) {
                                  setState(() => breakAfterImage = num);
                                }
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Total: $totalImages images',
                        style: const TextStyle(color: AppTheme.primaryLight, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final preset = ClassPreset(
                  name: nameController.text,
                  warmUpCount: warmUp,
                  earlyStudyCount: early,
                  midStudyCount: mid,
                  finalStudyCount: finalCount,
                  hasBreak: hasBreak,
                  breakMinutes: breakMinutes,
                  breakAfterImage: hasBreak ? breakPos : 0,
                );
                if (editIndex >= 0) {
                  notifier.updateCustomClassPreset(editIndex, preset);
                } else {
                  notifier.addCustomClassPreset(preset);
                }
                Navigator.pop(context);
              },
              child: Text(existingPreset == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    ),
  );
}
