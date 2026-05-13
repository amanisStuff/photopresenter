import 'package:flutter/material.dart';

// ============================================================
// Theme Strategy Pattern - Abstract Interface
// ============================================================
/// Concrete implementations (DarkThemeStyle, LightThemeStyle)
/// provide the actual values, enabling runtime theme switching.
abstract class ThemeStyle {
  // ── Core Palette ──
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

  // ── Backgrounds ──
  Color get background;
  Color get surfaceCard;
  Color get surfaceDark;
  Color get surfaceOverlay;
  Color get onSurface;
  Color get surfaceDropdown;

  // ── Text Colors ──
  Color get textSecondary;
  Color get textTertiary;
  Color get textOnDark;
  Color get textOnDarkMedium;
  Color get textOnDarkSubtle;

  // ── Gradient / Scene Colors ──
  Color get breakBackgroundStart;
  Color get breakBackgroundEnd;
  Color get screenBackgroundStart;
  Color get screenBackgroundEnd;
  Color get badgeText;

  // ── Button Gradients ──
  Color get buttonGradientTop;
  Color get buttonGradientMid;
  Color get buttonGradientBottom;
  Color get insetBorderDark;

  // ── Typography ──
  TextStyle get cardTitleStyle;
  TextStyle get cardSubtitleStyle;
  TextStyle get badgeStyle;
  TextStyle get overlayTitleStyle;
  TextStyle get overlayTextStyle;
  TextStyle get screenTitleStyle;
  TextStyle get appBarTitleStyle;
  TextStyle get titleBarTextStyle;
  TextStyle get sectionHeaderStyle;
  TextStyle get dialogTitleStyle;
  TextStyle get dialogSectionTitleStyle;
  TextStyle get inputLabelStyle;
  TextStyle get textFieldInputStyle;
  TextStyle get textFieldLabelStyle;
  TextStyle get textFieldHintStyle;
  TextStyle get tileTitleStyle;
  TextStyle get tileSubtitleStyle;
  TextStyle get dropdownTextStyle;
  TextStyle get dropdownItemStyle;
  TextStyle get actionTextStyle;
  TextStyle get subtleActionStyle;
  TextStyle get cancelActionStyle;
  TextStyle get infoTextStyle;
  TextStyle get badgeCounterStyle;
  TextStyle get imageCounterStyle;
  TextStyle get addImageLabelStyle;
  TextStyle get overlayHintStyle;
  TextStyle get overlaySubtextStyle;
  TextStyle get overlayCountdownStyle;
  TextStyle get overlayTimerStyle;
  TextStyle get phaseLabelStyle;
  TextStyle get phaseCountStyle;
  TextStyle get classLabelStyle;
  TextStyle get audioToggleStyle;
  TextStyle get imagesNeededStyle;
  TextStyle get configValueStyle;
  TextStyle get timerValueStyle;
  TextStyle get timerDisplayStyle;
  TextStyle get emptyStateTextStyle;
  TextStyle get errorTextStyle;
  TextStyle get filterClearStyle;
  TextStyle get dialogBreakLabelStyle;
  TextStyle get dialogBreakSubtextStyle;
  TextStyle get dialogDropdownItemStyle;

  // ── Decorations ──
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

  // ── Flutter ThemeData ──
  ThemeData get themeData;
}