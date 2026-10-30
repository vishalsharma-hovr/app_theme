// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

/// HOVR's one-colour icons, shared by the rider and driver apps. Each value is
/// a package asset key, so it works anywhere a path does (`Image.asset`,
/// `AssetImage`, `asset:` parameters); draw it with [HovrIcon] to tint it from
/// the theme.
abstract final class HovrIcons {
  static const String _dir = 'packages/app_theme/assets/icons';

  static const String call = '$_dir/call.png';
  static const String chat = '$_dir/chat.png';
  static const String copy = '$_dir/copy.png';
  static const String creditCard = '$_dir/credit_card.png';
  static const String home = '$_dir/home.png';
  static const String leaf = '$_dir/leaf.png';
  static const String message = '$_dir/message.png';
  static const String noReferrals = '$_dir/no_referrals.png';
  static const String share = '$_dir/share.png';
  static const String trips = '$_dir/trips.png';
  static const String wallet = '$_dir/wallet.png';
  static const String work = '$_dir/work.png';

  static const List<String> all = [call, chat, copy, creditCard, home, leaf, message, noReferrals, share, trips, wallet, work];
}

/// Shared illustrations and photos, shown in their own colours (never tinted).
abstract final class HovrImages {
  static const String _dir = 'packages/app_theme/assets/images';

  /// Top-down HOVR car photo, the default driver vehicle picture.
  static const String car = '$_dir/car.png';

  /// The "not available in your region" city illustration.
  static const String toronto = '$_dir/toronto.png';

  /// The welcome screen mark.
  static const String welcome = '$_dir/welcome.png';

  static const List<String> all = [car, toronto, welcome];
}

/// A [HovrIcons] glyph tinted like Flutter's [Icon]: [color], else the
/// surrounding [IconTheme] colour, so it follows light and dark mode.
///
/// HOVR icons keep their colour in festive seasons: pass `context.hovrBrand.*`
/// or `context.colors.*` as [color], never the seasonal `context.brand.*`.
class HovrIcon extends StatelessWidget {
  const HovrIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  /// One of the [HovrIcons] keys.
  final String icon;

  /// Square size; defaults to the [IconTheme] size (24).
  final double? size;

  final Color? color;

  /// Read by screen readers; null hides the icon from them, like [Icon].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(icon.isNotEmpty, 'HovrIcon needs an asset key');
    final iconTheme = IconTheme.of(context);
    final dimension = size ?? iconTheme.size ?? 24;
    return SizedBox.square(
      dimension: dimension,
      child: Image.asset(
        icon,
        width: dimension,
        height: dimension,
        fit: BoxFit.contain,
        color: color ?? iconTheme.color,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
      ),
    );
  }
}
