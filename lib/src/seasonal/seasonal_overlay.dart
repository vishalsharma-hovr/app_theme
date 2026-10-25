// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// Plays a short burst of [theme]'s decorations above [child] (use it in
/// `MaterialApp.builder` so it covers every screen), then gets out of the way.
/// Change [playCount] to play it again, e.g. when the app returns to the
/// foreground. Never takes taps, hidden from screen readers, and skipped
/// entirely when the OS "reduce motion" setting is on.
class SeasonalOverlay extends StatelessWidget {
  const SeasonalOverlay({
    super.key,
    required this.theme,
    required this.child,
    this.playCount = 0,
  });

  final SeasonalTheme theme;
  final Widget child;
  final int playCount;

  /// How long one burst lasts, including its fade-out.
  static const Duration burst = Duration(seconds: 5);

  /// On the decoration layer; lets tests find it.
  static const Key decorationKey = ValueKey('seasonal-decorations');

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        child,
        if (theme != SeasonalTheme.none && !reduceMotion)
          Positioned.fill(
            // A new key restarts the burst.
            key: ValueKey((theme, playCount)),
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: _FloatingIcons(
                  key: decorationKey,
                  icons: theme.icons,
                  falling: theme == SeasonalTheme.christmas,
                  size: theme.iconSize,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A few [SeasonalIcon]s that fall down the screen ([falling]) or drift across
/// it, spread over its whole height, for one [SeasonalOverlay.burst]. Positions
/// are fixed per slot (no randomness) so frames are stable.
class _FloatingIcons extends StatefulWidget {
  const _FloatingIcons({
    super.key,
    required this.icons,
    required this.falling,
    required this.size,
  });

  final List<SeasonalIconKind> icons;
  final bool falling;
  final double size;

  @override
  State<_FloatingIcons> createState() => _FloatingIconsState();
}

class _FloatingIconsState extends State<_FloatingIcons>
    with SingleTickerProviderStateMixin {
  static const int _count = 8;
  static const double _opacity = 0.85;

  /// The last part of the burst fades out instead of cutting off.
  static const double _fadeFrom = 0.8;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SeasonalOverlay.burst,
  );
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      // Drop the icons (and their Lottie tickers) once the burst ends.
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _position(int slot, double t, Size size) {
    final lane = (slot + 0.5) / _count;
    final speed = 1 + slot % 2; // 1–2 passes per burst
    final progress = (t * speed + slot * 0.37) % 1;
    if (widget.falling) {
      return Offset(
        lane * (size.width - widget.size),
        progress * (size.height - widget.size),
      );
    }
    return Offset(
      progress * (size.width - widget.size),
      lane * (size.height - widget.size),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        // One layer for all icons; isolated so frames don't repaint the app.
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final fade = t < _fadeFrom ? 1.0 : (1 - t) / (1 - _fadeFrom);
              return Opacity(
                opacity: _opacity * fade,
                child: Stack(
                  children: [
                    for (var slot = 0; slot < _count; slot++)
                      Positioned.fromRect(
                        rect: _position(slot, t, size) & Size.square(widget.size),
                        child: SeasonalIcon(
                          kind: widget.icons[slot % widget.icons.length],
                          size: widget.size,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
