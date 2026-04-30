import 'dart:typed_data';
import 'package:pasteboard/pasteboard.dart';

/// Service for handling clipboard operations, specifically image and file pastes.
class ClipboardService {
  /// Retrieves image data from the clipboard.
  ///
  /// Returns [Uint8List] if an image is found, otherwise null.
  Future<Uint8List?> getClipboardImage() async {
    return await Pasteboard.image;
  }

  /// Retrieves file paths from the clipboard.
  ///
  /// Supports multi-file paste (e.g. from File Explorer).
  Future<List<String>> getClipboardFiles() async {
    return await Pasteboard.files();
  }

  /// Checks if the clipboard contains images or files.
  Future<bool> hasRelevantData() async {
    final files = await getClipboardFiles();
    if (files.isNotEmpty) return true;
    final image = await getClipboardImage();
    return image != null;
  }
}
