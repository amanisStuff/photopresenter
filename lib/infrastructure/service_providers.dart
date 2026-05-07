import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/window_service.dart';
import 'services/clipboard_service.dart';
import 'services/file_service.dart';
import 'services/audio_service.dart';
import 'services/gallery_service.dart';

final windowServiceProvider = Provider((ref) => WindowService());
final clipboardServiceProvider = Provider((ref) => ClipboardService());
final fileServiceProvider = Provider((ref) => FileService());
final audioServiceProvider = Provider((ref) => AudioService());
final galleryServiceProvider = Provider((ref) => GalleryService());
