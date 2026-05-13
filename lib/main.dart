import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme.dart';
import 'shared/theme/theme_notifier.dart';
import 'shared/theme/theme_mode.dart';
import 'shared/theme/theme_composition.dart';
import 'infrastructure/services/window_service.dart';
import 'interfaces/screens/presentation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final windowService = WindowService();
  await windowService.initialize();

  runApp(const ProviderScope(child: PhotoPresenterApp()));
}

class PhotoPresenterApp extends ConsumerWidget {
  const PhotoPresenterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always watch to ensure rebuilds when theme changes.
    final themeStyle = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final mode = notifier.mode;
    final palette = notifier.paletteChoice;
    final style = notifier.styleChoice;
    final font = notifier.fontConfig;

    final effectiveStyle = mode == ThemeModeChoice.system
        ? notifier.resolve(MediaQuery.platformBrightnessOf(context))
        : themeStyle;

    AppTheme.setCurrent(effectiveStyle);

    return MaterialApp(
      key: ValueKey('${mode.name}_${palette.name}_${style.name}_${font.fontFamily}_${font.baseScale}'),
      title: 'PhotoPresenter',
      debugShowCheckedModeBanner: false,
      themeMode: mode == ThemeModeChoice.system
          ? ThemeMode.system
          : (mode == ThemeModeChoice.dark ? ThemeMode.dark : ThemeMode.light),
      theme: effectiveStyle.themeData,
      darkTheme: (effectiveStyle as ComposedThemeStyle).themeDataFor(Brightness.dark),
      home: const PresentationScreen(),
    );
  }
}
