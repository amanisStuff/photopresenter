import 'theme_composition.dart';
import 'theme_choices.dart';
import 'colors.dart';
import 'typography.dart';
import 'decorations.dart';

class LightThemeStyle extends ComposedThemeStyle {
  LightThemeStyle()
      : super(
          palette: const RoyalBlueLight(),
          typography: BaseTypography(const RoyalBlueLight(), const FontConfig()),
          decorations: SkeuomorphicDecorations(const RoyalBlueLight()),
        );
}
