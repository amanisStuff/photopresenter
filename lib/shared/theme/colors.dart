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

// ── Emerald ──

class EmeraldDark implements ColorPalette {
  const EmeraldDark();

  @override Color get primary => const Color(0xFF2E8B57);
  @override Color get primaryDark => const Color(0xFF1A6B3F);
  @override Color get primaryLight => const Color(0xFF4CAF7A);
  @override Color get surfaceLightest => const Color(0xFFE8F5E9);
  @override Color get secondary => const Color(0xFFA5D6A7);
  @override Color get surfaceMuted => const Color(0xFF6A8F7A);
  @override Color get border => const Color(0xFF507060);
  @override Color get success => const Color(0xFF33CC33);
  @override Color get successDark => const Color(0xFF28A428);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFF0A1410);
  @override Color get surfaceCard => const Color(0xFF0F1E16);
  @override Color get surfaceDark => const Color(0xFF0C1812);
  @override Color get surfaceOverlay => const Color(0xFF142A1E);
  @override Color get onSurface => const Color(0xFFB8D0C0);
  @override Color get surfaceDropdown => const Color(0xFF1E2E24);
  @override Color get textSecondary => const Color(0xFFA0C0B0);
  @override Color get textTertiary => const Color(0xFF80A890);
  @override Color get textOnDark => Colors.white;
  @override Color get textOnDarkMedium => const Color(0xCCFFFFFF);
  @override Color get textOnDarkSubtle => const Color(0xA6FFFFFF);
  @override Color get breakBackgroundStart => const Color(0xFF0A1812);
  @override Color get breakBackgroundEnd => const Color(0xFF0E1E16);
  @override Color get screenBackgroundStart => const Color(0xFF0C1812);
  @override Color get screenBackgroundEnd => const Color(0xFF08100C);
  @override Color get badgeText => const Color(0xFFAAC8B8);
  @override Color get buttonGradientTop => const Color(0xFF3A5A4A);
  @override Color get buttonGradientMid => const Color(0xFF2E4A3A);
  @override Color get buttonGradientBottom => const Color(0xFF223A2E);
  @override Color get insetBorderDark => const Color(0xFF182A1E);
}

class EmeraldLight implements ColorPalette {
  const EmeraldLight();

  @override Color get primary => const Color(0xFF2E8B57);
  @override Color get primaryDark => const Color(0xFF1A6B3F);
  @override Color get primaryLight => const Color(0xFF4CAF7A);
  @override Color get surfaceLightest => const Color(0xFFF2FBF5);
  @override Color get secondary => const Color(0xFFA5D6A7);
  @override Color get surfaceMuted => const Color(0xFF90A898);
  @override Color get border => const Color(0xFFB0C8B8);
  @override Color get success => const Color(0xFF28A428);
  @override Color get successDark => const Color(0xFF1E7A1E);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFFF0F7F2);
  @override Color get surfaceCard => Colors.white;
  @override Color get surfaceDark => const Color(0xFFE8F0EA);
  @override Color get surfaceOverlay => const Color(0xFFF5FAF6);
  @override Color get onSurface => const Color(0xFF2A2A2A);
  @override Color get surfaceDropdown => Colors.white;
  @override Color get textSecondary => const Color(0xFF506050);
  @override Color get textTertiary => const Color(0xFF708070);
  @override Color get textOnDark => const Color(0xFF1A1A1A);
  @override Color get textOnDarkMedium => const Color(0xFF404040);
  @override Color get textOnDarkSubtle => const Color(0xFF606060);
  @override Color get breakBackgroundStart => const Color(0xFFE8F0EA);
  @override Color get breakBackgroundEnd => const Color(0xFFE0E8E2);
  @override Color get screenBackgroundStart => const Color(0xFFF0F7F2);
  @override Color get screenBackgroundEnd => const Color(0xFFE8F0EA);
  @override Color get badgeText => const Color(0xFF405048);
  @override Color get buttonGradientTop => const Color(0xFFF0F5F0);
  @override Color get buttonGradientMid => const Color(0xFFD8E0D8);
  @override Color get buttonGradientBottom => const Color(0xFFC0C8C0);
  @override Color get insetBorderDark => const Color(0xFFB0B8B0);
}

// ── Ruby ──

class RubyDark implements ColorPalette {
  const RubyDark();

