// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Top-down festive car marker for [season] (nose up, 120×240 px), as an asset
/// key for `rootBundle`; null outside a season, where each app keeps its own car.
String? festiveCarAsset(SeasonalTheme season) => switch (season) {
      SeasonalTheme.none => null,
      SeasonalTheme.halloween =>
        'packages/app_theme/assets/vehicle_icons/halloween_pumpkin.png',
      SeasonalTheme.christmas =>
        'packages/app_theme/assets/vehicle_icons/christmas_reindeer.png',
      SeasonalTheme.newYear =>
        'packages/app_theme/assets/vehicle_icons/newyear_fireworks.png',
    };
