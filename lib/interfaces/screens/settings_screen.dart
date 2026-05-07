import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/entities/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Timer'),
          _SettingsTile(
            title: 'Default Timer Duration',
            subtitle: '${settings.timerDurationSeconds} seconds',
            trailing: DropdownButton<int>(
              value: settings.timerDurationSeconds,
              dropdownColor: const Color(0xFF2A2A2A),
              underline: const SizedBox(),
              items: AppSettings.timerOptions.map((val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    val < 60 ? '${val}s' : '${val ~/ 60}min',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.setTimerDuration(val);
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Audio'),
          _SettingsTile(
            title: 'Auto-play Audio',
            subtitle: 'Play audio when slideshow starts',
            trailing: Switch(
              value: settings.autoPlayAudio,
              onChanged: notifier.setAutoPlayAudio,
              activeThumbColor: AppTheme.xpGreen,
              activeTrackColor: AppTheme.xpGreen.withValues(alpha: 0.3),
            ),
          ),
          _SettingsTile(
            title: 'Sound on Transition',
            subtitle: 'Play sound when moving to next image',
            trailing: Switch(
              value: settings.soundOnTransition,
              onChanged: notifier.setSoundOnTransition,
              activeThumbColor: AppTheme.royalBlue,
              activeTrackColor: AppTheme.royalBlue.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Display'),
          _SettingsTile(
            title: 'Show Image Info',
            subtitle: 'Display image name and count',
            trailing: Switch(
              value: settings.showImageInfo,
              onChanged: notifier.setShowImageInfo,
                  activeThumbColor: AppTheme.royalBlue,
                  activeTrackColor: AppTheme.royalBlue.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Audio Mode'),
          _AudioModeTile(
            currentMode: settings.audioMode,
            onChanged: notifier.setAudioMode,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Behavior'),
          _SettingsTile(
            title: 'Confirm on Close',
            subtitle: 'Ask before closing the app',
            trailing: Switch(
              value: settings.confirmOnClose,
              onChanged: notifier.setConfirmOnClose,
              activeThumbColor: AppTheme.royalBlue,
              activeTrackColor: AppTheme.royalBlue.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Class Mode Presets'),
          ...ClassPreset.defaultPresets.asMap().entries.map((entry) {
            final preset = entry.value;
            return _ClassPresetTile(
              name: preset.name,
              warmUp: preset.warmUpCount,
              early: preset.earlyStudyCount,
              mid: preset.midStudyCount,
              finalCount: preset.finalStudyCount,
              hasBreak: preset.hasBreak,
              breakMinutes: preset.breakMinutes,
            );
          }),
          ...settings.customClassPresets.asMap().entries.map((entry) {
            final preset = entry.value;
            return _ClassPresetTile(
              name: preset.name,
              warmUp: preset.warmUpCount,
              early: preset.earlyStudyCount,
              mid: preset.midStudyCount,
              finalCount: preset.finalStudyCount,
              hasBreak: preset.hasBreak,
              breakMinutes: preset.breakMinutes,
              isCustom: true,
              onEdit: () => _showEditPresetDialog(context, ref, entry.key, preset),
              onDelete: () => notifier.removeCustomClassPreset(entry.key),
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.add, color: AppTheme.royalBlue, size: 18),
              label: const Text(
                'Add Custom Class',
                style: TextStyle(color: AppTheme.royalBlue),
              ),
              onPressed: () => _showEditPresetDialog(context, ref, -1, null),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.restore, color: Colors.white54),
              label: const Text(
                'Reset to Defaults',
                style: TextStyle(color: Colors.white54),
              ),
              onPressed: () => notifier.resetToDefaults(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.royalBlueLight,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF12121F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.royalBlue.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFB0B0C8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ClassPresetTile extends StatelessWidget {
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

  const _ClassPresetTile({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF12121F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.royalBlue.withValues(alpha: 0.08),
          width: 0.5,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$warmUp warm-up, $early early, $mid mid, $finalCount final ($total total)${hasBreak ? ', break at img ${(total/2).floor() + 1}' : ''}',
                  style: const TextStyle(
                    color: Colors.white54,
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
    );
  }
}

Future<void> _showEditPresetDialog(
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
          title: Text(existingPreset == null ? 'Add Custom Class' : 'Edit Class'),
          content: SizedBox(
            width: 380,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Class Name',
                      hintText: 'e.g., Quick 15 Min',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NumberInputRow(label: 'Warm-up (30s)', value: warmUp, onChanged: (v) => setState(() => warmUp = v)),
                  _NumberInputRow(label: 'Early Study (1m)', value: early, onChanged: (v) => setState(() => early = v)),
                  _NumberInputRow(label: 'Mid Study (5m)', value: mid, onChanged: (v) => setState(() => mid = v)),
                  _NumberInputRow(label: 'Final Study (10m)', value: finalCount, onChanged: (v) => setState(() => finalCount = v)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Checkbox(value: hasBreak, onChanged: (v) => setState(() => hasBreak = v ?? false)),
                      const Text('Break'),
                      if (hasBreak) ...[
                        SizedBox(
                          width: 75,
                          child: DropdownButton<int>(
                            value: breakMinutes,
                            isDense: true,
                            items: [3, 5, 10, 15].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                            onChanged: (v) { if (v != null) setState(() => breakMinutes = v); },
                          ),
                        ),
                        const Text('at img'),
                        SizedBox(
                          width: 50,
                          height: 32,
                          child: TextField(
                            controller: breakAfterController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
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
                  const SizedBox(height: 8),
                  Center(child: Text('Total: $totalImages images', style: const TextStyle(color: AppTheme.royalBlue))),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
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

class _AudioModeTile extends StatelessWidget {
  final AudioMode currentMode;
  final ValueChanged<AudioMode> onChanged;

  const _AudioModeTile({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF12121F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.royalBlue.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AudioMode.values.map((mode) {
          final isSelected = mode == currentMode;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: InkWell(
              onTap: () => onChanged(mode),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppTheme.royalBlue : Colors.white54,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        Text(
                          mode.description,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NumberInputRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberInputRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 32,
            child: Text('$value', textAlign: TextAlign.center),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => onChanged(value + 1),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
