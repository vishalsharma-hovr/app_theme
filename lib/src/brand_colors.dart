// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// The brand accent (the `AppColors` / `DriverAppColor` greens), swapped per
/// season ([forSeason]) and mirrored for dark mode ([dark]). Shared by the
/// rider and driver apps. Every colour code is listed in `doc/festive_colors.md`.
///
/// Read with `context.brand.green700` instead of `AppColors.green700` so the
/// accent follows [SeasonalTheme] and light/dark. HOVR icons use
/// `context.hovrBrand`, which never follows the season. Neutrals live in [AppPalette].
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.green012,
    required this.green025,
    required this.green050,
    required this.green056,
    required this.green100,
    required this.green200,
    required this.green300,
    required this.green400,
    required this.green500,
    required this.green600,
    required this.green700,
    required this.green800,
    required this.green900,
    required this.greenButton,
    required this.primaryColor,
    required this.brandPrimary,
  });

  final Color green012;
  final Color green025;
  final Color green050;
  final Color green056;
  final Color green100;
  final Color green200;
  final Color green300;
  final Color green400;
  final Color green500;
  final Color green600;
  final Color green700;
  final Color green800;
  final Color green900;
  final Color greenButton;
  final Color primaryColor;
  final Color brandPrimary;

  /// The year-round HOVR palette: exactly the existing `DriverAppColor` greens.
  /// Primary `#39851C`, the same in light and dark (see [forSeason]).
  static const standard = BrandColors(
    green012: DriverAppColor.green012,
    green025: DriverAppColor.green025,
    green050: DriverAppColor.green050,
    green056: DriverAppColor.green056,
    green100: DriverAppColor.green100,
    green200: DriverAppColor.green200,
    green300: DriverAppColor.green300,
    green400: DriverAppColor.green400,
    green500: DriverAppColor.green500,
    green600: DriverAppColor.green600,
    green700: DriverAppColor.green700,
    green800: DriverAppColor.green800,
    green900: DriverAppColor.green900,
    greenButton: DriverAppColor.greenButton,
    primaryColor: DriverAppColor.primaryColor,
    brandPrimary: DriverAppColor.brandPrimary,
  );

  /// Halloween: pumpkin orange. Primary `#C2410C` (dark `#FB923C`); tints
  /// `#FFF7ED`–`#FED7AA`. Strong tokens stay at least WCAG AA on white.
  static const halloween = BrandColors(
    green012: Color(0xFFFFF7ED),
    green025: Color(0xFFFFEDD5),
    green050: Color(0xFFFED7AA),
    green056: Color(0xFFC2410C),
    green100: Color(0xFFFDBA74),
    green200: Color(0xFFFB923C),
    green300: Color(0xFFF97316),
    green400: Color(0xFFC2410C),
    green500: Color(0xFF9A3412),
    green600: Color(0xFF9A3412),
    green700: Color(0xFF7C2D12),
    green800: Color(0xFF431407),
    green900: Color(0xFF2A0C03),
    greenButton: Color(0xFFC2410C),
    primaryColor: Color(0xFFC2410C),
    brandPrimary: Color(0xFFC2410C),
  );

  /// Christmas: deep pine. Primary `#15803D` (dark `#4ADE80`); tints
  /// `#F0FDF4`–`#BBF7D0`. No gold (New Year's) or orange (Halloween's), and no
  /// red, which stays the error colour.
  static const christmas = BrandColors(
    green012: Color(0xFFF0FDF4),
    green025: Color(0xFFDCFCE7),
    green050: Color(0xFFBBF7D0),
    green056: Color(0xFF15803D),
    green100: Color(0xFF86EFAC),
    green200: Color(0xFF4ADE80),
    green300: Color(0xFF22C55E),
    green400: Color(0xFF15803D),
    green500: Color(0xFF166534),
    green600: Color(0xFF14532D),
    green700: Color(0xFF0F3D22),
    green800: Color(0xFF052E16),
    green900: Color(0xFF021A0C),
    greenButton: Color(0xFF166534),
    primaryColor: Color(0xFF15803D),
    brandPrimary: Color(0xFF166534),
  );

  /// New Year: midnight indigo with gold tints. Primary `#4338CA` (dark gold
  /// `#EAB308`); tints `#FFFBEB`–`#FDE68A`. Strong tokens stay at least WCAG AA on white.
  static const newYear = BrandColors(
    green012: Color(0xFFFFFBEB),
    green025: Color(0xFFFEF3C7),
    green050: Color(0xFFFDE68A),
    green056: Color(0xFF4338CA),
    green100: Color(0xFFFCD34D),
    green200: Color(0xFFEAB308),
    green300: Color(0xFFCA8A04),
    green400: Color(0xFF4338CA),
    green500: Color(0xFF3730A3),
    green600: Color(0xFF312E81),
    green700: Color(0xFF1E1B4B),
    green800: Color(0xFF13112F),
    green900: Color(0xFF0A091A),
    greenButton: Color(0xFF3730A3),
    primaryColor: Color(0xFF4338CA),
    brandPrimary: Color(0xFF3730A3),
  );

  /// Dark-mode version: the scale is mirrored, so light tints (chip and card
  /// backgrounds) turn dark and strong greens (text, buttons) turn light.
  BrandColors get dark => BrandColors(
    green012: green800,
    green025: green700,
    green050: green600,
    green056: green200,
    green100: green500,
    green200: green400,
    green300: green300,
    green400: green200,
    green500: green100,
    green600: green050,
    green700: green025,
    green800: green012,
    green900: green012,
    greenButton: green200,
    primaryColor: green200,
    brandPrimary: green200,
  );

  /// The palette for [season]; [dark] gives its dark-mode version. Out of
  /// season the HOVR fills stay as in light mode (primary `#39851C`,
  /// [brandPrimary] `#148023`, [greenButton] `#308011`; white labels on them,
  /// 3.5–3.9:1 on the dark page, so use them for fills and icons); festive primaries
  /// use their lighter tone in dark (New Year's indigo is under 3:1 on dark).
  static BrandColors forSeason(SeasonalTheme season, {bool dark = false}) {
    final light = switch (season) {
      SeasonalTheme.none => standard,
      SeasonalTheme.halloween => halloween,
      SeasonalTheme.christmas => christmas,
      SeasonalTheme.newYear => newYear,
    };
    if (!dark) return light;
    if (season == SeasonalTheme.none) {
      // HOVR's button and primary greens are the brand: the same in both modes.
      return standard.dark.copyWith(
        primaryColor: standard.primaryColor,
        brandPrimary: standard.brandPrimary,
        greenButton: standard.greenButton,
      );
    }
    return light.dark;
  }

  /// The palette in [context]'s theme, or [standard] when none is attached.
  static BrandColors of(BuildContext context) =>
      Theme.of(context).extension<BrandColors>() ?? standard;

  @override
  BrandColors copyWith({
    Color? green012,
    Color? green025,
    Color? green050,
    Color? green056,
    Color? green100,
    Color? green200,
    Color? green300,
    Color? green400,
    Color? green500,
    Color? green600,
    Color? green700,
    Color? green800,
    Color? green900,
    Color? greenButton,
    Color? primaryColor,
    Color? brandPrimary,
  }) {
    return BrandColors(
      green012: green012 ?? this.green012,
      green025: green025 ?? this.green025,
      green050: green050 ?? this.green050,
      green056: green056 ?? this.green056,
      green100: green100 ?? this.green100,
      green200: green200 ?? this.green200,
      green300: green300 ?? this.green300,
      green400: green400 ?? this.green400,
      green500: green500 ?? this.green500,
      green600: green600 ?? this.green600,
      green700: green700 ?? this.green700,
      green800: green800 ?? this.green800,
      green900: green900 ?? this.green900,
      greenButton: greenButton ?? this.greenButton,
      primaryColor: primaryColor ?? this.primaryColor,
      brandPrimary: brandPrimary ?? this.brandPrimary,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return BrandColors(
      green012: mix(green012, other.green012),
      green025: mix(green025, other.green025),
      green050: mix(green050, other.green050),
      green056: mix(green056, other.green056),
      green100: mix(green100, other.green100),
      green200: mix(green200, other.green200),
      green300: mix(green300, other.green300),
      green400: mix(green400, other.green400),
      green500: mix(green500, other.green500),
      green600: mix(green600, other.green600),
      green700: mix(green700, other.green700),
      green800: mix(green800, other.green800),
      green900: mix(green900, other.green900),
      greenButton: mix(greenButton, other.greenButton),
      primaryColor: mix(primaryColor, other.primaryColor),
      brandPrimary: mix(brandPrimary, other.brandPrimary),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrandColors &&
      other.green012 == green012 &&
      other.green025 == green025 &&
      other.green050 == green050 &&
      other.green056 == green056 &&
      other.green100 == green100 &&
      other.green200 == green200 &&
      other.green300 == green300 &&
      other.green400 == green400 &&
      other.green500 == green500 &&
      other.green600 == green600 &&
      other.green700 == green700 &&
      other.green800 == green800 &&
      other.green900 == green900 &&
      other.greenButton == greenButton &&
      other.primaryColor == primaryColor &&
      other.brandPrimary == brandPrimary;

  @override
  int get hashCode => Object.hash(
    green012,
    green025,
    green050,
    green056,
    green100,
    green200,
    green300,
    green400,
    green500,
    green600,
    green700,
    green800,
    green900,
    greenButton,
    primaryColor,
    brandPrimary,
  );
}

extension BrandColorsContext on BuildContext {
  /// Seasonal brand accent; see [BrandColors].
  BrandColors get brand => BrandColors.of(this);

  /// Year-round HOVR palette for light/dark that never follows the season.
  /// Use it for HOVR icons ([HovrIcon]) so they keep their colour while the
  /// rest of the screen is festive.
  BrandColors get hovrBrand => BrandColors.forSeason(
        SeasonalTheme.none,
        dark: Theme.of(this).brightness == Brightness.dark,
      );
}
