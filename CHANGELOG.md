## 0.1.1

* Brand colours follow the festive season (unchanged from 0.1.0): pass
  `season` to `AppTheme.light` / `AppTheme.dark`. Every colour code per season,
  light and dark, is in `doc/festive_colors.md` (a test keeps it in sync).
* The HOVR primary `#39851C` is now the exact Material `primary` out of season,
  the same in light and dark, with white on it. Before, light used a generated
  muted shade (`#436833`) and dark a lighter green (`#62C73A`). Festive seasons
  use their own primary in light and its lighter tone in dark (New Year's
  indigo is under 3:1 on dark). The light Material surface is now the palette
  white (was tinted `#F8FAF0`). Buttons, switches and focus colours change shade
  in both apps.
* `BrandColors.forSeason(season, dark: true)` returns the dark palette for a
  season.
* Add `context.hovrBrand`: the year-round HOVR palette that never follows the
  season. **Action for apps:** pass `context.hovrBrand.*` (or `context.colors.*`)
  to `HovrIcon(color: ...)` instead of `context.brand.*`, so HOVR icons keep
  their colour in festive seasons. Find call sites with
  `grep -rn "HovrIcon(" lib | grep "context.brand"`.
* Festive maps each have their own look (colour codes in
  `doc/festive_colors.md`): Halloween "haunted night" (candle-glow highways,
  slime-green parks), Christmas "snowy village" (gingerbread buildings, icy
  main-road edges) plus a new dark-mode "snowy night" map
  (`christmas_dark.json`, picked by `mapStyleAsset` in dark mode), and New Year
  "city of lights" (champagne highways, gold transit lines). Roads are very
  dark or very light so the HOVR green route stands out (at least 3:1).
* `MapSeasonalLayer` at Halloween adds visiting characters (bats, pumpkins, a
  ghost and a spider; `MapCharacterKind`) on a one-minute timeline
  (`MapSeasonalLayer.castCycle`): at most three at once, only in the top
  quarter and bottom corners, with quiet gaps. Drawn in code (no new assets).
  **Action for apps:** size the layer to the visible map and hide it during a
  trip.
* `MapSeasonalLayer(calm: true)` keeps decorations in the top quarter
  (`MapSeasonalLayer.calmBand`), fading in and out, with no Halloween
  characters: use it on screens where the map is busy.
* Add `HovrIcons` (package asset keys for HOVR's one-colour icons: call, chat,
  copy, credit card, home, leaf, message, ...) and `AppPalette.successColor` /
  `warningColor`. **Action for apps:** replace copies of these icons in the
  app's own `assets/` with `HovrIcons.*`, drawn with `HovrIcon` to tint them.
* Requires `custom_text_view` v1.1.0 (pinned with `ref: v1.1.0`), the same ref
  as the apps, so `pub get` resolves. In v1.1.0 `TextViewWidget` text without a
  `textColor` follows the theme, so it is readable in dark mode.
* Tests: every season, light and dark: text and icon tokens and brand text on
  brand tints meet WCAG AA, white/dark text on the primary meets AA, HOVR icons
  keep their colour.

## 0.1.0

* Seasonal themes (Halloween, Christmas, New Year): overlay, banner, loader,
  map layer, festive map styles, car markers and design tokens.
