enum PaletteChoice {
  royalBlue,
  emerald,
  ruby,
  amethyst,
  slate;

  String get label => switch (this) {
        royalBlue => 'Royal Blue',
        emerald => 'Emerald',
        ruby => 'Ruby',
        amethyst => 'Amethyst',
        slate => 'Slate',
      };
}

enum StyleChoice {
  skeuomorphic,
  flat;

  String get label => switch (this) {
        skeuomorphic => 'Skeuomorphic',
        flat => 'Flat',
      };
}

class FontConfig {
  final String fontFamily;
  final double baseScale;

  const FontConfig({
    this.fontFamily = 'Segoe UI',
    this.baseScale = 1.0,
  });

  FontConfig copyWith({String? fontFamily, double? baseScale}) =>
      FontConfig(
        fontFamily: fontFamily ?? this.fontFamily,
        baseScale: baseScale ?? this.baseScale,
      );

  static const List<String> commonFamilies = [
    'Segoe UI',
    'Arial',
    'Georgia',
    'Times New Roman',
    'Courier New',
    'Verdana',
    'Tahoma',
    'Trebuchet MS',
    'Impact',
    'Comic Sans MS',
  ];
}
