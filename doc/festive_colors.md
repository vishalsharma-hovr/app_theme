# Festive colour codes

Reference for the brand colours in each season, light and dark. Source of truth:
`lib/src/brand_colors.dart` (`BrandColors.forSeason`). A test
(`test/brand_colors_test.dart`) fails if a colour in the code is missing here.

Use:

```dart
final season = seasonalThemeFor(DateTime.now());
MaterialApp(
  theme: AppTheme.light(season: season),
  darkTheme: AppTheme.dark(season: season),
);
// Screens: context.brand.* (follows the season), context.colors.* (neutrals).
// HOVR icons: context.hovrBrand.* (never follows the season).
```

## Rules

- **Brand colours follow the season.** Buttons, primary, accents, chips and the
  festive banner card take the season's palette.
- **HOVR icons never do.** `HovrIcons` / `HovrImages` keep their shape, and
  their colour when drawn with `context.hovrBrand.*` or `context.colors.*`.
- **Status colours never change:** error `#E80101`, success `#2E7D32`, warning
  `#B45309` (light; dark versions in `AppPalette.dark`). Christmas has no red so
  red always means "error".
- **Out of season, the HOVR fills are the same in light and dark:** primary
  `#39851C`, `brandPrimary` `#148023` (button fill) and `greenButton` `#308011`,
  with white labels (at least 4.5:1). On the dark page they are 3.5–3.9:1, fine
  for buttons and icons; as small text (e.g. the rating chip) about 3:1, accepted.
  Festive primaries use a lighter tone in dark mode: New Year's indigo is only
  2.29:1 on the dark page, below the 3:1 minimum for buttons.
- **Readable in every season:** text and icon tokens are at least 4.5:1 (WCAG AA)
  on the page, light and dark, with the exception below. Tests enforce this.

## Page backgrounds

`AppPalette.forSeason(season, dark:)` (used by `AppTheme.light/dark(season:)`)
tints only the page colours; text, greys, `white` and status colours stay.

| Season | Light page `white000` | Light alt `bgColor` | Dark page `white000` | Dark alt `bgColor` |
|---|---|---|---|---|
| None | `#FDFFFC` | `#F7F7FA` | `#161615` | `#0D0D0C` |
| Halloween | `#FFF9F2` | `#FFF1E0` | `#1F140F` | `#150D09` |
| Christmas | `#F0FDF4` | `#DCFCE7` | `#0F1A14` | `#09110D` |
| New Year | `#FFFBEB` | `#FEF3C7` | `#12111F` | `#0B0A15` |

Halloween's light tints are a touch paler than its brand tints so the error red
`#E80101` and success green `#2E7D32` stay at least 4.5:1.

## Primary colour

| Season | Light primary | Text on it | Primary on page | Dark primary | Text on it | Primary on page |
|---|---|---|---|---|---|---|
| None (HOVR) | `#39851C` | `#FFFFFF` 4.62 | 4.59 | `#39851C` | `#FFFFFF` 4.62 | 3.92 * |
| Halloween | `#C2410C` | `#FFFFFF` 5.18 | 5.15 | `#FB923C` | `#161615` 8.00 | 8.00 |
| Christmas | `#15803D` | `#FFFFFF` 5.02 | 4.99 | `#4ADE80` | `#161615` 10.39 | 10.39 |
| New Year | `#4338CA` | `#FFFFFF` 7.90 | 7.86 | `#EAB308` | `#161615` 9.44 | 9.44 |

