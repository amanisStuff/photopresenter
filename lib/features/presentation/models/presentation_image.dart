import 'dart:typed_data';

enum ImageSource { file, memory, network }

/// Represents an image in the presentation.
class PresentationImage {
  final String id;
  final String? path;
  final Uint8List? bytes;
  final String? url;
  final ImageSource source;
  final String name;

  PresentationImage({
    required this.id,
    this.path,
    this.bytes,
    this.url,
    required this.source,
    required this.name,
  });

  factory PresentationImage.fromPath(String path) {
    return PresentationImage(
      id: path,
      path: path,
      source: ImageSource.file,
      name: path.split(r'\').last.split('/').last,
    );
  }

  factory PresentationImage.fromBytes(Uint8List bytes, String name) {
    return PresentationImage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bytes: bytes,
      source: ImageSource.memory,
      name: name,
    );
  }

  factory PresentationImage.fromUrl(String url) {
    final fileName = url.split('?').first.split('/').last;
    return PresentationImage(
      id: url,
      url: url,
      source: ImageSource.network,
      name: fileName.isNotEmpty ? fileName : url,
    );
  }
}
