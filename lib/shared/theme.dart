import 'package:flutter/material.dart';

import 'theme/theme_style.dart';
import 'theme/dark_theme_style.dart';
import 'theme/theme_notifier.dart';

// ============================================================
// Static Facade (delegates to the active ThemeStyle strategy)
// ============================================================

/// Top-level entry point for all visual tokens.  Every widget uses
/// `AppTheme.xxx` instead of hardcoding colours, text styles, or
/// decoration values.  Internally the calls are forwarded to the
/// currently active [ThemeStyle] which can be swapped at runtime
/// via [ThemeNotifier].
class AppTheme {
  AppTheme._();

  // The style backing the facade, kept in sync by ThemeNotifier.
  static ThemeStyle _currentStyle = DarkThemeStyle();

  static void setCurrent(ThemeStyle style) => _currentStyle = style;
  static ThemeStyle get current => _currentStyle;

  // ── Core Palette ──
  static Color get primary => _currentStyle.primary;
  static Color get primaryDark => _currentStyle.primaryDark;
  static Color get primaryLight => _currentStyle.primaryLight;
  static Color get surfaceLightest => _currentStyle.surfaceLightest;
  static Color get secondary => _currentStyle.secondary;
  static Color get surfaceMuted => _currentStyle.surfaceMuted;
  static Color get border => _currentStyle.border;
  static Color get success => _currentStyle.success;
  static Color get successDark => _currentStyle.successDark;
  static Color get error => _currentStyle.error;

  // ── Backgrounds ──
  static Color get background => _currentStyle.background;
  static Color get surfaceCard => _currentStyle.surfaceCard;
  static Color get surfaceDark => _currentStyle.surfaceDark;
  static Color get surfaceOverlay => _currentStyle.surfaceOverlay;
  static Color get onSurface => _currentStyle.onSurface;
  static Color get surfaceDropdown => _currentStyle.surfaceDropdown;

  // ── Text Colors ──
  static Color get textSecondary => _currentStyle.textSecondary;
  static Color get textTertiary => _currentStyle.textTertiary;
  static Color get textOnDark => _currentStyle.textOnDark;
  static Color get textOnDarkMedium => _currentStyle.textOnDarkMedium;
  static Color get textOnDarkSubtle => _currentStyle.textOnDarkSubtle;

  // ── Gradient / Scene Colors ──
  static Color get breakBackgroundStart => _currentStyle.breakBackgroundStart;
  static Color get breakBackgroundEnd => _currentStyle.breakBackgroundEnd;
  static Color get screenBackgroundStart => _currentStyle.screenBackgroundStart;
  static Color get screenBackgroundEnd => _currentStyle.screenBackgroundEnd;
  static Color get badgeText => _currentStyle.badgeText;

  // ── Button Gradients ──
  static Color get buttonGradientTop => _currentStyle.buttonGradientTop;
  static Color get buttonGradientMid => _currentStyle.buttonGradientMid;
  static Color get buttonGradientBottom => _currentStyle.buttonGradientBottom;
  static Color get insetBorderDark => _currentStyle.insetBorderDark;