  @override Color get primary => const Color(0xFFC62828);
  @override Color get primaryDark => const Color(0xFF8E1A1A);
  @override Color get primaryLight => const Color(0xFFE53935);
  @override Color get surfaceLightest => const Color(0xFFFFEBEE);
  @override Color get secondary => const Color(0xFFE57373);
  @override Color get surfaceMuted => const Color(0xFF8F6068);
  @override Color get border => const Color(0xFF705058);
  @override Color get success => const Color(0xFF33CC33);
  @override Color get successDark => const Color(0xFF28A428);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFF140A0A);
  @override Color get surfaceCard => const Color(0xFF1E0F10);
  @override Color get surfaceDark => const Color(0xFF180C0C);
  @override Color get surfaceOverlay => const Color(0xFF2A1416);
  @override Color get onSurface => const Color(0xFFD0B8B8);
  @override Color get surfaceDropdown => const Color(0xFF2A1A1A);
  @override Color get textSecondary => const Color(0xFFC0A0A0);
  @override Color get textTertiary => const Color(0xFFA88080);
  @override Color get textOnDark => Colors.white;
  @override Color get textOnDarkMedium => const Color(0xCCFFFFFF);
  @override Color get textOnDarkSubtle => const Color(0xA6FFFFFF);
  @override Color get breakBackgroundStart => const Color(0xFF180C0C);
  @override Color get breakBackgroundEnd => const Color(0xFF201012);
  @override Color get screenBackgroundStart => const Color(0xFF160A0A);
  @override Color get screenBackgroundEnd => const Color(0xFF0E0606);
  @override Color get badgeText => const Color(0xFFC8A0A0);
  @override Color get buttonGradientTop => const Color(0xFF5A3A3A);
  @override Color get buttonGradientMid => const Color(0xFF4A2E2E);
  @override Color get buttonGradientBottom => const Color(0xFF3A2222);
  @override Color get insetBorderDark => const Color(0xFF221212);
}

class RubyLight implements ColorPalette {
  const RubyLight();

  @override Color get primary => const Color(0xFFC62828);
  @override Color get primaryDark => const Color(0xFF8E1A1A);
  @override Color get primaryLight => const Color(0xFFE53935);
  @override Color get surfaceLightest => const Color(0xFFF2F2F2);
  @override Color get secondary => const Color(0xFFE57373);
  @override Color get surfaceMuted => const Color(0xFFA08080);
  @override Color get border => const Color(0xFFC0B0B0);
  @override Color get success => const Color(0xFF28A428);
  @override Color get successDark => const Color(0xFF1E7A1E);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFFFDF2F2);
  @override Color get surfaceCard => const Color(0xFFFFFAFA);
  @override Color get surfaceDark => const Color(0xFFF0E8E8);
  @override Color get surfaceOverlay => const Color(0xFFFAF5F5);
  @override Color get onSurface => const Color(0xFF2A2A2A);
  @override Color get surfaceDropdown => const Color(0xFFFFFAFA);
  @override Color get textSecondary => const Color(0xFF605050);
  @override Color get textTertiary => const Color(0xFF807070);
  @override Color get textOnDark => const Color(0xFF1A1A1A);
  @override Color get textOnDarkMedium => const Color(0xFF404040);
  @override Color get textOnDarkSubtle => const Color(0xFF606060);
  @override Color get breakBackgroundStart => const Color(0xFFF0E8E8);
  @override Color get breakBackgroundEnd => const Color(0xFFE8E0E0);
  @override Color get screenBackgroundStart => const Color(0xFFFDF2F2);
  @override Color get screenBackgroundEnd => const Color(0xFFF0E8E8);
  @override Color get badgeText => const Color(0xFF404040);
  @override Color get buttonGradientTop => const Color(0xFFFDF0F0);
  @override Color get buttonGradientMid => const Color(0xFFE8D8D8);
  @override Color get buttonGradientBottom => const Color(0xFFD0C0C0);
  @override Color get insetBorderDark => const Color(0xFFC0B0B0);
}

// ── Amethyst ──

class AmethystDark implements ColorPalette {
  const AmethystDark();

