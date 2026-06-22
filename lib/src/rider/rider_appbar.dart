// ignore_for_file: use_string_in_part_of_directives

part of app_theme;

final riderNameScreenAppBar = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderDriverAppColor.white000,
  elevation: 0,
  toolbarHeight: 32,
);

final riderEmailIdScreenAppBar = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderDriverAppColor.white000,
  elevation: 0,
  toolbarHeight: 32,
);

final riderAcceptTermsAndPolicy = AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: RiderDriverAppColor.white000,
  elevation: 0,
  toolbarHeight: 32,
);

PreferredSize accountViewAppBar({
  required BuildContext context,
  required String firstName,
  required String lastName,
  required String rating,
  required Widget profilePic,
  required VoidCallback onTap,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            color: RiderDriverAppColor.white000,
            margin: const EdgeInsets.only(top: 60, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextViewWidget(
                      text: "$firstName $lastName",
                      fontSize: 24,
                      sizedBoxWidth: displayWidth(context: context) * .7,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: rating.contains("No") ? RiderDriverAppColor.bgMuted : RiderDriverAppColor.green012,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        spacing: 2,
                        children: [
                          Icon(
                            Icons.star_rate_rounded,
                            color: rating.contains("No") ? RiderDriverAppColor.textSecondary : RiderDriverAppColor.brandPrimary,
                            size: 13,
                          ),
                          TextViewWidget(
                            text: rating,
                            fontSize: 12,
                            textColor: rating.contains("No") ? RiderDriverAppColor.textSecondary : RiderDriverAppColor.brandPrimary,
                          ),
                          const SizedBox(width: 10)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                profilePic,
              ],
            ),
          ),
          // const Divider(),
        ],
      ),
    ),
  );
}

PreferredSize backButtonAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: AppBar(
      elevation: 0,
      backgroundColor: RiderDriverAppColor.white000,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
    ),
  );
}

AppBar settingAppBar(BuildContext context, VoidCallback onTap) => AppBar(
      leading: IconButton(
        onPressed: onTap,
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
      title: const TextViewWidget(
        text: "Settings",
        fontSize: 16,
      ),
      centerTitle: true,
    );
//MARK: PROFILE SECTION
AppBar profileAppBar(BuildContext context, VoidCallback editCallback) => AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
      title: const TextViewWidget(
        text: "Profile",
        fontSize: 16,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: editCallback,
          icon: const Icon(Icons.edit),
        ),
      ],
    );

AppBar editProfileAppBar(BuildContext context) => AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
      title: const TextViewWidget(
        text: "Edit profile",
        fontSize: 16,
      ),
      centerTitle: true,
    );

//MARK: NOTIFICATION
AppBar notificationAppBar(BuildContext context) => AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
      title: const TextViewWidget(
        text: "",
        fontSize: 16,
      ),
      centerTitle: true,
    );

PreferredSize savedPlacesAppBar(BuildContext context, {required Function()? onClickAddPlace}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(80),
    child: AppBar(
      backgroundColor: RiderDriverAppColor.white000,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: onClickAddPlace,
          icon: const CircleAvatar(
            backgroundColor: RiderDriverAppColor.grey025,
            child: Icon(
              Icons.add,
              color: RiderDriverAppColor.green700,
            ),
          ),
        ),
      ],
    ),
  );
}

//MARK: PAYMENT SECTION
AppBar paymentMethodAppBar(BuildContext context) => AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const CircleAvatar(
          backgroundColor: RiderDriverAppColor.grey025,
          child: Icon(
            Icons.arrow_back,
            color: RiderDriverAppColor.green700,
          ),
        ),
      ),
    );
