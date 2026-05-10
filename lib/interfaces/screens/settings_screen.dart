import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_tile.dart';
import '../widgets/class_preset_tile.dart';
import '../widgets/audio_mode_tile.dart';
import '../widgets/edit_preset_dialog.dart';
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textOnDarkMedium),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: AppTheme.textOnDark, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          SectionHeader(title: 'Timer'),
          SettingsTile(
            title: 'Default Timer Duration',
            subtitle: '${settings.timerDurationSeconds} seconds',
            trailing: DropdownButton<int>(
              value: settings.timerDurationSeconds,
              dropdownColor: AppTheme.surfaceDropdown,
              underline: const SizedBox(),
              style: const TextStyle(color: AppTheme.textOnDarkMedium, fontSize: 13),
              items: AppSettings.timerOptions.map((val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    val < 60 ? '${val}s' : '${val ~/ 60}min',
                    style: const TextStyle(color: AppTheme.textOnDarkMedium),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.setTimerDuration(val);
              },
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Audio'),
          SettingsTile(
            title: 'Auto-play Audio',
            subtitle: 'Play audio when slideshow starts',
            trailing: Switch(
              value: settings.autoPlayAudio,
              onChanged: notifier.setAutoPlayAudio,
              activeThumbColor: AppTheme.success,
              activeTrackColor: AppTheme.success.withValues(alpha: 0.3),
            ),
          ),
          SettingsTile(
            title: 'Sound on Transition',
            subtitle: 'Play sound when moving to next image',
            trailing: Switch(
              value: settings.soundOnTransition,
              onChanged: notifier.setSoundOnTransition,
              activeThumbColor: AppTheme.primary,
              activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Display'),
          SettingsTile(
            title: 'Show Image Info',
            subtitle: 'Display image name and count',
            trailing: Switch(
              value: settings.showImageInfo,
              onChanged: notifier.setShowImageInfo,
              activeThumbColor: AppTheme.primary,
              activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Audio Mode'),
          AudioModeTile(
            currentMode: settings.audioMode,
            onChanged: notifier.setAudioMode,
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Behavior'),
          SettingsTile(
            title: 'Confirm on Close',
            subtitle: 'Ask before closing the app',
            trailing: Switch(
              value: settings.confirmOnClose,
              onChanged: notifier.setConfirmOnClose,
              activeThumbColor: AppTheme.primary,
              activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Pause Between Images'),
          SettingsTile(
            title: 'Auto-pause duration',
            subtitle: settings.pauseBetweenImagesSeconds == 0
                ? 'Disabled'
                : '${settings.pauseBetweenImagesSeconds} seconds pause between images',
            trailing: DropdownButton<int>(
              value: settings.pauseBetweenImagesSeconds,
              dropdownColor: AppTheme.surfaceDropdown,
              underline: const SizedBox(),
              style: const TextStyle(color: AppTheme.textOnDarkMedium, fontSize: 13),
              items: AppSettings.pauseOptions.map((val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(
                    val == 0 ? 'Off' : '${val}s',
                    style: const TextStyle(color: AppTheme.textOnDarkMedium),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) notifier.setPauseBetweenImages(val);
              },
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Class Mode Presets'),
          ...ClassPreset.defaultPresets.asMap().entries.map((entry) {
            final preset = entry.value;
            return ClassPresetTile(
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
            return ClassPresetTile(
              name: preset.name,
              warmUp: preset.warmUpCount,
              early: preset.earlyStudyCount,
              mid: preset.midStudyCount,
              finalCount: preset.finalStudyCount,
              hasBreak: preset.hasBreak,
              breakMinutes: preset.breakMinutes,
              isCustom: true,
              onEdit: () => showEditPresetDialog(context, ref, entry.key, preset),
              onDelete: () => notifier.removeCustomClassPreset(entry.key),
            );
          }),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.add, color: AppTheme.primary, size: 18),
              label: const Text(
                'Add Custom Class',
                style: TextStyle(color: AppTheme.primary),
              ),
              onPressed: () => showEditPresetDialog(context, ref, -1, null),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.restore, color: AppTheme.textOnDarkSubtle),
              label: const Text(
                'Reset to Defaults',
                style: TextStyle(color: AppTheme.textOnDarkSubtle),
              ),
              onPressed: () => notifier.resetToDefaults(),
            ),
          ),
        ],
      ),
    );
  }
}