  @override Color get primary => const Color(0xFF7B1FA2);
  @override Color get primaryDark => const Color(0xFF4A136B);
  @override Color get primaryLight => const Color(0xFF9C27B0);
  @override Color get surfaceLightest => const Color(0xFFF3E5F5);
  @override Color get secondary => const Color(0xFFCE93D8);
  @override Color get surfaceMuted => const Color(0xFF80688A);
  @override Color get border => const Color(0xFF605070);
  @override Color get success => const Color(0xFF33CC33);
  @override Color get successDark => const Color(0xFF28A428);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFF0E0A14);
  @override Color get surfaceCard => const Color(0xFF16102A);
  @override Color get surfaceDark => const Color(0xFF100C1E);
  @override Color get surfaceOverlay => const Color(0xFF1E1430);
  @override Color get onSurface => const Color(0xFFC0B8D0);
  @override Color get surfaceDropdown => const Color(0xFF221E30);
  @override Color get textSecondary => const Color(0xFFB0A8C0);
  @override Color get textTertiary => const Color(0xFF9088A8);
  @override Color get textOnDark => Colors.white;
  @override Color get textOnDarkMedium => const Color(0xCCFFFFFF);
  @override Color get textOnDarkSubtle => const Color(0xA6FFFFFF);
  @override Color get breakBackgroundStart => const Color(0xFF0E0A18);
  @override Color get breakBackgroundEnd => const Color(0xFF16102A);
  @override Color get screenBackgroundStart => const Color(0xFF100C1A);
  @override Color get screenBackgroundEnd => const Color(0xFF08060D);
  @override Color get badgeText => const Color(0xFFB0A8C8);
  @override Color get buttonGradientTop => const Color(0xFF4A3A5A);
  @override Color get buttonGradientMid => const Color(0xFF3A2E4A);
  @override Color get buttonGradientBottom => const Color(0xFF2E223A);
  @override Color get insetBorderDark => const Color(0xFF1E162A);
}

class AmethystLight implements ColorPalette {
  const AmethystLight();

  @override Color get primary => const Color(0xFF7B1FA2);
  @override Color get primaryDark => const Color(0xFF4A136B);
  @override Color get primaryLight => const Color(0xFF9C27B0);
  @override Color get surfaceLightest => const Color(0xFFF2F2F2);
  @override Color get secondary => const Color(0xFFCE93D8);
  @override Color get surfaceMuted => const Color(0xFFA090A8);
  @override Color get border => const Color(0xFFC0B0C0);
  @override Color get success => const Color(0xFF28A428);
  @override Color get successDark => const Color(0xFF1E7A1E);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFFF5F0FD);
  @override Color get surfaceCard => const Color(0xFFFCFAFF);
  @override Color get surfaceDark => const Color(0xFFE8E0F0);
  @override Color get surfaceOverlay => const Color(0xFFFAF5FF);
  @override Color get onSurface => const Color(0xFF2A2A2A);
  @override Color get surfaceDropdown => const Color(0xFFFCFAFF);
  @override Color get textSecondary => const Color(0xFF605070);
  @override Color get textTertiary => const Color(0xFF807088);
  @override Color get textOnDark => const Color(0xFF1A1A1A);
  @override Color get textOnDarkMedium => const Color(0xFF404040);
  @override Color get textOnDarkSubtle => const Color(0xFF606060);
  @override Color get breakBackgroundStart => const Color(0xFFF0E8F0);
  @override Color get breakBackgroundEnd => const Color(0xFFE8E0E8);
  @override Color get screenBackgroundStart => const Color(0xFFF5F0FD);
  @override Color get screenBackgroundEnd => const Color(0xFFEAE8F0);
  @override Color get badgeText => const Color(0xFF404040);
  @override Color get buttonGradientTop => const Color(0xFFF5F0FD);
  @override Color get buttonGradientMid => const Color(0xFFE0D8E8);
  @override Color get buttonGradientBottom => const Color(0xFFC8C0D0);
  @override Color get insetBorderDark => const Color(0xFFC0B0C0);
}

// ── Slate ──

class SlateDark implements ColorPalette {
  const SlateDark();

