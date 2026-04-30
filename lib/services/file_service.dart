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
}
