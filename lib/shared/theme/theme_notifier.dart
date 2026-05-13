import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_mode.dart';
import 'theme_choices.dart';
import 'theme_style.dart';
import 'theme_composition.dart';
import 'colors.dart';
import 'typography.dart';
import 'decorations.dart';

class ThemeNotifier extends Notifier<ThemeStyle> {
  ThemeModeChoice _mode = ThemeModeChoice.system;
  PaletteChoice _paletteChoice = PaletteChoice.royalBlue;
  StyleChoice _styleChoice = StyleChoice.skeuomorphic;
  FontConfig _fontConfig = const FontConfig();

  ThemeModeChoice get mode => _mode;
  PaletteChoice get paletteChoice => _paletteChoice;
  StyleChoice get styleChoice => _styleChoice;
  FontConfig get fontConfig => _fontConfig;

  ThemeStyle _compose([Brightness? platformBrightness]) {
    final isDark = switch (_mode) {
      ThemeModeChoice.dark => true,
      ThemeModeChoice.light => false,
      ThemeModeChoice.system =>
        (platformBrightness ?? Brightness.light) == Brightness.dark,
    };
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final palette = resolvePalette(_paletteChoice, brightness);
    final typography = BaseTypography(palette, _fontConfig);
    final decorations = resolveDecorations(_styleChoice, palette);
    return ComposedThemeStyle(
      palette: palette,
      typography: typography,
      decorations: decorations,
    );
  }

  @override
  ThemeStyle build() => _compose();

  ThemeStyle resolve([Brightness? platformBrightness]) => _compose(platformBrightness);

  void setMode(ThemeModeChoice mode, {Brightness? platformBrightness}) {
    _mode = mode;
    state = _compose(platformBrightness);
  }

  void setPalette(PaletteChoice choice) {
    _paletteChoice = choice;
    state = _compose();
  }

  void setStyle(StyleChoice choice) {
    _styleChoice = choice;
    state = _compose();
  }

  void setFontConfig(FontConfig config) {
    _fontConfig = config;
    state = _compose();
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeStyle>(ThemeNotifier.new);

ThemeStyle currentTheme(BuildContext context) =>
    ProviderScope.containerOf(context).read(themeProvider);
