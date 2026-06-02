import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class VideoService {
  static const int _maxFrames = 1000;
  static const _ffmpegCandidates = ['ffmpeg', '_ffmpeg'];
  static const _ffprobeCandidates = ['ffprobe', '_ffprobe'];

  String? _ffmpegExecutable;
  String? _ffprobeExecutable;

  Future<bool> isFfmpegAvailable() async {
    if (_ffmpegExecutable != null) return true;

    for (final name in _ffmpegCandidates) {
      try {
        final result = await Process.run(name, ['-version']);
        if (result.exitCode == 0) {
          _ffmpegExecutable = name;
          break;
        }
      } catch (_) {}
    }

    for (final name in _ffprobeCandidates) {
      try {
        final result = await Process.run(name, ['-version']);
        if (result.exitCode == 0) {
          _ffprobeExecutable = name;
          break;
        }
      } catch (_) {}
    }

    return _ffmpegExecutable != null;
  }

  Future<double?> probeVideoDurationSeconds(String videoPath) async {
    final ffprobe = _ffprobeExecutable;
    if (ffprobe == null) return null;

    try {
      final result = await Process.run(ffprobe, [
        '-v',
        'quiet',
        '-print_format',
        'json',
        '-show_format',
        videoPath,
      ]);
      if (result.exitCode != 0) return null;
      final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      final format = json['format'] as Map<String, dynamic>?;
      if (format == null) return null;
      final durationStr = format['duration'] as String?;
      if (durationStr == null) return null;
      return double.tryParse(durationStr);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> extractFrames({
    required String videoPath,
    required int intervalSeconds,
    required String outputDir,
    void Function(int framesExtracted)? onProgress,
  }) async {
    final ffmpeg = _ffmpegExecutable;
    if (ffmpeg == null) {
      throw Exception(
        'FFmpeg not found. Tried: ${_ffmpegCandidates.join(', ')}',
      );
    }

    await Directory(outputDir).create(recursive: true);

    final outputPattern = p.join(outputDir, 'frame_%04d.png');
    final args = [
      '-i',
      videoPath,
      '-vf',
      'fps=1/$intervalSeconds',
      '-frames:v',
      '$_maxFrames',
      outputPattern,
    ];

    final process = await Process.start(ffmpeg, args);

    final stderrLines = <String>[];
    final stderrCompleter = Completer<void>();

    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            stderrLines.add(line);
            final frameMatch = RegExp(r'^frame=\s*(\d+)').firstMatch(line);
            if (frameMatch != null) {
              final frameCount = int.tryParse(frameMatch.group(1)!) ?? 0;
              onProgress?.call(frameCount);
            }
          },
          onDone: () => stderrCompleter.complete(),
          onError: (e) => stderrCompleter.completeError(e),
        );

    process.stdout.transform(utf8.decoder).listen((_) {});

    final exitCode = await process.exitCode;
    await stderrCompleter.future;

    if (exitCode != 0) {
      throw Exception(
        'FFmpeg exited with code $exitCode\n${stderrLines.join('\n')}',
      );
    }

    final dir = Directory(outputDir);
    final files = await dir.list().toList();
    files.sort((a, b) => a.path.compareTo(b.path));

    return files
        .whereType<File>()
        .map((f) => f.path)
        .where((path) => path.endsWith('.png'))
        .toList();
  }

  Future<void> cleanupDir(String dirPath) async {
    final dir = Directory(dirPath);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
