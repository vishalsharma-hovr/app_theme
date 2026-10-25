// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// A greeting card for the home screen during [season]: the season's animation
/// beside [message] (localised by the app). Empty out of season. Shows a close
/// button when [onClose] is given.
class FestiveBanner extends StatelessWidget {
  const FestiveBanner({super.key, required this.season, required this.message, this.onClose});

  final SeasonalTheme season;
  final String message;
  final VoidCallback? onClose;

  /// On the card surface; lets tests check its colour.
  static const Key surfaceKey = ValueKey('festive-banner-surface');

  @override
  Widget build(BuildContext context) {
    if (season == SeasonalTheme.none) return const SizedBox.shrink();
    final brand = context.brand;
    return Container(
      key: surfaceKey,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brand.green012,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brand.green050),
      ),
      child: Row(
        children: [
          FestiveAccent(season: season, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: TextViewWidget(
              text: message,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textColor: brand.green700,
            ),
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              color: brand.green700,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}

/// A small decorative animation of [season]'s first icon, for inline use
/// (e.g. beside a title). Empty out of season; hidden from screen readers.
class FestiveAccent extends StatelessWidget {
  const FestiveAccent({super.key, required this.season, this.size = 40});

  final SeasonalTheme season;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (season == SeasonalTheme.none) return const SizedBox.shrink();
    return ExcludeSemantics(
      child: SeasonalIcon(kind: season.icons.first, size: size),
    );
  }
}
