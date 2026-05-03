import 'dart:typed_data';

<<<<<<< HEAD
enum ImageSource { file, memory, network }
=======
enum ImageSource { file, memory, url }
>>>>>>> 875f604f2f2ee1f5316965b0924ccd8ef4ecfc17

/// Represents an image in the presentation.
class PresentationImage {
  final String id;
  final String? path;
  final Uint8List? bytes;
  final String? url;
  final ImageSource source;
  final String name;
  final String? url;

  PresentationImage({
    required this.id,
    this.path,
    this.bytes,
    this.url,
    required this.source,
    required this.name,
    this.url,
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
<<<<<<< HEAD
    final fileName = url.split('?').first.split('/').last;
    return PresentationImage(
      id: url,
      url: url,
      source: ImageSource.network,
      name: fileName.isNotEmpty ? fileName : url,
=======
    final uri = Uri.parse(url);
    final name = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last.split('.').first
        : 'web_image';
    return PresentationImage(
      id: url,
      path: null,
      source: ImageSource.url,
      name: name,
      url: url,
>>>>>>> 875f604f2f2ee1f5316965b0924ccd8ef4ecfc17
    );
  }
}