Seasons (phone's local date, every year): Halloween Oct 24–31, Christmas
Dec 20–26, New Year Dec 31–Jan 2 (`seasonalThemeFor`).

\* Known exception, accepted: the HOVR primary on the dark page is 3.92:1 (AA
for buttons and icons, not small text). "Page" is white `#FDFFFC` in light and
`#161615` / `#0D0D0C` in dark. On the light grey page `#F7F7FA` some HOVR greens
are just under 4.5:1 (open item).

## All brand tokens (light / dark)

Tints (`green012`–`green300`) are for backgrounds, chips and decoration; strong
tokens (`green400`+, `green056`, `greenButton`, `primaryColor`, `brandPrimary`)
are for text, icons and buttons. Dark mode mirrors the scale.

| Token | None (HOVR) | Halloween | Christmas | New Year |
|---|---|---|---|---|
| `green012` | `#EDF4EA` / `#122A09` | `#FFF7ED` / `#431407` | `#F0FDF4` / `#052E16` | `#FFFBEB` / `#13112F` |
| `green025` | `#E4F4DE` / `#1D420E` | `#FFEDD5` / `#7C2D12` | `#DCFCE7` / `#0F3D22` | `#FEF3C7` / `#1E1B4B` |
| `green050` | `#D0EEC4` / `#275A13` | `#FED7AA` / `#9A3412` | `#BBF7D0` / `#14532D` | `#FDE68A` / `#312E81` |
| `green056` | `#38821B` / `#62C73A` | `#C2410C` / `#FB923C` | `#15803D` / `#4ADE80` | `#4338CA` / `#EAB308` |
| `green100` | `#9BDB82` / `#327519` | `#FDBA74` / `#9A3412` | `#86EFAC` / `#166534` | `#FCD34D` / `#3730A3` |
| `green200` | `#62C73A` / `#39851C` | `#FB923C` / `#C2410C` | `#4ADE80` / `#15803D` | `#EAB308` / `#4338CA` |
| `green300` | `#4AAB24` / `#4AAB24` | `#F97316` / `#F97316` | `#22C55E` / `#22C55E` | `#CA8A04` / `#CA8A04` |
| `green400` | `#39851C` / `#62C73A` | `#C2410C` / `#FB923C` | `#15803D` / `#4ADE80` | `#4338CA` / `#EAB308` |
| `green500` | `#327519` / `#9BDB82` | `#9A3412` / `#FDBA74` | `#166534` / `#86EFAC` | `#3730A3` / `#FCD34D` |
| `green600` | `#275A13` / `#D0EEC4` | `#9A3412` / `#FED7AA` | `#14532D` / `#BBF7D0` | `#312E81` / `#FDE68A` |
| `green700` | `#1D420E` / `#E4F4DE` | `#7C2D12` / `#FFEDD5` | `#0F3D22` / `#DCFCE7` | `#1E1B4B` / `#FEF3C7` |
| `green800` | `#122A09` / `#EDF4EA` | `#431407` / `#FFF7ED` | `#052E16` / `#F0FDF4` | `#13112F` / `#FFFBEB` |
| `green900` | `#081404` / `#EDF4EA` | `#2A0C03` / `#FFF7ED` | `#021A0C` / `#F0FDF4` | `#0A091A` / `#FFFBEB` |
| `greenButton` | `#308011` / `#308011` | `#C2410C` / `#FB923C` | `#166534` / `#4ADE80` | `#3730A3` / `#EAB308` |
| `primaryColor` | `#39851C` / `#39851C` | `#C2410C` / `#FB923C` | `#15803D` / `#4ADE80` | `#4338CA` / `#EAB308` |
| `brandPrimary` | `#148023` / `#148023` | `#C2410C` / `#FB923C` | `#166534` / `#4ADE80` | `#3730A3` / `#EAB308` |

## Decoration colours

Festive decorations keep their own colours in light and dark; they never read
the brand palette.

| Where | Colours |
|---|---|
| Halloween icons (`seasonal_icons.dart`) | pumpkin `#F97316`, rib `#C2410C`, stem `#3F6212`, bat `#2E1065` (on dark `#A78BFA`) |
| Christmas icons | ice `#7DD3FC`, pine `#15803D`, trunk `#78350F`, star `#FACC15` |
| New Year icons | star/gold `#FACC15`, spark `#14B8A6` |
| Map layer (`map_seasonal_layer.dart`) | snow `#FFFFFF` with shade `#CBD5E1`, ember core `#FDBA74` |
| Halloween map characters (`map_halloween_cast.dart`) | bat (dark-map violet `#A78BFA`), pumpkin (icon colours) with candle glow `#FDBA74`, ghost `#F8FAFC` with eyes `#1E1B2E`, spider `#0A0610` on thread `#E5E7EB` |

## Map styles

`mapStyleAsset(...)` picks the file: a festive season wins over dark mode.
Halloween and New Year are night maps in both modes; Christmas has a light and
a dark map. Out of season: Google's default map in light, `dark.json` in dark.

| Map (`assets/map_styles/`) | Land | Highway | Main road | Side street | Park | Water | Labels |
|---|---|---|---|---|---|---|---|
| Halloween — "Haunted night" (`halloween.json`) | `#140d1c` | `#ffd8a8` | `#30223f` | `#2a1f38` | `#2b4d12` | `#0b0f1f` | `#f2a65a` |
| Christmas — "Snowy village" (`christmas.json`, light) | `#f7fafc` | `#ffffff` | `#ffffff` | `#ffffff` | `#dcebe2` | `#d4ebf7` | `#1f4d2e` |
| Christmas — "Snowy night" (`christmas_dark.json`, dark) | `#1a2433` | `#f7fafc` | `#e3ebf2` | `#cdd8e2` | `#1e3a2c` | `#0f1c2e` | `#e6eef5` |
| New Year — "City of lights" (`new_year.json`) | `#0d1b2a` | `#fff4d6` | `#f9dc8c` | `#2b2610` | `#0f3a3d` | `#06111d` | `#e8c66a` |

What makes each one its own:

- **Halloween:** near-black violet town, candle-glow highways, slime-green
  parks (park labels `#a3e635`), violet borders `#5b3a80`, dimmed transit.
- **Christmas (light):** snow-white streets with pine highway edges `#15803d`,
  icy-blue main-road edges `#cfe3f0`, frosted parks, gingerbread-cream buildings
  `#f3e6d3`. No red.
- **Christmas (dark):** midnight blue-grey with snow-dusted roads, bright pine
  highway edges `#4ade80`, dark pine parks. No red.
- **New Year:** midnight navy, champagne highways, pale-gold main roads, dark
  bronze side streets, dark teal parks (labels `#5eead4`), gold transit lines
  `#e0b84a` for the busy night.

Rules (enforced by `test/map_style_test.dart`):

- **Route stays HOVR green** `#39851C` (drawn natively, no outline). Every road
  colour on a festive map is very dark or very light so the route is at least
  3:1 against it.
- **Labels read:** every label colour is at least 4.5:1 against its outline.
- **Unique:** no two festive maps share a highway, park or water colour, and
  Halloween and New Year use different rule sets.
- **Less clutter:** business pins are hidden on every festive map; stations,
  airports and main roads stay distinct.
