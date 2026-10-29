import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _onMap(SeasonalTheme season, {bool reduceMotion = false}) =>
    MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 800),
        disableAnimations: reduceMotion,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(children: [MapSeasonalLayer(season: season)]),
      ),
    );

final _layer = find.byKey(MapSeasonalLayer.decorationKey);

void main() {
  testWidgets('shows nothing outside a season', (tester) async {
    await tester.pumpWidget(_onMap(SeasonalTheme.none));
    expect(_layer, findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('each festive season keeps animating over the map', (
    tester,
  ) async {
    for (final season in [
      SeasonalTheme.halloween,
      SeasonalTheme.christmas,
      SeasonalTheme.newYear,
    ]) {
      await tester.pumpWidget(_onMap(season));
      // Well past one cycle: the layer loops instead of ending like a burst.
      await tester.pump(MapSeasonalLayer.cycle * 2.5);
      expect(_layer, findsOneWidget, reason: '$season');
      expect(_layer, paints..circle(), reason: '$season');
      expect(tester.binding.transientCallbackCount, greaterThan(0));
    }
  });

  testWidgets('Christmas snowballs are white with a shaded edge', (
    tester,
  ) async {
    await tester.pumpWidget(_onMap(SeasonalTheme.christmas));
    expect(
      _layer,
      paints
        ..circle(color: MapSeasonalLayer.snowShade)
        ..circle(color: MapSeasonalLayer.snow),
    );
  });

  testWidgets('reduce motion hides it and stops the animation', (
    tester,
  ) async {
    await tester.pumpWidget(_onMap(SeasonalTheme.christmas));
    await tester.pumpWidget(_onMap(SeasonalTheme.christmas, reduceMotion: true));
    expect(_layer, findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('switching the season off stops the animation', (tester) async {
    await tester.pumpWidget(_onMap(SeasonalTheme.newYear));
    await tester.pumpWidget(_onMap(SeasonalTheme.none));
    expect(_layer, findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('taps reach the map underneath', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
              ),
            ),
            const MapSeasonalLayer(season: SeasonalTheme.christmas),
          ],
        ),
      ),
    );
    await tester.tapAt(const Offset(400, 300));
    expect(taps, 1);
  });

  testWidgets('screen readers skip it', (tester) async {
    await tester.pumpWidget(_onMap(SeasonalTheme.halloween));
    expect(
      find.ancestor(of: _layer, matching: find.byType(ExcludeSemantics)),
      findsWidgets,
    );
  });
}
