// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

final driverNameScreenAppBar = AppBar(
  automaticallyImplyLeading: false,
  elevation: 0,
  toolbarHeight: 32,
);

final driverEmailIdScreenAppBar = AppBar(
  automaticallyImplyLeading: false,
  elevation: 0,
  toolbarHeight: 32,
);

final driverAcceptTermsAndPolicy = AppBar(
  automaticallyImplyLeading: false,
  elevation: 0,
  toolbarHeight: 32,
);

final uploadTask = AppBar(
  automaticallyImplyLeading: false,
  elevation: 0,
  toolbarHeight: 80,
);

// Top-level builders have no BuildContext, so coloured parts use a Builder.
AppBar buildEarningsAppBar(String title, {VoidCallback? onBackPressed, VoidCallback? onHelpPressed}) {
  return AppBar(
    title: Builder(
      builder: (context) => Text(
        title,
        style: TextStyle(
          color: context.colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    ),
    centerTitle: true,
    elevation: 0,
    leading: Builder(
      builder: (context) => IconButton.filled(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(context.colors.grey025),
        ),
        onPressed: onBackPressed,
        color: context.brand.green700,
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    actions: [
      Builder(
        builder: (context) => IconButton.filled(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(context.colors.grey025),
          ),
          onPressed: onHelpPressed,
          color: context.brand.green700,
          icon: const Icon(Icons.help),
        ),
      ),
      const SizedBox(width: 10)
    ],
  );
}

AppBar backbuttonAppBar({VoidCallback? onBackPressed, String title = "", bool centerTitle = false}) {
  return AppBar(
    leading: Builder(
      builder: (context) => IconButton(
        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(context.colors.bgMuted)),
        onPressed: onBackPressed,
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: context.colors.textPrimary,
        ),
      ),
    ),
    centerTitle: centerTitle,
    title: Builder(
      builder: (context) => Text(
        title,
        style: TextStyle(color: context.colors.black900, fontSize: 20),
      ),
    ),
  );
}
