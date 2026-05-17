import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/common/section_header.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/class_preset_tile.dart';
import '../widgets/settings/audio_mode_tile.dart';
import '../widgets/common/retro_switch.dart';
import '../widgets/dialogs/edit_preset_dialog.dart';
import '../../shared/theme.dart';
import '../../shared/theme/theme_mode.dart';
import '../../shared/theme/theme_choices.dart';
import '../../shared/theme/theme_notifier.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/entities/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeMode = ref.watch(themeProvider.notifier).mode;
    final paletteChoice = ref.watch(themeProvider.notifier).paletteChoice;
    final styleChoice = ref.watch(themeProvider.notifier).styleChoice;
    final fontConfig = ref.watch(themeProvider.notifier).fontConfig;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: AppTheme.controlsBar),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        decoration: AppTheme.settingsBackground,
        child: ListView(
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
                style: AppTheme.dropdownTextStyle,
                items: AppSettings.timerOptions.map((val) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(
                      val < 60 ? '${val}s' : '${val ~/ 60}min',
                      style: AppTheme.dropdownItemStyle,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) notifier.setTimerDuration(val);
                },
              ),
            ),
const SizedBox(height: 24),
             SectionHeader(title: 'Theme'),
             SettingsTile(
               title: 'Theme Mode',
               subtitle: themeMode.label,
               trailing: DropdownButton<ThemeModeChoice>(
                 value: themeMode,
                 dropdownColor: AppTheme.surfaceDropdown,
                 underline: const SizedBox(),
                 style: AppTheme.dropdownTextStyle,
                 items: ThemeModeChoice.values
                     .map((mode) => DropdownMenuItem(
                           value: mode,
                           child: Text(mode.label,
                               style: AppTheme.dropdownItemStyle),
                         ))
                     .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      themeNotifier.setMode(val,
                          platformBrightness:
                              MediaQuery.platformBrightnessOf(context));
                    }
                  },
               ),
              ),
              const SizedBox(height: 12),
              SettingsTile(
                title: 'Color Palette',
                subtitle: paletteChoice.label,
                trailing: DropdownButton<PaletteChoice>(
                  value: paletteChoice,
                  dropdownColor: AppTheme.surfaceDropdown,
                  underline: const SizedBox(),
                  style: AppTheme.dropdownTextStyle,
                  items: PaletteChoice.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label,
                                style: AppTheme.dropdownItemStyle),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) themeNotifier.setPalette(val);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SettingsTile(
                title: 'Panel Style',
                subtitle: styleChoice.label,
                trailing: DropdownButton<StyleChoice>(
                  value: styleChoice,
                  dropdownColor: AppTheme.surfaceDropdown,
                  underline: const SizedBox(),
                  style: AppTheme.dropdownTextStyle,
                  items: StyleChoice.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label,
                                style: AppTheme.dropdownItemStyle),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) themeNotifier.setStyle(val);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SettingsTile(
                title: 'Font Family',
                subtitle: fontConfig.fontFamily,
                trailing: DropdownButton<String>(
                  value: fontConfig.fontFamily,
                  dropdownColor: AppTheme.surfaceDropdown,
                  underline: const SizedBox(),
                  style: AppTheme.dropdownTextStyle,
                  items: FontConfig.commonFamilies
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f,
                                style: AppTheme.dropdownItemStyle),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      themeNotifier.setFontConfig(
                        fontConfig.copyWith(fontFamily: val),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SettingsTile(
                title: 'Font Scale',
                subtitle: '${(fontConfig.baseScale * 100).round()}%',
                trailing: SizedBox(
                  width: 120,
                  child: Slider(
                    value: fontConfig.baseScale,
                    min: 0.6,
                    max: 1.6,
                    divisions: 10,
                    label: '${(fontConfig.baseScale * 100).round()}%',
                    activeColor: AppTheme.success,
                    onChanged: (val) {
                      themeNotifier.setFontConfig(
                        fontConfig.copyWith(baseScale: val),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(title: 'Audio'),
            SettingsTile(
              title: 'Auto-play Audio',
              subtitle: 'Play audio when slideshow starts',
              trailing: RetroSwitch(
                value: settings.autoPlayAudio,
                onChanged: notifier.setAutoPlayAudio,
                activeColor: AppTheme.success,
              ),
            ),
            SettingsTile(
              title: 'Sound on Transition',
              subtitle: 'Play sound when moving to next image',
              trailing: RetroSwitch(
                value: settings.soundOnTransition,
                onChanged: notifier.setSoundOnTransition,
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Display'),
            SettingsTile(
              title: 'Show Image Info',
              subtitle: 'Display image name and count',
              trailing: RetroSwitch(
                value: settings.showImageInfo,
                onChanged: notifier.setShowImageInfo,
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
              trailing: RetroSwitch(
                value: settings.confirmOnClose,
                onChanged: notifier.setConfirmOnClose,
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
                style: AppTheme.dropdownTextStyle,
                items: AppSettings.pauseOptions.map((val) {
                  return DropdownMenuItem(
                    value: val,
                    child: Text(
                      val == 0 ? 'Off' : '${val}s',
                      style: AppTheme.dropdownItemStyle,
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
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Add Custom Class',
                  style: AppTheme.actionTextStyle,
                ),
                onPressed: () => showEditPresetDialog(context, ref, -1, null),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.restore),
                label: Text(
                  'Reset to Defaults',
                  style: AppTheme.subtleActionStyle,
                ),
                onPressed: () => notifier.resetToDefaults(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}