  // ── Typography ──
  static TextStyle get cardTitleStyle => _currentStyle.cardTitleStyle;
  static TextStyle get cardSubtitleStyle => _currentStyle.cardSubtitleStyle;
  static TextStyle get badgeStyle => _currentStyle.badgeStyle;
  static TextStyle get overlayTitleStyle => _currentStyle.overlayTitleStyle;
  static TextStyle get overlayTextStyle => _currentStyle.overlayTextStyle;
  static TextStyle get screenTitleStyle => _currentStyle.screenTitleStyle;
  static TextStyle get appBarTitleStyle => _currentStyle.appBarTitleStyle;
  static TextStyle get titleBarTextStyle => _currentStyle.titleBarTextStyle;
  static TextStyle get sectionHeaderStyle => _currentStyle.sectionHeaderStyle;
  static TextStyle get dialogTitleStyle => _currentStyle.dialogTitleStyle;
  static TextStyle get dialogSectionTitleStyle =>
      _currentStyle.dialogSectionTitleStyle;
  static TextStyle get inputLabelStyle => _currentStyle.inputLabelStyle;
  static TextStyle get textFieldInputStyle => _currentStyle.textFieldInputStyle;
  static TextStyle get textFieldLabelStyle => _currentStyle.textFieldLabelStyle;
  static TextStyle get textFieldHintStyle => _currentStyle.textFieldHintStyle;
  static TextStyle get tileTitleStyle => _currentStyle.tileTitleStyle;
  static TextStyle get tileSubtitleStyle => _currentStyle.tileSubtitleStyle;
  static TextStyle get dropdownTextStyle => _currentStyle.dropdownTextStyle;
  static TextStyle get dropdownItemStyle => _currentStyle.dropdownItemStyle;
  static TextStyle get actionTextStyle => _currentStyle.actionTextStyle;
  static TextStyle get subtleActionStyle => _currentStyle.subtleActionStyle;
  static TextStyle get cancelActionStyle => _currentStyle.cancelActionStyle;
  static TextStyle get infoTextStyle => _currentStyle.infoTextStyle;
  static TextStyle get badgeCounterStyle => _currentStyle.badgeCounterStyle;
  static TextStyle get imageCounterStyle => _currentStyle.imageCounterStyle;
  static TextStyle get addImageLabelStyle => _currentStyle.addImageLabelStyle;
  static TextStyle get overlayHintStyle => _currentStyle.overlayHintStyle;
  static TextStyle get overlaySubtextStyle => _currentStyle.overlaySubtextStyle;
  static TextStyle get overlayCountdownStyle =>
      _currentStyle.overlayCountdownStyle;
  static TextStyle get overlayTimerStyle => _currentStyle.overlayTimerStyle;
  static TextStyle get phaseLabelStyle => _currentStyle.phaseLabelStyle;
  static TextStyle get phaseCountStyle => _currentStyle.phaseCountStyle;
  static TextStyle get classLabelStyle => _currentStyle.classLabelStyle;
  static TextStyle get audioToggleStyle => _currentStyle.audioToggleStyle;
  static TextStyle get imagesNeededStyle => _currentStyle.imagesNeededStyle;
  static TextStyle get configValueStyle => _currentStyle.configValueStyle;
  static TextStyle get timerValueStyle => _currentStyle.timerValueStyle;
  static TextStyle get timerDisplayStyle => _currentStyle.timerDisplayStyle;
  static TextStyle get emptyStateTextStyle => _currentStyle.emptyStateTextStyle;
  static TextStyle get errorTextStyle => _currentStyle.errorTextStyle;
  static TextStyle get filterClearStyle => _currentStyle.filterClearStyle;
  static TextStyle get dialogBreakLabelStyle =>
      _currentStyle.dialogBreakLabelStyle;
  static TextStyle get dialogBreakSubtextStyle =>
      _currentStyle.dialogBreakSubtextStyle;
  static TextStyle get dialogDropdownItemStyle =>
      _currentStyle.dialogDropdownItemStyle;

  // ── Decorations ──
  static BoxDecoration get controlsBar => _currentStyle.controlsBar;
  static BoxDecoration get headerDecoration => _currentStyle.headerDecoration;
  static List<BoxShadow> get bevelInset => _currentStyle.bevelInset;
  static BoxDecoration buttonDecoration(
          {bool pressed = false, bool isPlay = false}) =>
      _currentStyle.buttonDecoration(pressed: pressed, isPlay: isPlay);
  static BoxDecoration pillButton({bool active = false}) =>
      _currentStyle.pillButton(active: active);
  static BoxDecoration taskPaneTile({bool selected = false}) =>
      _currentStyle.taskPaneTile(selected: selected);
  static BoxDecoration controlButton({bool disabled = false}) =>
      _currentStyle.controlButton(disabled: disabled);
  static BoxDecoration get tileOuterDecoration => _currentStyle.tileOuterDecoration;
  static BoxDecoration get tileAccentBarDecoration =>
      _currentStyle.tileAccentBarDecoration;
  static BoxDecoration get tileContentDecoration => _currentStyle.tileContentDecoration;
  static BoxDecoration get settingsBackground => _currentStyle.settingsBackground;
  static BoxDecoration get presentationBackground =>
      _currentStyle.presentationBackground;

  static ThemeData get darkTheme => DarkThemeStyle().themeData;
}