import 'package:app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, ThemeData theme, PreferredSizeWidget appBar) =>
      tester.pumpWidget(MaterialApp(theme: theme, home: Scaffold(appBar: appBar)));

  Color appBarColor(WidgetTester tester) => tester
      .widget<Material>(find.descendant(of: find.byType(AppBar), matching: find.byType(Material)).first)
      .color!;

  for (final (name, theme, palette) in [
    ('light', AppTheme.light(), AppPalette.light),
    ('dark', AppTheme.dark(), AppPalette.dark),
  ]) {
    testWidgets('$name: shared app bars take the theme background', (tester) async {
      for (final bar in [loginScreenAppBar, riderNameScreenAppBar, driverNameScreenAppBar, uploadTask]) {
        await pump(tester, theme, bar);
        expect(appBarColor(tester), palette.white000);
      }
    });

    testWidgets('$name: backbuttonAppBar colours follow the palette', (tester) async {
      await pump(tester, theme, backbuttonAppBar(title: 'Back'));
      expect(tester.widget<Text>(find.text('Back')).style!.color, palette.black900);
      expect(tester.widget<Icon>(find.byIcon(Icons.arrow_back_ios)).color, palette.textPrimary);
    });

    testWidgets('$name: buildEarningsAppBar colours follow the palette', (tester) async {
      await pump(tester, theme, buildEarningsAppBar('Earnings'));
      expect(tester.widget<Text>(find.text('Earnings')).style!.color, palette.black);
      expect(appBarColor(tester), palette.white000);
    });
  }

  for (final season in SeasonalTheme.values) {
    testWidgets('${season.name}: brand accents follow the season', (tester) async {
      await pump(tester, AppTheme.light(season: season), buildEarningsAppBar('E'));
      final back = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.arrow_back));
      expect(back.color, BrandColors.forSeason(season).green700);
    });
  }
}
