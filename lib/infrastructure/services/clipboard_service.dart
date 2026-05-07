import 'dart:typed_data';
import 'package:pasteboard/pasteboard.dart';

class ClipboardService {
  Future<Uint8List?> getClipboardImage() async {
    return await Pasteboard.image;
  }

  Future<List<String>> getClipboardFiles() async {
    return await Pasteboard.files();
  }

  Future<bool> hasRelevantData() async {
    final files = await getClipboardFiles();
    if (files.isNotEmpty) return true;
    final image = await getClipboardImage();
    return image != null;
  }
}
