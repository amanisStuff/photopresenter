import 'package:flutter/material.dart';
import 'theme_style.dart';
import 'colors.dart';
import 'typography.dart';
import 'decorations.dart';

class ComposedThemeStyle implements ThemeStyle {
  final ColorPalette palette;
  final TypographySet typography;
  final DecorationSet decorations;

  const ComposedThemeStyle({
    required this.palette,
    required this.typography,
    required this.decorations,
  });

  @override Color get primary => palette.primary;
  @override Color get primaryDark => palette.primaryDark;
  @override Color get primaryLight => palette.primaryLight;
  @override Color get surfaceLightest => palette.surfaceLightest;
  @override Color get secondary => palette.secondary;
  @override Color get surfaceMuted => palette.surfaceMuted;
  @override Color get border => palette.border;
  @override Color get success => palette.success;
  @override Color get successDark => palette.successDark;
  @override Color get error => palette.error;
  @override Color get background => palette.background;
  @override Color get surfaceCard => palette.surfaceCard;
  @override Color get surfaceDark => palette.surfaceDark;
  @override Color get surfaceOverlay => palette.surfaceOverlay;
  @override Color get onSurface => palette.onSurface;
  @override Color get surfaceDropdown => palette.surfaceDropdown;
  @override Color get textSecondary => palette.textSecondary;
  @override Color get textTertiary => palette.textTertiary;
  @override Color get textOnDark => palette.textOnDark;
  @override Color get textOnDarkMedium => palette.textOnDarkMedium;
  @override Color get textOnDarkSubtle => palette.textOnDarkSubtle;
  @override Color get breakBackgroundStart => palette.breakBackgroundStart;
  @override Color get breakBackgroundEnd => palette.breakBackgroundEnd;
  @override Color get screenBackgroundStart => palette.screenBackgroundStart;
  @override Color get screenBackgroundEnd => palette.screenBackgroundEnd;
  @override Color get badgeText => palette.badgeText;
  @override Color get buttonGradientTop => palette.buttonGradientTop;
  @override Color get buttonGradientMid => palette.buttonGradientMid;
  @override Color get buttonGradientBottom => palette.buttonGradientBottom;
  @override Color get insetBorderDark => palette.insetBorderDark;

  @override TextStyle get cardTitleStyle => typography.cardTitle;
  @override TextStyle get cardSubtitleStyle => typography.cardSubtitle;
  @override TextStyle get badgeStyle => typography.badge;
  @override TextStyle get overlayTitleStyle => typography.overlayTitle;
  @override TextStyle get overlayTextStyle => typography.overlayText;
  @override TextStyle get screenTitleStyle => typography.screenTitle;
  @override TextStyle get appBarTitleStyle => typography.appBarTitle;
  @override TextStyle get titleBarTextStyle => typography.titleBarText;
  @override TextStyle get sectionHeaderStyle => typography.sectionHeader;
  @override TextStyle get dialogTitleStyle => typography.dialogTitle;
  @override TextStyle get dialogSectionTitleStyle => typography.dialogSectionTitle;
  @override TextStyle get inputLabelStyle => typography.inputLabel;
  @override TextStyle get textFieldInputStyle => typography.textFieldInput;
  @override TextStyle get textFieldLabelStyle => typography.textFieldLabel;
  @override TextStyle get textFieldHintStyle => typography.textFieldHint;
  @override TextStyle get tileTitleStyle => typography.tileTitle;
  @override TextStyle get tileSubtitleStyle => typography.tileSubtitle;
  @override TextStyle get dropdownTextStyle => typography.dropdownText;
  @override TextStyle get dropdownItemStyle => typography.dropdownItem;
  @override TextStyle get actionTextStyle => typography.actionText;
  @override TextStyle get subtleActionStyle => typography.subtleAction;
  @override TextStyle get cancelActionStyle => typography.cancelAction;
  @override TextStyle get infoTextStyle => typography.infoText;
  @override TextStyle get badgeCounterStyle => typography.badgeCounter;
  @override TextStyle get imageCounterStyle => typography.imageCounter;
  @override TextStyle get addImageLabelStyle => typography.addImageLabel;
  @override TextStyle get overlayHintStyle => typography.overlayHint;
  @override TextStyle get overlaySubtextStyle => typography.overlaySubtext;
  @override TextStyle get overlayCountdownStyle => typography.overlayCountdown;
  @override TextStyle get overlayTimerStyle => typography.overlayTimer;
  @override TextStyle get phaseLabelStyle => typography.phaseLabel;
  @override TextStyle get phaseCountStyle => typography.phaseCount;
  @override TextStyle get classLabelStyle => typography.classLabel;
  @override TextStyle get audioToggleStyle => typography.audioToggle;
  @override TextStyle get imagesNeededStyle => typography.imagesNeeded;
  @override TextStyle get configValueStyle => typography.configValue;
  @override TextStyle get timerValueStyle => typography.timerValue;
  @override TextStyle get timerDisplayStyle => typography.timerDisplay;
  @override TextStyle get emptyStateTextStyle => typography.emptyStateText;
  @override TextStyle get errorTextStyle => typography.errorText;
  @override TextStyle get filterClearStyle => typography.filterClear;
  @override TextStyle get dialogBreakLabelStyle => typography.dialogBreakLabel;
  @override TextStyle get dialogBreakSubtextStyle => typography.dialogBreakSubtext;
  @override TextStyle get dialogDropdownItemStyle => typography.dialogDropdownItem;

