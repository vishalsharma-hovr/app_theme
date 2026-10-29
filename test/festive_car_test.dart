import 'dart:io';

import 'package:app_theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each festive season has its own car, none outside a season', () {
    expect(festiveCarAsset(SeasonalTheme.none), isNull);
    expect(
      festiveCarAsset(SeasonalTheme.halloween),
      'packages/app_theme/assets/vehicle_icons/halloween_pumpkin.png',
    );
    expect(
      festiveCarAsset(SeasonalTheme.christmas),
      'packages/app_theme/assets/vehicle_icons/christmas_reindeer.png',
    );
    expect(
      festiveCarAsset(SeasonalTheme.newYear),
      'packages/app_theme/assets/vehicle_icons/newyear_fireworks.png',
    );
  });

  test('every festive car is a PNG in this package', () {
    const pngSignature = [0x89, 0x50, 0x4E, 0x47];
    for (final season in SeasonalTheme.values) {
      final asset = festiveCarAsset(season);
      if (asset == null) continue;
      final bytes =
          File(asset.replaceFirst('packages/app_theme/', '')).readAsBytesSync();
      expect(bytes.take(4), pngSignature, reason: asset);
    }
  });
}
