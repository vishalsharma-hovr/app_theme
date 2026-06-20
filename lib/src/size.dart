// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

Size displaySize({required BuildContext context}) {
  return MediaQuery.sizeOf(context);
}

double displayHeight({required BuildContext context}) {
  return displaySize(context: context).height;
}

double displayWidth({required BuildContext context}) {
  return displaySize(context: context).width;
}

EdgeInsets displayViewInsetOf({required BuildContext context}) {
  return MediaQuery.viewInsetsOf(context);
}
