import 'dart:math' as math;

import 'package:app_theme/app_theme.dart';
import 'package:custom_text_view/custom_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  Widget host(Widget child, {ThemeData? theme}) =>
      MaterialApp(theme: theme ?? AppTheme.light(), home: Scaffold(body: Center(child: child)));

  group('FestiveBanner', () {
    testWidgets('is empty out of season', (tester) async {
      await tester.pumpWidget(host(const FestiveBanner(season: SeasonalTheme.none, message: 'Hi')));
      expect(find.text('Hi'), findsNothing);
      expect(find.byType(SeasonalIcon), findsNothing);
    });

    testWidgets('shows the greeting with the season animation', (tester) async {
      await tester.pumpWidget(
        host(const FestiveBanner(season: SeasonalTheme.christmas, message: 'Merry Christmas')),
      );
      expect(find.text('Merry Christmas'), findsOneWidget);
      expect(tester.widget<SeasonalIcon>(find.byType(SeasonalIcon)).kind, SeasonalIconKind.snowflake);
    });

    testWidgets('screen readers hear the greeting, not the animation', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const FestiveBanner(season: SeasonalTheme.newYear, message: 'Happy New Year')),
      );
      expect(find.bySemanticsLabel('Happy New Year'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(ExcludeSemantics), matching: find.byType(SeasonalIcon)),
        findsOneWidget,
      );
      handle.dispose();
    });

    for (final season in [SeasonalTheme.halloween, SeasonalTheme.christmas, SeasonalTheme.newYear]) {
      for (final (mode, theme, brand) in [
        ('light', AppTheme.light(season: season), BrandColors.forSeason(season)),
        ('dark', AppTheme.dark(season: season), BrandColors.forSeason(season, dark: true)),
      ]) {
        testWidgets('${season.name} $mode: festive card, greeting meets WCAG AA', (tester) async {
          await tester.pumpWidget(host(FestiveBanner(season: season, message: 'Hi'), theme: theme));
          final text = tester.widget<TextViewWidget>(find.byType(TextViewWidget)).textColor!;
          final box = tester.widget<Container>(find.byKey(FestiveBanner.surfaceKey));
          final bg = (box.decoration! as BoxDecoration).color!;
          expect(bg, brand.green012);
          expect(text, brand.green700);
          expect(_contrast(text, bg), greaterThanOrEqualTo(4.5));
        });
      }
    }
  });

  group('FestiveBanner close button', () {
    testWidgets('shows only when onClose is given, and calls it', (tester) async {
      var closed = 0;
      await tester.pumpWidget(host(const FestiveBanner(season: SeasonalTheme.halloween, message: 'Hi')));
      expect(find.byType(IconButton), findsNothing);

      await tester.pumpWidget(
        host(FestiveBanner(season: SeasonalTheme.halloween, message: 'Hi', onClose: () => closed++)),
      );
      await tester.tap(find.byTooltip('Close'));
      expect(closed, 1);
    });
  });

  group('FestiveAccent', () {
    testWidgets('is empty out of season', (tester) async {
      await tester.pumpWidget(host(const FestiveAccent(season: SeasonalTheme.none)));
      expect(find.byType(SeasonalIcon), findsNothing);
    });

    testWidgets('shows the season\'s first icon at the given size, hidden from screen readers', (tester) async {
      await tester.pumpWidget(host(const FestiveAccent(season: SeasonalTheme.halloween, size: 40)));
      final icon = tester.widget<SeasonalIcon>(find.byType(SeasonalIcon));
      expect(icon.kind, SeasonalIconKind.pumpkin);
      expect(icon.size, 40);
      expect(find.descendant(of: find.byType(ExcludeSemantics), matching: find.byType(SeasonalIcon)), findsOneWidget);
    });
  });
}
