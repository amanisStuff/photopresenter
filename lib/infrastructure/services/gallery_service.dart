import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../core/entities/gallery_manifest.dart';

class GalleryService {
  static const _uuid = Uuid();
  static const _galleriesDirName = 'galleries';

  Future<Directory> get _galleriesDir async {
    final appData = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appData.path, _galleriesDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<GalleryManifest> saveGallery({
    required String name,
    required List<String> imagePaths,
    required List<String> audioPaths,
    String user = 'Local User',
  }) async {
    if (imagePaths.isEmpty && audioPaths.isEmpty) {
      throw Exception('Cannot save gallery with no images or audio');
    }

    final galleriesDir = await _galleriesDir;
    final galleryId = _uuid.v4();
    final galleryDir = Directory(p.join(galleriesDir.path, galleryId));
    await galleryDir.create(recursive: true);

    final imagesDir = Directory(p.join(galleryDir.path, 'images'));
    final audiosDir = Directory(p.join(galleryDir.path, 'audios'));
    await imagesDir.create();
    await audiosDir.create();

    final savedImagePaths = <String>[];
    for (final srcPath in imagePaths) {
      final file = File(srcPath);
      if (await file.exists()) {
        final destPath = p.join(imagesDir.path, p.basename(srcPath));
        await file.copy(destPath);
        savedImagePaths.add(destPath);
      }
    }

    final savedAudioPaths = <String>[];
    for (final srcPath in audioPaths) {
      final file = File(srcPath);
      if (await file.exists()) {
        final destPath = p.join(audiosDir.path, p.basename(srcPath));
        await file.copy(destPath);
        savedAudioPaths.add(destPath);
      }
    }

    final manifest = GalleryManifest(
      id: galleryId,
      name: name,
      user: user,
      createdAt: DateTime.now(),
      imageCount: savedImagePaths.length,
      audioCount: savedAudioPaths.length,
      imagePaths: savedImagePaths,
      audioPaths: savedAudioPaths,
    );

    final manifestFile = File(p.join(galleryDir.path, 'gallery.json'));
    await manifestFile.writeAsString(jsonEncode(manifest.toJson()));

    return manifest;
  }

  Future<List<GalleryManifest>> listGalleries() async {
    final galleriesDir = await _galleriesDir;
    if (!await galleriesDir.exists()) return [];

    final manifests = <GalleryManifest>[];
    final dirs = await galleriesDir.list().toList();

    for (final entry in dirs) {
      if (entry is Directory) {
        final manifestFile = File(p.join(entry.path, 'gallery.json'));
        if (await manifestFile.exists()) {
          final content = await manifestFile.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          manifests.add(GalleryManifest.fromJson(json));
        }
      }
    }

    manifests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return manifests;
  }

  Future<GalleryManifest> loadGallery(String id) async {
    final galleriesDir = await _galleriesDir;
    final galleryDir = Directory(p.join(galleriesDir.path, id));
    final manifestFile = File(p.join(galleryDir.path, 'gallery.json'));

    if (!await manifestFile.exists()) {
      throw Exception('Gallery not found: $id');
    }

    final content = await manifestFile.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    return GalleryManifest.fromJson(json);
  }

  Future<void> deleteGallery(String id) async {
    final galleriesDir = await _galleriesDir;
    final galleryDir = Directory(p.join(galleriesDir.path, id));

    if (await galleryDir.exists()) {
      await galleryDir.delete(recursive: true);
    }
  }
}
