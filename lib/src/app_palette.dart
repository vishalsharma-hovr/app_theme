// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// The `AppColors` neutrals, text and status colours that change in dark mode.
///
/// Read with `context.colors.grey500` instead of `AppColors.grey500` so the
/// colour follows light/dark. Brand greens live in [BrandColors]
/// (`context.brand`); colours that look the same in both modes (map pins,
/// warning icons, transparent) stay on `AppColors`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Defaults are the light `AppColors` values; pass only what differs.
  const AppPalette({
    this.white000 = AppColors.white000,
    this.white = Colors.white,
    this.black900 = AppColors.black900,
    this.black = Colors.black,
    this.bgColor = AppColors.bgColor,
    this.grey012 = AppColors.grey012,
    this.grey025 = AppColors.grey025,
    this.grey050 = AppColors.grey050,
    this.grey100 = AppColors.grey100,
    this.grey200 = AppColors.grey200,
    this.grey300 = AppColors.grey300,
    this.grey400 = AppColors.grey400,
    this.grey500 = AppColors.grey500,
    this.grey600 = AppColors.grey600,
    this.grey700 = AppColors.grey700,
    this.grey800 = AppColors.grey800,
    this.grey900 = AppColors.grey900,
    this.grey444 = DriverAppColor.grey444,
    this.blue050 = AppColors.blue050,
    this.orange050 = AppColors.orange050,
    this.textFormFieldBackgroundColor = AppColors.textFormFieldBackgroundColor,
    this.errorColor = AppColors.errorColor,
    this.greyColor = AppColors.greyColor,
    this.buttonBackgroundColor = AppColors.buttonBackgroundColor,
    this.referAndEarnArrowBgColor = AppColors.referAndEarnArrowBgColor,
    this.textColor = AppColors.textColor,
    this.backArrowButtonBackgroundColor = AppColors.backArrowButtonBackgroundColor,
    this.warningContainerBackgroundErrorColor = AppColors.warningContainerBackgroundErrorColor,
    this.warningColorsStringColors = AppColors.warningColorsStringColors,
    this.logoutIconAndTextColors = AppColors.logoutIconAndTextColors,
    this.complaintSelectedColor = AppColors.complaintSelectedColor,
    this.textPrimary = AppColors.textPrimary,
    this.textSecondary = AppColors.textSecondary,
    this.textMuted = AppColors.textMuted,
    this.textMuted61 = AppColors.textMuted61,
    this.textMuted2 = AppColors.textMuted2,
    this.bgMuted = AppColors.bgMuted,
    this.iconMuted = AppColors.iconMuted,
    this.unKnownTextColor = AppColors.unKnownTextColor,
    this.blueRatingColors = AppColors.blueRatingColors,
    this.goOfflineButtonColors = AppColors.goOfflineButtonColors,
    this.whiteColorButton = AppColors.whiteColorButton,
    this.lightBlue = AppColors.lightBlue,
    this.recommededNextStep = AppColors.recommededNextStep,
    this.warningAlertsBackgroundColor = AppColors.warningAlertsBackgroundColor,
    this.criticalAlertsBackgroundColor = AppColors.criticalAlertsBackgroundColor,
    this.criticalAlertIconColor = AppColors.criticalAlertIconColor,
    this.successColor = AppColors.successColor,
    this.warningColor = AppColors.warningColor,
  });

  final Color white000;
  final Color white;
  final Color black900;
  final Color black;
  final Color bgColor;
  final Color grey012;
  final Color grey025;
  final Color grey050;
  final Color grey100;
  final Color grey200;
  final Color grey300;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color grey800;
  final Color grey900;
  final Color grey444;
  final Color blue050;
  final Color orange050;
  final Color textFormFieldBackgroundColor;
  final Color errorColor;
  final Color greyColor;
  final Color buttonBackgroundColor;
  final Color referAndEarnArrowBgColor;
  final Color textColor;
  final Color backArrowButtonBackgroundColor;
  final Color warningContainerBackgroundErrorColor;
  final Color warningColorsStringColors;
  final Color logoutIconAndTextColors;
  final Color complaintSelectedColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textMuted61;
  final Color textMuted2;
  final Color bgMuted;
  final Color iconMuted;
  final Color unKnownTextColor;
  final Color blueRatingColors;
  final Color goOfflineButtonColors;
  final Color whiteColorButton;
  final Color lightBlue;
  final Color recommededNextStep;
  final Color warningAlertsBackgroundColor;
  final Color criticalAlertsBackgroundColor;
  final Color criticalAlertIconColor;

  /// Success state; green in every season, readable on [white000].
  final Color successColor;

  /// Warning state; amber in every season, readable on [white000].
  final Color warningColor;

  /// Rider app light mode: exactly `AppColors`.
  static const light = AppPalette();

  /// Driver app light mode: `AppColors` plus the values `DriverAppColor` changes.
  static const driverLight = AppPalette(
    grey012: DriverAppColor.grey012,
    errorColor: DriverAppColor.errorColor,
  );

  /// Dark mode for both apps. The light scale is mirrored: white surfaces turn
  /// near-black, black text turns near-white, and greys swap ends so a grey
  /// used as text stays readable and one used as a background stays subtle.
  static const dark = AppPalette(
    white000: Color(0xFF161615),
    white: Color(0xFF161615),
    black900: Color(0xFFF2F3F1),
    black: Color(0xFFF2F3F1),
    bgColor: Color(0xFF0D0D0C),
    grey012: Color(0xFF1E1E1D),
    grey025: Color(0xFF262625),
    grey050: Color(0xFF353533),
    grey100: Color(0xFF474745),
    grey200: Color(0xFF7A7B79),
    grey300: Color(0xFF8C8D8B),
    grey400: Color(0xFF8C8D8B),
    grey500: Color(0xFFA0A19F),
    grey600: Color(0xFFB9BAB7),
    grey700: Color(0xFFD2D3D0),
    grey800: Color(0xFFE8E9E6),
    grey900: Color(0xFFC8C8C8),
    grey444: Color(0xFFC8C8C8),
    blue050: Color(0xFF1E2D46),
    orange050: Color(0xFF41280F),
    textFormFieldBackgroundColor: Color(0xFF262625),
    errorColor: Color(0xFFF87171),
    greyColor: Color(0xFF262625),
    buttonBackgroundColor: Color(0xFF2A2A29),
    referAndEarnArrowBgColor: Color(0xFF262625),
    textColor: Color(0xFFF87171),
    backArrowButtonBackgroundColor: Color(0xFF262625),
    warningContainerBackgroundErrorColor: Color(0xFF37341E),
    warningColorsStringColors: Color(0xFFD7C85A),
    logoutIconAndTextColors: Color(0xFFF87171),
    complaintSelectedColor: Color(0xFFECECEC),
    textPrimary: Color(0xFFECECEC),
    textSecondary: Color(0xFFBEBEC0),
    textMuted: Color(0xFF8E8E90),
    textMuted61: Color(0xFFA1A1A3),
    textMuted2: Color(0xFF969698),
    bgMuted: Color(0xFF2D2D2E),
    iconMuted: Color(0xFF969698),
    unKnownTextColor: Color(0xFFC8C8C8),
    blueRatingColors: Color(0xFF7AA0F0),
    goOfflineButtonColors: Color(0xFF8C8D8B),
    whiteColorButton: Color(0xFF2A2A29),
    lightBlue: Color(0xFF60A5FA),
    recommededNextStep: Color(0xFF60A5FA),
    warningAlertsBackgroundColor: Color(0xFF3A3014),
    criticalAlertsBackgroundColor: Color(0xFF3C181A),
    criticalAlertIconColor: Color(0xFFF87171),
    successColor: Color(0xFF4ADE80),
    warningColor: Color(0xFFFBBF24),
  );

  /// The palette in [context]'s theme, or [light] when none is attached.
  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  @override
  AppPalette copyWith() => this;

  // shortcut: snaps instead of blending, so a light/dark switch is instant; blend
  // per colour if an animated theme change is ever wanted.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette && t >= 0.5 ? other : this;
}

extension AppPaletteContext on BuildContext {
  /// Light/dark-aware colours; see [AppPalette].
  AppPalette get colors => AppPalette.of(this);
}
