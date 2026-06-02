import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileService {
  Future<List<String>> pickImages() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      return result.paths.whereType<String>().toList();
    }
    return [];
  }

  Future<String?> pickVideo() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm',
      ],
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path;
    }
    return null;
  }

  Future<String?> pickAudio() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac'],
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first.path;
    }
    return null;
  }

  Future<List<String>> pickAudioFiles() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a', 'aac'],
    );

    if (result != null) {
      return result.paths.whereType<String>().toList();
    }
    return [];
  }

  Future<String?> exportImages(
      List<MapEntry<String, String>> imagesWithNames) async {
    String? directoryPath = await FilePicker.getDirectoryPath();

    if (directoryPath == null) return null;

    int savedCount = 0;
    for (final entry in imagesWithNames) {
      final sourcePath = entry.key;
      final fileName = entry.value;
      final sourceFile = File(sourcePath);

      if (await sourceFile.exists()) {
        final extension = sourcePath.split('.').last;
        final destPath = '$directoryPath/$fileName.$extension';
        await sourceFile.copy(destPath);
        savedCount++;
      }
    }

    return '$savedCount images saved to $directoryPath';
  }

  Future<String?> saveGallery({
    required String galleryName,
    required List<MapEntry<String, String>> imagePaths,
    required int timerDurationSeconds,
    List<String>? audioPaths,
  }) async {
    String? directoryPath = await FilePicker.getDirectoryPath();
    if (directoryPath == null) return null;

    final galleryDir = '$directoryPath/$galleryName';
    await Directory(galleryDir).create(recursive: true);

    final futures = <Future>[];
    final savedNames = <String>[];

    for (final entry in imagePaths) {
      final sourcePath = entry.key;
      final fileName = entry.value;
      final extension = sourcePath.split('.').last;
      final destPath = '$galleryDir/$fileName.$extension';
      futures.add(_copyIfExists(sourcePath, destPath).then((_) => savedNames.add(fileName)));
    }

    final audioFileNames = <String>[];
    if (audioPaths != null) {
      for (final audioPath in audioPaths) {
        final fileName = audioPath.split('/').last;
        final destPath = '$galleryDir/$fileName';
        futures.add(_copyIfExists(audioPath, destPath).then((_) => audioFileNames.add(fileName)));
      }
    }

    await Future.wait(futures);

    final manifest = {
      'name': galleryName,
      'timerDuration': timerDurationSeconds,
      'images': savedNames,
      if (audioFileNames.isNotEmpty) 'audio': audioFileNames,
    };

    await File('$galleryDir/gallery.json').writeAsString(
      JsonEncoder.withIndent('  ').convert(manifest),
    );

    return '${savedNames.length} images saved to $galleryDir';
  }

  Future<String?> savePlaylist({
    required String playlistName,
    required List<String> audioPaths,
  }) async {
    if (audioPaths.isEmpty) return 'No audio files to save';

    String? directoryPath = await FilePicker.getDirectoryPath();
    if (directoryPath == null) return null;

    final playlistDir = '$directoryPath/$playlistName';
    await Directory(playlistDir).create(recursive: true);

    final futures = <Future>[];
    final savedNames = <String>[];

    for (final audioPath in audioPaths) {
      final fileName = audioPath.split('/').last;
      final destPath = '$playlistDir/$fileName';
      futures.add(_copyIfExists(audioPath, destPath).then((_) => savedNames.add(fileName)));
    }

    await Future.wait(futures);

    final manifest = {
      'name': playlistName,
      'audio': savedNames,
    };

    await File('$playlistDir/playlist.json').writeAsString(
      JsonEncoder.withIndent('  ').convert(manifest),
    );

    return '${savedNames.length} audio files saved to $playlistDir';
  }

  Future<void> _copyIfExists(String source, String dest) async {
    final file = File(source);
    if (await file.exists()) await file.copy(dest);
  }

  Future<Map<String, dynamic>?> loadGalleryManifest(String dirPath) async {
    final manifestFile = File('$dirPath/gallery.json');
    if (!await manifestFile.exists()) return null;

    final content = await manifestFile.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> pickAndLoadGallery() async {
    String? directoryPath = await FilePicker.getDirectoryPath();
    if (directoryPath == null) return null;
    return await loadGalleryManifest(directoryPath);
  }

  Future<Map<String, dynamic>?> pickAndLoadPlaylist() async {
    String? directoryPath = await FilePicker.getDirectoryPath();
    if (directoryPath == null) return null;
    final manifestFile = File('$directoryPath/playlist.json');
    if (!await manifestFile.exists()) return null;
    final content = await manifestFile.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<String?> saveRenderedImage(List<int> bytes, String fileName) async {
    String? directoryPath = await FilePicker.getDirectoryPath();
    if (directoryPath == null) return null;

    final filePath = '$directoryPath/$fileName';
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }
}
