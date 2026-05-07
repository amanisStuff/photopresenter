import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2E5CB8);
  static const Color primaryDark = Color(0xFF1A3D8F);
  static const Color primaryLight = Color(0xFF4A7AE8);
  static const Color surfaceLightest = Color(0xFFF2F2F2);
  static const Color secondary = Color(0xFFD4D4D4);
  static const Color surfaceMuted = Color(0xFFA0A0A0);
  static const Color border = Color(0xFF808080);
  static const Color success = Color(0xFF33CC33);
  static const Color successDark = Color(0xFF28A428);
  static const Color error = Color(0xFFE81123);
  static const Color background = Color(0xFF0A0A14);
  static const Color surfaceCard = Color(0xFF16162A);
  static const Color surfaceDark = Color(0xFF0F0F1E);
  static const Color surfaceOverlay = Color(0xFF1A1A2E);
  static const Color onSurface = Color(0xFF2A2A2A);
  static const Color textSecondary = Color(0xFFA0A0B8);
  static const Color textTertiary = Color(0xFF8888A8);
  static const Color surfaceDropdown = Color(0xFF2A2A2A);
  static const Color breakBackgroundStart = Color(0xFF0A0A18);
  static const Color breakBackgroundEnd = Color(0xFF14142A);
  static const Color buttonGradientTop = Color(0xFFE8E8E8);
  static const Color buttonGradientMid = Color(0xFFD8D8D8);
  static const Color buttonGradientBottom = Color(0xFFC0C0C0);
  static const Color screenBackgroundStart = Color(0xFF0D0D1A);
  static const Color screenBackgroundEnd = Color(0xFF06060D);
  static const Color badgeText = Color(0xFFB0B0C8);
  static const Color textOnDark = Colors.white;
  static const Color textOnDarkMedium = Colors.white70;
  static const Color textOnDarkSubtle = Colors.white54;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppTheme.primary,
        secondary: AppTheme.secondary,
        tertiary: AppTheme.success,
        surface: AppTheme.background,
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: AppTheme.onSurface,
        error: AppTheme.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppTheme.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppTheme.surfaceOverlay,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          backgroundColor: WidgetStateProperty.all(AppTheme.primary),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 500),
      ),
    );
  }

  static BoxDecoration get controlsBar => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [buttonGradientTop, Color(0xFFC8C8C8), buttonGradientMid],
      stops: [0.0, 0.5, 1.0],
    ),
    border: Border(
      top: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1),
      bottom: BorderSide(color: const Color(0xFF606060), width: 1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 4,
        offset: const Offset(0, -2),
      ),
    ],
  );

  static BoxDecoration get headerDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3B6ED5), Color(0xFF2E5CB8), Color(0xFF1A3D8F)],
    ),
    border: Border(
      bottom: BorderSide(color: Color(0xFF0F2B6A), width: 1),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static List<BoxShadow> get bevelInset => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static BoxDecoration buttonDecoration({bool pressed = false, bool isPlay = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: pressed
            ? [const Color(0xFFB8B8B8), buttonGradientMid]
            : [const Color(0xFFF5F5F5), const Color(0xFFD0D0D0), const Color(0xFFB8B8B8)],
        stops: pressed ? null : [0.0, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(isPlay ? 20 : 4),
      border: Border.all(color: const Color(0xFF707070), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration pillButton({bool active = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: active
            ? [primary, primaryDark]
            : [buttonGradientTop, buttonGradientBottom],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active ? const Color(0xFF0F2B6A) : const Color(0xFF808080),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.6),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration taskPaneTile({bool selected = false}) {
    return BoxDecoration(
      gradient: selected
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primary.withValues(alpha: 0.3), primary.withValues(alpha: 0.1)],
            )
          : null,
      borderRadius: BorderRadius.circular(6),
      border: selected
          ? Border.all(color: primary.withValues(alpha: 0.5), width: 1)
          : null,
    );
  }

  static BoxDecoration controlButton({bool disabled = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: disabled
            ? [buttonGradientBottom, buttonGradientMid]
            : [buttonGradientTop, buttonGradientBottom],
      ),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.6),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  static BoxDecoration get tileOuterDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: primary.withValues(alpha: 0.15), width: 0.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get tileAccentBarDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [primary, primaryDark],
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    ),
  );

  static BoxDecoration get tileContentDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: [surfaceCard, surfaceDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: const BorderRadius.only(
      topRight: Radius.circular(8),
      bottomRight: Radius.circular(8),
    ),
  );

  static BoxDecoration get presentationBackground => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [screenBackgroundStart, screenBackgroundEnd],
    ),
  );

  static TextStyle get cardTitleStyle => const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get cardSubtitleStyle => const TextStyle(
    color: textTertiary,
    fontSize: 12,
  );

  static TextStyle get badgeStyle => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get overlayTitleStyle => const TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 6,
  );

  static TextStyle get overlayTextStyle => const TextStyle(
    color: badgeText,
    fontSize: 13,
  );
}
