import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _fallback = Text('spinner');

Widget _app(SeasonalTheme season, {bool disableAnimations = false}) {
  return MaterialApp(
    builder: (context, child) => MediaQuery(
      data:
          MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
      child: child!,
    ),
    home: Scaffold(
      body: Center(child: FestiveLoader(season: season, fallback: _fallback)),
    ),
  );
}

SeasonalIcon _shownIcon(WidgetTester tester) =>
    tester.widget<SeasonalIcon>(find.byType(SeasonalIcon));

double _itemTop(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(FestiveLoader.itemKey)).dy;

void main() {
  testWidgets('outside a season it shows the app spinner', (tester) async {
    await tester.pumpWidget(_app(SeasonalTheme.none));

    expect(find.text('spinner'), findsOneWidget);
    expect(find.byType(SeasonalIcon), findsNothing);
  });

  for (final season in [
    SeasonalTheme.halloween,
    SeasonalTheme.christmas,
    SeasonalTheme.newYear,
  ]) {
    testWidgets('$season shows only its own festive items', (tester) async {
      await tester.pumpWidget(_app(season));

      expect(find.text('spinner'), findsNothing);
      expect(_shownIcon(tester).kind, season.icons.first);

      // Half a cycle later the next item of the same season hops.
      await tester.pump(FestiveLoader.hop);
      expect(_shownIcon(tester).kind, season.icons[1 % season.icons.length]);
      expect(season.icons, contains(_shownIcon(tester).kind));
    });
  }

  testWidgets('the item bounces: it leaves the ground and lands again', (
    tester,
  ) async {
    await tester.pumpWidget(_app(SeasonalTheme.halloween));
    final ground = _itemTop(tester);

    await tester.pump(FestiveLoader.hop * 0.4); // near the top of the hop
    expect(_itemTop(tester), lessThan(ground - 4));

    await tester.pump(FestiveLoader.hop * 0.6); // landed for the next hop
    expect(_itemTop(tester), closeTo(ground, 1));
  });

  testWidgets('with reduce motion on, the item stays still', (tester) async {
    await tester.pumpWidget(
      _app(SeasonalTheme.christmas, disableAnimations: true),
    );
    final ground = _itemTop(tester);

    await tester.pump(FestiveLoader.hop * 0.4);

    expect(_itemTop(tester), ground);
  });

  testWidgets('screen readers hear the loading label', (tester) async {
    await tester.pumpWidget(_app(SeasonalTheme.newYear));

    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
  });
}
