import 'package:flutter/material.dart';
import 'theme_choices.dart';

abstract class ColorPalette {
  Color get primary;
  Color get primaryDark;
  Color get primaryLight;
  Color get surfaceLightest;
  Color get secondary;
  Color get surfaceMuted;
  Color get border;
  Color get success;
  Color get successDark;
  Color get error;
  Color get background;
  Color get surfaceCard;
  Color get surfaceDark;
  Color get surfaceOverlay;
  Color get onSurface;
  Color get surfaceDropdown;
  Color get textSecondary;
  Color get textTertiary;
  Color get textOnDark;
  Color get textOnDarkMedium;
  Color get textOnDarkSubtle;
  Color get breakBackgroundStart;
  Color get breakBackgroundEnd;
  Color get screenBackgroundStart;
  Color get screenBackgroundEnd;
  Color get badgeText;
  Color get buttonGradientTop;
  Color get buttonGradientMid;
  Color get buttonGradientBottom;
  Color get insetBorderDark;
}

class RoyalBlueDark implements ColorPalette {
  const RoyalBlueDark();

  @override Color get primary => const Color(0xFF2E5CB8);
  @override Color get primaryDark => const Color(0xFF1A3D8F);
  @override Color get primaryLight => const Color(0xFF4A7AE8);
  @override Color get surfaceLightest => const Color(0xFFF2F2F2);
  @override Color get secondary => const Color(0xFFD4D4D4);
  @override Color get surfaceMuted => const Color(0xFFA0A0A0);
  @override Color get border => const Color(0xFF808080);
  @override Color get success => const Color(0xFF33CC33);
  @override Color get successDark => const Color(0xFF28A428);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFF0A0A14);
  @override Color get surfaceCard => const Color(0xFF16162A);
  @override Color get surfaceDark => const Color(0xFF0F0F1E);
  @override Color get surfaceOverlay => const Color(0xFF1A1A2E);
  @override Color get onSurface => const Color(0xFFB8B8C8);
  @override Color get surfaceDropdown => const Color(0xFF2A2A2A);
  @override Color get textSecondary => const Color(0xFFB0B0C8);
  @override Color get textTertiary => const Color(0xFF9090B0);
  @override Color get textOnDark => Colors.white;
  @override Color get textOnDarkMedium => const Color(0xCCFFFFFF);
  @override Color get textOnDarkSubtle => const Color(0xA6FFFFFF);
  @override Color get breakBackgroundStart => const Color(0xFF0A0A18);
  @override Color get breakBackgroundEnd => const Color(0xFF14142A);
  @override Color get screenBackgroundStart => const Color(0xFF0D0D1A);
  @override Color get screenBackgroundEnd => const Color(0xFF06060D);
  @override Color get badgeText => const Color(0xFFB0B0C8);
  @override Color get buttonGradientTop => const Color(0xFF5A5A5A);
  @override Color get buttonGradientMid => const Color(0xFF4A4A4A);
  @override Color get buttonGradientBottom => const Color(0xFF3A3A3A);
  @override Color get insetBorderDark => const Color(0xFF1E1E1E);
}

class RoyalBlueLight implements ColorPalette {
  const RoyalBlueLight();

  @override Color get primary => const Color(0xFF2E5CB8);
  @override Color get primaryDark => const Color(0xFF1A3D8F);
  @override Color get primaryLight => const Color(0xFF4A7AE8);
  @override Color get surfaceLightest => const Color(0xFFF2F2F2);
  @override Color get secondary => const Color(0xFFD4D4D4);
  @override Color get surfaceMuted => const Color(0xFFA0A0A0);
  @override Color get border => const Color(0xFFB0B0B0);
  @override Color get success => const Color(0xFF28A428);
  @override Color get successDark => const Color(0xFF1E7A1E);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFFF2F2F2);
  @override Color get surfaceCard => Colors.white;
  @override Color get surfaceDark => const Color(0xFFE8E8E8);
  @override Color get surfaceOverlay => const Color(0xFFF5F5F5);
  @override Color get onSurface => const Color(0xFF2A2A2A);
  @override Color get surfaceDropdown => Colors.white;
  @override Color get textSecondary => const Color(0xFF606060);
  @override Color get textTertiary => const Color(0xFF808080);
  @override Color get textOnDark => const Color(0xFF1A1A1A);
  @override Color get textOnDarkMedium => const Color(0xFF404040);
  @override Color get textOnDarkSubtle => const Color(0xFF606060);
  @override Color get breakBackgroundStart => const Color(0xFFF0F0F0);
  @override Color get breakBackgroundEnd => const Color(0xFFE8E8E8);
  @override Color get screenBackgroundStart => const Color(0xFFF5F5F5);
  @override Color get screenBackgroundEnd => const Color(0xFFEAEAEA);
  @override Color get badgeText => const Color(0xFF404040);
  @override Color get buttonGradientTop => const Color(0xFFF0F0F0);
  @override Color get buttonGradientMid => const Color(0xFFD8D8D8);
  @override Color get buttonGradientBottom => const Color(0xFFC0C0C0);
  @override Color get insetBorderDark => const Color(0xFFB0B0B0);
}

ColorPalette resolvePalette(PaletteChoice choice, Brightness brightness) {
  switch (choice) {
    case PaletteChoice.royalBlue:
      return brightness == Brightness.dark
          ? const RoyalBlueDark()
          : const RoyalBlueLight();
  }
}
