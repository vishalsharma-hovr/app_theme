import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _onTripMap(SeasonalTheme season) => MediaQuery(
      data: const MediaQueryData(size: Size(400, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(children: [MapSeasonalLayer(season: season, calm: true)]),
      ),
    );

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

  group('Halloween characters', () {
    const size = Size(400, 800);
    // One sample per 100 ms across the whole timeline.
    const samples = 600;
    Iterable<double> times() sync* {
      for (var i = 0; i < samples; i++) {
        yield i / samples;
      }
    }

    test('at most ${MapSeasonalLayer.maxCharactersOnScreen} on screen at once', () {
      for (final t in times()) {
        expect(
          MapSeasonalLayer.halloweenCastAt(t, size).length,
          lessThanOrEqualTo(MapSeasonalLayer.maxCharactersOnScreen),
          reason: 't=$t',
        );
      }
    });

    test('stay in the top band or the bottom corners, never over the route and car', () {
      final topBand = Rect.fromLTRB(-size.width, -size.height, size.width * 2, size.height * 0.25);
      final bottomLeft = Rect.fromLTRB(-size.width, size.height * 0.8, size.width * 0.2, size.height * 2);
      final bottomRight = Rect.fromLTRB(size.width * 0.8, size.height * 0.8, size.width * 2, size.height * 2);
      for (final t in times()) {
        for (final (kind, bounds) in MapSeasonalLayer.halloweenCastAt(t, size)) {
          final safe = [topBand, bottomLeft, bottomRight].any(
            (zone) => zone.intersect(bounds) == bounds,
          );
          expect(safe, isTrue, reason: '$kind at $bounds, t=$t');
        }
      }
    });

    test('bats, pumpkins, a ghost and a spider all appear every cycle', () {
      final seen = <MapCharacterKind>{
        for (final t in times())
          for (final (kind, _) in MapSeasonalLayer.halloweenCastAt(t, size)) kind,
      };
      expect(seen, MapCharacterKind.values.toSet());
    });

    test('they come and go: the map is sometimes clear of characters', () {
      final clear = times().where((t) => MapSeasonalLayer.halloweenCastAt(t, size).isEmpty);
      expect(clear, isNotEmpty);
    });

    testWidgets('only Halloween runs the characters layer', (tester) async {
      final cast = find.byKey(MapSeasonalLayer.castKey);
      await tester.pumpWidget(_onMap(SeasonalTheme.halloween));
      expect(cast, findsOneWidget);
      await tester.pumpWidget(_onMap(SeasonalTheme.christmas));
      expect(cast, findsNothing);
    });

    testWidgets('reduce motion hides the characters and stops their timeline', (tester) async {
      await tester.pumpWidget(_onMap(SeasonalTheme.halloween));
      await tester.pumpWidget(_onMap(SeasonalTheme.halloween, reduceMotion: true));
      expect(find.byKey(MapSeasonalLayer.castKey), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('a ghost drawn mid-cycle paints over the map', (tester) async {
      await tester.pumpWidget(_onMap(SeasonalTheme.halloween));
      await tester.pump(MapSeasonalLayer.castCycle * 0.37);
      expect(find.byKey(MapSeasonalLayer.castKey), paints..path());
    });
  });

  group('calm (in-trip) mode', () {
    const size = Size(400, 800);
    const festive = [SeasonalTheme.halloween, SeasonalTheme.christmas, SeasonalTheme.newYear];

    test('ambient decorations stay in the top quarter, at half the density', () {
      for (final season in festive) {
        for (var i = 0; i < 120; i++) {
          final t = i / 120;
          final calm = MapSeasonalLayer.decorationsAt(season, t, size, calm: true);
          expect(calm.length, MapSeasonalLayer.decorationsAt(season, t, size).length ~/ 2);
          for (final centre in calm) {
            expect(centre.dy, lessThanOrEqualTo(size.height * 0.25), reason: '$season t=$t $centre');
          }
        }
      }
    });

    test('outside calm mode decorations still use the whole map', () {
      final ys = [
        for (var i = 0; i < 120; i++)
          for (final c in MapSeasonalLayer.decorationsAt(SeasonalTheme.christmas, i / 120, size)) c.dy,
      ];
      expect(ys.any((y) => y > size.height * 0.5), isTrue);
    });

    testWidgets('no Halloween characters on the trip map, only the ambient layer', (tester) async {
      await tester.pumpWidget(_onTripMap(SeasonalTheme.halloween));
      expect(find.byKey(MapSeasonalLayer.castKey), findsNothing);
      expect(_layer, findsOneWidget);
    });
  });
}
