import 'theme_composition.dart';
import 'theme_choices.dart';
import 'colors.dart';
import 'typography.dart';
import 'decorations.dart';

class DarkThemeStyle extends ComposedThemeStyle {
  DarkThemeStyle()
      : super(
          palette: const RoyalBlueDark(),
          typography: BaseTypography(const RoyalBlueDark(), const FontConfig()),
          decorations: SkeuomorphicDecorations(const RoyalBlueDark()),
        );
}
