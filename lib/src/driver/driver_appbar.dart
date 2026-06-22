// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

final driverNameScreenAppBar = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderAppColors.white000,
  elevation: 0,
  toolbarHeight: 32,
);

final driverEmailIdScreenAppBar = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderAppColors.white000,
  elevation: 0,
  toolbarHeight: 32,
);

final driverAcceptTermsAndPolicy = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderAppColors.white000,
  elevation: 0,
  toolbarHeight: 32,
);

final uploadTask = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderAppColors.white000,
  elevation: 0,
  toolbarHeight: 80,
);

AppBar buildEarningsAppBar(String title, {VoidCallback? onBackPressed, VoidCallback? onHelpPressed}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton.filled(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(RiderAppColors.grey025),
      ),
      onPressed: onBackPressed,
      color: RiderAppColors.green700,
      icon: const Icon(Icons.arrow_back),
    ),
    actions: [
      IconButton.filled(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(RiderAppColors.grey025),
        ),
        onPressed: onHelpPressed,
        color: RiderAppColors.green700,
        icon: const Icon(Icons.help),
      ),
      const SizedBox(width: 10)
    ],
  );
}

AppBar backbuttonAppBar({VoidCallback? onBackPressed, String title = "", bool centerTitle = false}) {
  return AppBar(
    leading: IconButton(
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(RiderAppColors.bgMuted)),
      onPressed: onBackPressed,
      icon: const Icon(
        Icons.arrow_back_ios,
        size: 20,
        color: RiderAppColors.textPrimary,
      ),
    ),
    centerTitle: centerTitle,
    title: Text(
      title,
      style: const TextStyle(color: RiderAppColors.black900, fontSize: 20),
    ),
  );
}
