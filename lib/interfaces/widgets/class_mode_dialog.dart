import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme.dart';
import '../../core/providers/presentation_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/entities/class_session.dart';
import '../../core/entities/app_settings.dart';

class PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PresetButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class PhaseConfigRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const PhaseConfigRow({
    super.key,
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
          Expanded(flex: 2, child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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

class ClassModeSelectionDialog extends StatefulWidget {
  final List<ClassPreset> customPresets;
  final Function(ClassLength) onSelectPreset;
  final Function(ClassConfig) onSelectCustom;

  const ClassModeSelectionDialog({
    super.key,
    this.customPresets = const [],
    required this.onSelectPreset,
    required this.onSelectCustom,
  });

  @override
  State<ClassModeSelectionDialog> createState() =>
      _ClassModeSelectionDialogState();
}

class _ClassModeSelectionDialogState extends State<ClassModeSelectionDialog> {
  int _warmUpCount = 4;
  int _earlyCount = 4;
  int _midCount = 2;
  int _finalCount = 1;
  bool _hasBreak = false;
  int _breakMinutes = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Class Mode'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Start',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PresetButton(
                    label: '30 Min (11 img)',
                    onTap: () =>
                        widget.onSelectPreset(ClassLength.thirtyMinutes),
                  ),
                  PresetButton(
                    label: '60 Min (18 img)',
                    onTap: () =>
                        widget.onSelectPreset(ClassLength.sixtyMinutes),
                  ),
                  ...widget.customPresets.map(
                    (preset) => PresetButton(
                      label: '${preset.name} (${preset.totalImages} img)',
                      onTap: () {
                        final config = ClassConfig(
                          length: ClassLength.custom,
                          warmUpCount: preset.warmUpCount,
                          earlyStudyCount: preset.earlyStudyCount,
                          midStudyCount: preset.midStudyCount,
                          finalStudyCount: preset.finalStudyCount,
                          hasBreak: preset.hasBreak,
                          breakMinutes: preset.breakMinutes,
                        );
                        widget.onSelectCustom(config);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Custom Configuration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              PhaseConfigRow(
                label: 'Warm-up (30s)',
                value: _warmUpCount,
                onChanged: (val) => setState(() => _warmUpCount = val),
              ),
              PhaseConfigRow(
                label: 'Early Study (1m)',
                value: _earlyCount,
                onChanged: (val) => setState(() => _earlyCount = val),
              ),
              PhaseConfigRow(
                label: 'Mid Study (5m)',
                value: _midCount,
                onChanged: (val) => setState(() => _midCount = val),
              ),
              PhaseConfigRow(
                label: 'Final Study (10m)',
                value: _finalCount,
                onChanged: (val) => setState(() => _finalCount = val),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _hasBreak,
                    onChanged: (val) =>
                        setState(() => _hasBreak = val ?? false),
                  ),
                  const Text('Include break'),
                  if (_hasBreak) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: DropdownButton<int>(
                        value: _breakMinutes,
                        isDense: true,
                        items: [3, 5, 10]
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text('$m min'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _breakMinutes = val);
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.royalBlue.withValues(alpha: 0.12),
                      AppTheme.royalBlueDark.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.royalBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      color: AppTheme.royalBlueLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Images needed: ${_warmUpCount + _earlyCount + _midCount + _finalCount}',
                      style: const TextStyle(
                        color: AppTheme.royalBlueLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final config = ClassConfig(
              length: ClassLength.custom,
              warmUpCount: _warmUpCount,
              earlyStudyCount: _earlyCount,
              midStudyCount: _midCount,
              finalStudyCount: _finalCount,
              hasBreak: _hasBreak,
              breakMinutes: _breakMinutes,
            );
            widget.onSelectCustom(config);
          },
          child: const Text('Start Class'),
        ),
      ],
    );
  }
}

Future<void> showClassModeDialog(BuildContext context, WidgetRef ref) async {
  final notifier = ref.read(presentationProvider.notifier);
  final state = ref.read(presentationProvider);

  if (state.isClassMode) {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Class Mode?'),
        content: const Text(
          'Are you sure you want to stop the current class session?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop'),
          ),
        ],
      ),
    );
    if (shouldStop == true) {
      notifier.stopClassMode();
    }
    return;
  }

  if (state.images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please add images before starting Class Mode'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  final settings = ref.read(settingsProvider);

  await showDialog<void>(
    context: context,
    builder: (context) => ClassModeSelectionDialog(
      customPresets: settings.customClassPresets,
      onSelectPreset: (preset) {
        final config = ClassConfig.fromPreset(preset);
        final queue = config.generatePhaseQueue();
        if (queue.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please configure class settings first'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        notifier.startClassMode(config);
        Navigator.pop(context);
      },
      onSelectCustom: (config) {
        final queue = config.generatePhaseQueue();
        if (queue.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please configure class settings first'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        notifier.startClassMode(config);
        Navigator.pop(context);
      },
    ),
  );
}
