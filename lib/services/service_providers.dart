import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'window_service.dart';
import 'clipboard_service.dart';
import 'file_service.dart';
import 'audio_service.dart';

final windowServiceProvider = Provider((ref) => WindowService());
final clipboardServiceProvider = Provider((ref) => ClipboardService());
final fileServiceProvider = Provider((ref) => FileService());
final audioServiceProvider = Provider((ref) => AudioService());
