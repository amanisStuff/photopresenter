import 'package:flutter/material.dart';
import 'colors.dart';
import 'theme_choices.dart';

abstract class TypographySet {
  TextStyle get cardTitle;
  TextStyle get cardSubtitle;
  TextStyle get badge;
  TextStyle get overlayTitle;
  TextStyle get overlayText;
  TextStyle get screenTitle;
  TextStyle get appBarTitle;
  TextStyle get titleBarText;
  TextStyle get sectionHeader;
  TextStyle get dialogTitle;
  TextStyle get dialogSectionTitle;
  TextStyle get inputLabel;
  TextStyle get textFieldInput;
  TextStyle get textFieldLabel;
  TextStyle get textFieldHint;
  TextStyle get tileTitle;
  TextStyle get tileSubtitle;
  TextStyle get dropdownText;
  TextStyle get dropdownItem;
  TextStyle get actionText;
  TextStyle get subtleAction;
  TextStyle get cancelAction;
  TextStyle get infoText;
  TextStyle get badgeCounter;
  TextStyle get imageCounter;
  TextStyle get addImageLabel;
  TextStyle get overlayHint;
  TextStyle get overlaySubtext;
  TextStyle get overlayCountdown;
  TextStyle get overlayTimer;
  TextStyle get phaseLabel;
  TextStyle get phaseCount;
  TextStyle get classLabel;
  TextStyle get audioToggle;
  TextStyle get imagesNeeded;
  TextStyle get configValue;
  TextStyle get timerValue;
  TextStyle get timerDisplay;
  TextStyle get emptyStateText;
  TextStyle get errorText;
  TextStyle get filterClear;
  TextStyle get dialogBreakLabel;
  TextStyle get dialogBreakSubtext;
  TextStyle get dialogDropdownItem;
}

class BaseTypography implements TypographySet {
  final ColorPalette palette;
  final FontConfig fontConfig;

  const BaseTypography(this.palette, this.fontConfig);

  TextStyle _style({
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontConfig.fontFamily,
      fontSize: fontSize * fontConfig.baseScale,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }

  @override TextStyle get cardTitle => _style(
    color: palette.textOnDark, fontSize: 14, fontWeight: FontWeight.w500,
  );

  @override TextStyle get cardSubtitle => _style(
    color: palette.textTertiary, fontSize: 12,
  );

  @override TextStyle get badge => _style(
    color: palette.textOnDark, fontSize: 10, fontWeight: FontWeight.bold,
  );

  @override TextStyle get overlayTitle => _style(
    color: palette.textOnDark, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 6,
  );

  @override TextStyle get overlayText => _style(
    color: palette.textSecondary, fontSize: 13,
  );

  @override TextStyle get screenTitle => _style(
    color: palette.textOnDark, fontSize: 22, fontWeight: FontWeight.bold,
  );

  @override TextStyle get appBarTitle => _style(
    color: palette.textOnDark, fontWeight: FontWeight.w500,
  );

  @override TextStyle get titleBarText => _style(
    color: palette.textOnDark, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.3,
  );

  @override TextStyle get sectionHeader => _style(
    color: palette.textSecondary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.5,
  );

  @override TextStyle get dialogTitle => _style(
    color: palette.textOnDark, fontSize: 16, fontWeight: FontWeight.w600,
  );

  @override TextStyle get dialogSectionTitle => _style(
    color: palette.textOnDark, fontWeight: FontWeight.bold, fontSize: 14,
  );

  @override TextStyle get inputLabel => _style(
    color: palette.textOnDarkMedium, fontSize: 13,
  );

  @override TextStyle get textFieldInput => _style(
    color: palette.textOnDark, fontSize: 14,
  );

  @override TextStyle get textFieldLabel => _style(
    color: palette.textTertiary, fontSize: 13,
  );

  @override TextStyle get textFieldHint => _style(
    color: palette.textOnDarkSubtle,
  );

  @override TextStyle get tileTitle => _style(
    color: palette.textOnDark, fontSize: 14, fontWeight: FontWeight.w500,
  );

  @override TextStyle get tileSubtitle => _style(
    color: palette.textSecondary, fontSize: 12,
  );

  @override TextStyle get dropdownText => _style(
    color: palette.textOnDark, fontSize: 13,
  );

  @override TextStyle get dropdownItem => _style(
    color: palette.textOnDarkMedium,
  );

  @override TextStyle get actionText => _style(
    color: palette.textSecondary,
  );

  @override TextStyle get subtleAction => _style(
    color: palette.textOnDarkSubtle,
  );

  @override TextStyle get cancelAction => _style(
    color: palette.textOnDarkSubtle,
  );

  @override TextStyle get infoText => _style(
    color: palette.textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
  );

  @override TextStyle get badgeCounter => _style(
    color: palette.primaryLight, fontSize: 11, fontWeight: FontWeight.w500,
  );

  @override TextStyle get imageCounter => _style(
    color: palette.primaryLight, fontSize: 12, fontWeight: FontWeight.w500,
  );

  @override TextStyle get addImageLabel => _style(
    color: palette.primaryLight, fontSize: 13,
  );

  @override TextStyle get overlayHint => _style(
    color: palette.textSecondary, fontSize: 14,
  );

  @override TextStyle get overlaySubtext => _style(
    color: palette.textSecondary, fontSize: 12, letterSpacing: 3,
  );

  @override TextStyle get overlayCountdown => _style(
    color: palette.textOnDark, fontSize: 48, fontWeight: FontWeight.bold,
  );

  @override TextStyle get overlayTimer => _style(
    color: palette.textOnDark, fontSize: 14, fontWeight: FontWeight.bold,
  );

  @override TextStyle get phaseLabel => _style(
    color: palette.onSurface, fontSize: 10, fontWeight: FontWeight.bold,
  );

  @override TextStyle get phaseCount => _style(
    color: palette.onSurface.withValues(alpha: 0.5), fontSize: 10,
  );

  @override TextStyle get classLabel => _style(
    color: palette.textOnDark, fontSize: 11, fontWeight: FontWeight.w500,
  );

  @override TextStyle get audioToggle => _style(
    color: palette.textOnDark, fontSize: 10, fontWeight: FontWeight.bold,
  );

  @override TextStyle get imagesNeeded => _style(
    color: palette.textOnDark, fontWeight: FontWeight.bold,
  );

  @override TextStyle get configValue => _style(
    color: palette.textOnDark, fontWeight: FontWeight.bold,
  );

  @override TextStyle get timerValue => _style(
    color: palette.onSurface, fontWeight: FontWeight.bold,
  );

  @override TextStyle get timerDisplay => _style(
    color: palette.textOnDark, fontWeight: FontWeight.bold, fontSize: 20,
  );

  @override TextStyle get emptyStateText => _style(
    color: palette.textOnDarkSubtle, fontSize: 18,
  );

  @override TextStyle get errorText => _style(
    color: palette.textOnDarkSubtle,
  );

  @override TextStyle get filterClear => _style(
    color: palette.error,
  );

  @override TextStyle get dialogBreakLabel => _style(
    color: palette.textOnDarkMedium, fontSize: 13,
  );

  @override TextStyle get dialogBreakSubtext => _style(
    color: palette.textOnDarkSubtle, fontSize: 13,
  );

  @override TextStyle get dialogDropdownItem => _style(
    color: palette.textOnDarkMedium,
  );
}
