import 'package:flutter/material.dart';
import 'colors.dart';
import 'theme_choices.dart';

abstract class DecorationSet {
  BoxDecoration get controlsBar;
  BoxDecoration get headerDecoration;
  List<BoxShadow> get bevelInset;
  BoxDecoration buttonDecoration({bool pressed, bool isPlay});
  BoxDecoration pillButton({bool active});
  BoxDecoration taskPaneTile({bool selected});
  BoxDecoration controlButton({bool disabled});
  BoxDecoration get tileOuterDecoration;
  BoxDecoration get tileAccentBarDecoration;
  BoxDecoration get tileContentDecoration;
  BoxDecoration get settingsBackground;
  BoxDecoration get presentationBackground;
}

class SkeuomorphicDecorations implements DecorationSet {
  final ColorPalette palette;
  const SkeuomorphicDecorations(this.palette);

  @override
  BoxDecoration get controlsBar => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [palette.buttonGradientTop, palette.buttonGradientMid, palette.buttonGradientBottom],
      stops: const [0.0, 0.5, 1.0],
    ),
    border: Border(
      top: BorderSide(color: Colors.white.withValues(alpha: palette is RoyalBlueDark ? 0.15 : 0.8), width: 1),
      bottom: BorderSide(color: palette.insetBorderDark, width: 1),
    ),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: palette is RoyalBlueDark ? 0.4 : 0.08), blurRadius: 4, offset: const Offset(0, -2))],
  );

  @override
  BoxDecoration get headerDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [palette.primaryLight, palette.primary, palette.primaryDark],
    ),
    border: Border(bottom: BorderSide(color: palette.primaryDark, width: 1)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: palette is RoyalBlueDark ? 0.3 : 0.15), blurRadius: 4, offset: const Offset(0, 1))],
  );

  @override
  List<BoxShadow> get bevelInset => [
    BoxShadow(color: Colors.black.withValues(alpha: palette is RoyalBlueDark ? 0.15 : 0.08), blurRadius: 2, offset: const Offset(0, 1)),
  ];

  @override
  BoxDecoration buttonDecoration({bool pressed = false, bool isPlay = false}) {
    final isDark = palette is RoyalBlueDark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: pressed
            ? [const Color(0xFF2E2E2E), const Color(0xFF252525)]
            : [palette.buttonGradientTop, palette.buttonGradientMid, palette.buttonGradientBottom],
        stops: pressed ? null : [0.0, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(isPlay ? 20 : 4),
      border: Border.all(color: palette.insetBorderDark, width: 1),
      boxShadow: [
        BoxShadow(color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.8), blurRadius: 1, offset: const Offset(0, 1)),
        BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1), blurRadius: 2, offset: const Offset(0, 1)),
      ],
    );
  }

  @override
  BoxDecoration pillButton({bool active = false}) {
    final isDark = palette is RoyalBlueDark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: active
            ? [palette.primary, palette.primaryDark]
            : [palette.buttonGradientTop, palette.buttonGradientBottom],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: active ? palette.primaryDark : palette.insetBorderDark, width: 1,
      ),
      boxShadow: [
        BoxShadow(color: Colors.white.withValues(alpha: isDark ? 0.1 : 0), blurRadius: 1, offset: const Offset(0, 1)),
        BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0), blurRadius: 1, offset: const Offset(0, 1)),
      ],
    );
  }

  @override
  BoxDecoration taskPaneTile({bool selected = false}) {
    return BoxDecoration(
      gradient: selected
          ? LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [palette.primary.withValues(alpha: 0.3), palette.primary.withValues(alpha: 0.1)],
            )
          : null,
      borderRadius: BorderRadius.circular(6),
      border: selected
          ? Border.all(color: palette.primary.withValues(alpha: 0.5), width: 1)
          : null,
    );
  }

  @override
  BoxDecoration controlButton({bool disabled = false}) {
    final isDark = palette is RoyalBlueDark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: disabled
            ? [palette.buttonGradientBottom, palette.buttonGradientMid]
            : [palette.buttonGradientTop, palette.buttonGradientBottom],
      ),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: palette.insetBorderDark, width: 1),
      boxShadow: [
        BoxShadow(color: Colors.white.withValues(alpha: isDark ? 0.1 : 0), blurRadius: 1, offset: const Offset(0, 1)),
        BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.4 : 0), blurRadius: 1, offset: const Offset(0, 1)),
      ],
    );
  }

  @override
  BoxDecoration get tileOuterDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: palette.insetBorderDark, width: 1),
  );

  @override
  BoxDecoration get tileAccentBarDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [palette.primary, palette.primaryDark],
    ),
    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
  );

  @override
  BoxDecoration get tileContentDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [palette.surfaceCard, palette.surfaceDark, palette.surfaceOverlay],
      stops: const [0.0, 0.5, 1.0],
    ),
    borderRadius: BorderRadius.circular(6),
  );

  @override
  BoxDecoration get settingsBackground => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [palette.screenBackgroundStart, palette.screenBackgroundEnd],
    ),
  );

  @override
  BoxDecoration get presentationBackground => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [palette.screenBackgroundStart, palette.screenBackgroundEnd],
    ),
  );
}

class FlatDecorations implements DecorationSet {
  final ColorPalette palette;
  const FlatDecorations(this.palette);

  @override
  BoxDecoration get controlsBar => BoxDecoration(
    color: palette.surfaceDark,
    border: Border(bottom: BorderSide(color: palette.border, width: 1)),
  );

  @override
  BoxDecoration get headerDecoration => BoxDecoration(
    color: palette.primary,
  );

  @override
  List<BoxShadow> get bevelInset => [];

  @override
  BoxDecoration buttonDecoration({bool pressed = false, bool isPlay = false}) {
    return BoxDecoration(
      color: pressed ? palette.surfaceMuted : palette.surfaceCard,
      borderRadius: BorderRadius.circular(isPlay ? 20 : 4),
      border: Border.all(color: palette.border, width: 1),
    );
  }

  @override
  BoxDecoration pillButton({bool active = false}) {
    return BoxDecoration(
      color: active ? palette.primary : palette.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: active ? palette.primaryDark : palette.border, width: 1),
    );
  }

  @override
  BoxDecoration taskPaneTile({bool selected = false}) {
    return BoxDecoration(
      color: selected ? palette.primary.withValues(alpha: 0.15) : null,
      borderRadius: BorderRadius.circular(6),
      border: selected ? Border.all(color: palette.primary.withValues(alpha: 0.4), width: 1) : null,
    );
  }

  @override
  BoxDecoration controlButton({bool disabled = false}) {
    return BoxDecoration(
      color: disabled ? palette.surfaceMuted : palette.surfaceCard,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: palette.border, width: 1),
    );
  }

  @override
  BoxDecoration get tileOuterDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: palette.border, width: 1),
  );

  @override
  BoxDecoration get tileAccentBarDecoration => BoxDecoration(
    color: palette.primary,
    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
  );

  @override
  BoxDecoration get tileContentDecoration => BoxDecoration(
    color: palette.surfaceCard,
    borderRadius: BorderRadius.circular(6),
  );

  @override
  BoxDecoration get settingsBackground => BoxDecoration(
    color: palette.background,
  );

  @override
  BoxDecoration get presentationBackground => BoxDecoration(
    color: palette.surfaceDark,
  );
}

DecorationSet resolveDecorations(StyleChoice choice, ColorPalette palette) {
  switch (choice) {
    case StyleChoice.skeuomorphic:
      return SkeuomorphicDecorations(palette);
    case StyleChoice.flat:
      return FlatDecorations(palette);
  }
}
