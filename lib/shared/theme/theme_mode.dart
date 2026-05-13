/// Represents the user's theme mode preference.
enum ThemeModeChoice {
  light,
  dark,
  system;

  String get label => switch (this) {
        light => 'Light',
        dark => 'Dark',
        system => 'System',
      };
}