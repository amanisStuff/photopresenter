import 'dart:io';
import 'package:file_picker/file_picker.dart';

/// Service for picking image files from the local filesystem.
class FileService {
  /// Opens a file picker to select multiple images.
  ///
  /// Filters for common image extensions.
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

  /// Opens a file picker to select a single audio file.
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

  /// Opens a file picker to select multiple audio files.
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

  /// Opens a directory picker and exports images to the selected location.
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
}
