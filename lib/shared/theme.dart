import 'package:flutter/material.dart';

class AppTheme {
  static const Color royalBlue = Color(0xFF2E5CB8);
  static const Color royalBlueDark = Color(0xFF1A3D8F);
  static const Color royalBlueLight = Color(0xFF4A7AE8);
  static const Color silverLight = Color(0xFFF2F2F2);
  static const Color silver = Color(0xFFD4D4D4);
  static const Color silverDark = Color(0xFFA0A0A0);
  static const Color silverBorder = Color(0xFF808080);
  static const Color xpGreen = Color(0xFF33CC33);
  static const Color xpGreenDark = Color(0xFF28A428);
  static const Color closeRed = Color(0xFFE81123);
  static const Color bgDark = Color(0xFF0A0A14);
  static const Color bgDarkCard = Color(0xFF16162A);
  static const Color bgDarkest = Color(0xFF0F0F1E);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color textOnSilver = Color(0xFF2A2A2A);
  static const Color textMuted = Color(0xFFA0A0B8);
  static const Color textSubtitle = Color(0xFF8888A8);
  static const Color dropdownBg = Color(0xFF2A2A2A);
  static const Color breakGradientStart = Color(0xFF0A0A18);
  static const Color breakGradientEnd = Color(0xFF14142A);
  static const Color silverHighlight = Color(0xFFE8E8E8);
  static const Color silverMid = Color(0xFFD8D8D8);
  static const Color silverShadow = Color(0xFFC0C0C0);
  static const Color presentationBgTop = Color(0xFF0D0D1A);
  static const Color presentationBgBottom = Color(0xFF06060D);
  static const Color textBadge = Color(0xFFB0B0C8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: royalBlue,
        secondary: silver,
        tertiary: xpGreen,
        surface: bgDark,
        onSurface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: textOnSilver,
        error: closeRed,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: royalBlue.withValues(alpha: 0.3), width: 1),
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
          backgroundColor: WidgetStateProperty.all(royalBlue),
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

  static BoxDecoration get silverControlsBar => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [silverHighlight, Color(0xFFC8C8C8), silverMid],
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

  static BoxDecoration get royalBlueHeader => BoxDecoration(
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

  static BoxDecoration silverButton({bool pressed = false, bool isPlay = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: pressed
            ? [const Color(0xFFB8B8B8), silverMid]
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

  static BoxDecoration xpPillButton({bool active = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: active
            ? [royalBlue, royalBlueDark]
            : [silverHighlight, silverShadow],
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

  static BoxDecoration xpTaskPaneTile({bool selected = false}) {
    return BoxDecoration(
      gradient: selected
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [royalBlue.withValues(alpha: 0.3), royalBlue.withValues(alpha: 0.1)],
            )
          : null,
      borderRadius: BorderRadius.circular(6),
      border: selected
          ? Border.all(color: royalBlue.withValues(alpha: 0.5), width: 1)
          : null,
    );
  }

  static BoxDecoration xpControlButton({bool disabled = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: disabled
            ? [silverShadow, silverMid]
            : [silverHighlight, silverShadow],
      ),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: silverBorder, width: 1),
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
    border: Border.all(color: royalBlue.withValues(alpha: 0.15), width: 0.5),
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
      colors: [royalBlue, royalBlueDark],
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8),
      bottomLeft: Radius.circular(8),
    ),
  );

  static BoxDecoration get tileContentDecoration => BoxDecoration(
    gradient: LinearGradient(
      colors: [bgDarkCard, bgDarkest],
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
      colors: [presentationBgTop, presentationBgBottom],
    ),
  );

  static TextStyle get cardTitleStyle => const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get cardSubtitleStyle => const TextStyle(
    color: textSubtitle,
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
    color: textBadge,
    fontSize: 13,
  );
}
