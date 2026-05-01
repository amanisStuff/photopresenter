import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'providers/settings_provider.dart';
import 'models/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
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
              activeColor: Colors.blueAccent,
            ),
          ),
          _SettingsTile(
            title: 'Sound on Transition',
            subtitle: 'Play sound when moving to next image',
            trailing: Switch(
              value: settings.soundOnTransition,
              onChanged: notifier.setSoundOnTransition,
              activeColor: Colors.blueAccent,
            ),
          ),
          if (settings.soundOnTransition)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SoundPickerTile(
                soundPath: settings.transitionSoundPath,
                onPick: () async {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['wav', 'mp3', 'ogg'],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    notifier.setTransitionSoundPath(result.files.first.path);
                  }
                },
                onClear: () => notifier.setTransitionSoundPath(null),
              ),
            ),
          _SettingsTile(
            title: 'Default Volume',
            subtitle: '${(settings.defaultVolume * 100).toInt()}%',
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: settings.defaultVolume,
                min: 0.0,
                max: 1.0,
                activeColor: Colors.blueAccent,
                inactiveColor: Colors.white24,
                onChanged: notifier.setDefaultVolume,
              ),
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
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Behavior'),
          _SettingsTile(
            title: 'Confirm on Close',
            subtitle: 'Ask before closing the app',
            trailing: Switch(
              value: settings.confirmOnClose,
              onChanged: notifier.setConfirmOnClose,
              activeColor: Colors.blueAccent,
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
          color: Colors.blueAccent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
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
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
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
                    color: Colors.white54,
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

class _SoundOnTransitionSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SoundOnTransitionSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
        ),
        if (value)
          Tooltip(
            message: 'Create assets/beep.wav or add to pubspec.yaml',
            child: const Icon(Icons.info_outline, size: 14, color: Colors.orange),
          ),
      ],
    );
  }
}

class _SoundPickerTile extends StatelessWidget {
  final String? soundPath;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _SoundPickerTile({
    required this.soundPath,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = soundPath?.split('/').last ?? 'Default (beep.wav)';
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, size: 18, color: Colors.white54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onPick,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Browse', style: TextStyle(fontSize: 12)),
          ),
          if (soundPath != null)
            IconButton(
              icon: const Icon(Icons.clear, size: 16),
              onPressed: onClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: Colors.white54,
            ),
        ],
      ),
    );
  }
}