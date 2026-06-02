import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../shared/theme.dart';
import '../../../core/providers/presentation_provider.dart';
import '../../../infrastructure/service_providers.dart';
import '../../../infrastructure/services/video_service.dart';
import '../../../infrastructure/services/file_service.dart';
import 'package:uuid/uuid.dart';
import '../common/number_input_row.dart';

const _uuid = Uuid();

Future<void> showAddVideoDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final videoService = ref.read(videoServiceProvider);
  final ffmpegAvailable = await videoService.isFfmpegAvailable();

  if (!context.mounted) return;

  if (!ffmpegAvailable) {
    await _showFfmpegNoticeDialog(context);
    return;
  }

  await _showExtractionDialog(context, ref);
}

Future<void> _showFfmpegNoticeDialog(BuildContext context) async {
  final isLinux = Platform.isLinux;
  final installCommand = isLinux
      ? 'sudo apt-get install ffmpeg'
      : 'Install FFmpeg from https://ffmpeg.org';

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppTheme.surfaceOverlay,
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppTheme.primaryLight, size: 24),
          const SizedBox(width: 8),
          Text('FFmpeg Required', style: AppTheme.dialogTitleStyle),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'FFmpeg is needed to extract frames from video files.',
              style: AppTheme.infoTextStyle,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Install it and restart the app:',
                    style: AppTheme.inputLabelStyle,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    installCommand,
                    style: AppTheme.textFieldInputStyle.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Got it', style: AppTheme.actionTextStyle),
        ),
      ],
    ),
  );
}

Future<void> _showExtractionDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final videoService = ref.read(videoServiceProvider);
  final notifier = ref.read(presentationProvider.notifier);
  final fileService = ref.read(fileServiceProvider);

  await showDialog<void>(
    context: context,
    builder: (context) => _ExtractionDialogContent(
      videoService: videoService,
      fileService: fileService,
      notifier: notifier,
    ),
  );
}

class _ExtractionDialogContent extends StatefulWidget {
  final VideoService videoService;
  final FileService fileService;
  final PresentationNotifier notifier;

  const _ExtractionDialogContent({
    required this.videoService,
    required this.fileService,
    required this.notifier,
  });

  @override
  State<_ExtractionDialogContent> createState() =>
      _ExtractionDialogContentState();
}

class _ExtractionDialogContentState extends State<_ExtractionDialogContent> {
  String? _videoPath;
  String? _videoFileName;
  int _intervalSeconds = 5;
  double? _durationSeconds;
  bool _extracting = false;
  double _progress = 0;
  String? _error;

  int get _estimatedFrameCount {
    if (_durationSeconds == null || _durationSeconds! <= 0) return 0;
    final count = (_durationSeconds! / _intervalSeconds).ceil();
    return count > 1000 ? 1000 : count;
  }

  Future<void> _pickVideo() async {
    final path = await widget.fileService.pickVideo();
    if (path == null) return;

    final duration =
        await widget.videoService.probeVideoDurationSeconds(path);

    if (!mounted) return;
    setState(() {
      _videoPath = path;
      _videoFileName = p.basename(path);
      _durationSeconds = duration;
      _error = null;
      _progress = 0;
    });
  }

  Future<void> _extractAndAdd() async {
    if (_videoPath == null) return;

    setState(() {
      _extracting = true;
      _error = null;
      _progress = 0;
    });

    final appDir = await getApplicationDocumentsDirectory();
    final outputDir = p.join(
      appDir.path,
      '.temp_video_frames',
      _uuid.v4(),
    );

    try {
      final paths = await widget.videoService.extractFrames(
        videoPath: _videoPath!,
        intervalSeconds: _intervalSeconds,
        outputDir: outputDir,
        onProgress: (frames) {
          if (!mounted) return;
          final total = _estimatedFrameCount;
          setState(() {
            _progress = total > 0 ? frames / total : 0;
          });
        },
      );

      if (paths.isEmpty) {
        setState(() {
          _error = 'No frames were extracted from the video';
          _extracting = false;
        });
        return;
      }

      widget.notifier.addImages(paths);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${paths.length} snapshots added from "$_videoFileName"',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _extracting = false;
      });
    } finally {
      await widget.videoService.cleanupDir(outputDir);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceOverlay,
      title: Row(
        children: [
          Icon(Icons.videocam, color: AppTheme.primaryLight, size: 24),
          const SizedBox(width: 8),
          Text('Add Video Snapshots', style: AppTheme.dialogTitleStyle),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _videoFileName ?? 'Select a video file...',
                        style: AppTheme.textFieldInputStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _extracting ? null : _pickVideo,
                      icon: const Icon(Icons.folder_open, size: 16),
                      label: const Text('Browse'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NumberInputRow(
                label: 'Interval (seconds)',
                value: _intervalSeconds,
                onChanged: (v) {
                  setState(() => _intervalSeconds = v < 1 ? 1 : v);
                },
              ),
              if (_videoPath != null && _durationSeconds != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '~$_estimatedFrameCount frames',
                        style: AppTheme.infoTextStyle,
                      ),
                      if (_estimatedFrameCount >= 1000) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(max)',
                          style: AppTheme.infoTextStyle.copyWith(
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (_extracting) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor:
                      AppTheme.surfaceMuted.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryLight),
                ),
                const SizedBox(height: 8),
                Text(
                  'Extracting frames...',
                  style: AppTheme.infoTextStyle,
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _error!,
                    style: AppTheme.errorTextStyle.copyWith(fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _extracting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTheme.cancelActionStyle),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textOnDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onPressed:
              _videoPath != null && !_extracting ? _extractAndAdd : null,
          child: const Text('Extract & Add'),
        ),
      ],
    );
  }
}