  @override BoxDecoration get controlsBar => decorations.controlsBar;
  @override BoxDecoration get headerDecoration => decorations.headerDecoration;
  @override List<BoxShadow> get bevelInset => decorations.bevelInset;
  @override BoxDecoration buttonDecoration({bool pressed = false, bool isPlay = false}) =>
      decorations.buttonDecoration(pressed: pressed, isPlay: isPlay);
  @override BoxDecoration pillButton({bool active = false}) =>
      decorations.pillButton(active: active);
  @override BoxDecoration taskPaneTile({bool selected = false}) =>
      decorations.taskPaneTile(selected: selected);
  @override BoxDecoration controlButton({bool disabled = false}) =>
      decorations.controlButton(disabled: disabled);
  @override BoxDecoration get tileOuterDecoration => decorations.tileOuterDecoration;
  @override BoxDecoration get tileAccentBarDecoration => decorations.tileAccentBarDecoration;
  @override BoxDecoration get tileContentDecoration => decorations.tileContentDecoration;
  @override BoxDecoration get settingsBackground => decorations.settingsBackground;
  @override BoxDecoration get presentationBackground => decorations.presentationBackground;

  @override
  ThemeData get themeData => _build(Brightness.light);

  ThemeData themeDataFor(Brightness brightness) => _build(brightness);

  ThemeData _build(Brightness brightness) {
    final c = palette;
    final ty = typography;
    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary, secondary: c.secondary,
        tertiary: c.success, surface: c.background,
        onSurface: c.textOnDark, onPrimary: c.textOnDark,
        onSecondary: c.onSurface, error: c.error, onError: c.textOnDark,
      ),
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        backgroundColor: brightness == Brightness.dark ? Colors.transparent : c.surfaceCard,
        elevation: 0, centerTitle: true,
        titleTextStyle: brightness == Brightness.dark ? null : ty.appBarTitle,
      ),
      cardTheme: CardThemeData(
        color: c.surfaceOverlay, elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.primary.withValues(alpha: 0.3), width: 1),
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
          foregroundColor: WidgetStateProperty.all(c.textOnDarkMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
          backgroundColor: WidgetStateProperty.all(c.primary),
          foregroundColor: WidgetStateProperty.all(c.textOnDark),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
    );
  }
}