  @override Color get primary => const Color(0xFF546E7A);
  @override Color get primaryDark => const Color(0xFF37474F);
  @override Color get primaryLight => const Color(0xFF78909C);
  @override Color get surfaceLightest => const Color(0xFFECEFF1);
  @override Color get secondary => const Color(0xFF90A4AE);
  @override Color get surfaceMuted => const Color(0xFF607080);
  @override Color get border => const Color(0xFF506070);
  @override Color get success => const Color(0xFF33CC33);
  @override Color get successDark => const Color(0xFF28A428);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFF0A0C10);
  @override Color get surfaceCard => const Color(0xFF12161E);
  @override Color get surfaceDark => const Color(0xFF0E1016);
  @override Color get surfaceOverlay => const Color(0xFF1A1E26);
  @override Color get onSurface => const Color(0xFFB8C0C8);
  @override Color get surfaceDropdown => const Color(0xFF1E222A);
  @override Color get textSecondary => const Color(0xFFA0B0B8);
  @override Color get textTertiary => const Color(0xFF889098);
  @override Color get textOnDark => Colors.white;
  @override Color get textOnDarkMedium => const Color(0xCCFFFFFF);
  @override Color get textOnDarkSubtle => const Color(0xA6FFFFFF);
  @override Color get breakBackgroundStart => const Color(0xFF0A0E12);
  @override Color get breakBackgroundEnd => const Color(0xFF10141A);
  @override Color get screenBackgroundStart => const Color(0xFF0C0E12);
  @override Color get screenBackgroundEnd => const Color(0xFF080A0D);
  @override Color get badgeText => const Color(0xFFA8B0B8);
  @override Color get buttonGradientTop => const Color(0xFF4A5058);
  @override Color get buttonGradientMid => const Color(0xFF3A4048);
  @override Color get buttonGradientBottom => const Color(0xFF2E343A);
  @override Color get insetBorderDark => const Color(0xFF1A1E22);
}

class SlateLight implements ColorPalette {
  const SlateLight();

  @override Color get primary => const Color(0xFF546E7A);
  @override Color get primaryDark => const Color(0xFF37474F);
  @override Color get primaryLight => const Color(0xFF78909C);
  @override Color get surfaceLightest => const Color(0xFFF2F2F2);
  @override Color get secondary => const Color(0xFF90A4AE);
  @override Color get surfaceMuted => const Color(0xFF809098);
  @override Color get border => const Color(0xFFB0B8C0);
  @override Color get success => const Color(0xFF28A428);
  @override Color get successDark => const Color(0xFF1E7A1E);
  @override Color get error => const Color(0xFFE81123);
  @override Color get background => const Color(0xFFF0F2F5);
  @override Color get surfaceCard => const Color(0xFFF8FAFC);
  @override Color get surfaceDark => const Color(0xFFE8EAF0);
  @override Color get surfaceOverlay => const Color(0xFFF5F6FA);
  @override Color get onSurface => const Color(0xFF2A2A2A);
  @override Color get surfaceDropdown => const Color(0xFFF8FAFC);
  @override Color get textSecondary => const Color(0xFF506070);
  @override Color get textTertiary => const Color(0xFF708088);
  @override Color get textOnDark => const Color(0xFF1A1A1A);
  @override Color get textOnDarkMedium => const Color(0xFF404040);
  @override Color get textOnDarkSubtle => const Color(0xFF606060);
  @override Color get breakBackgroundStart => const Color(0xFFE8EAF0);
  @override Color get breakBackgroundEnd => const Color(0xFFE0E4E8);
  @override Color get screenBackgroundStart => const Color(0xFFF0F2F5);
  @override Color get screenBackgroundEnd => const Color(0xFFE8EAF0);
  @override Color get badgeText => const Color(0xFF404040);
  @override Color get buttonGradientTop => const Color(0xFFF0F2F5);
  @override Color get buttonGradientMid => const Color(0xFFD8DCE0);
  @override Color get buttonGradientBottom => const Color(0xFFC0C4C8);
  @override Color get insetBorderDark => const Color(0xFFB0B8C0);
}

ColorPalette resolvePalette(PaletteChoice choice, Brightness brightness) {
  switch (choice) {
    case PaletteChoice.royalBlue:
      return brightness == Brightness.dark
          ? const RoyalBlueDark()
          : const RoyalBlueLight();
    case PaletteChoice.emerald:
      return brightness == Brightness.dark
          ? const EmeraldDark()
          : const EmeraldLight();
    case PaletteChoice.ruby:
      return brightness == Brightness.dark
          ? const RubyDark()
          : const RubyLight();
    case PaletteChoice.amethyst:
      return brightness == Brightness.dark
          ? const AmethystDark()
          : const AmethystLight();
    case PaletteChoice.slate:
      return brightness == Brightness.dark
          ? const SlateDark()
          : const SlateLight();
  }
}
