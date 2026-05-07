import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme.dart';
import 'infrastructure/services/window_service.dart';
import 'interfaces/screens/presentation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final windowService = WindowService();
  await windowService.initialize();

  runApp(const ProviderScope(child: PhotoPresenterApp()));
}

class PhotoPresenterApp extends StatelessWidget {
  const PhotoPresenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoPresenter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const PresentationScreen(),
    );
  }
}
