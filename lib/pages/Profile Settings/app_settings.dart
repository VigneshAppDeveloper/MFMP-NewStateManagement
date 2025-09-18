import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/LoginModels/profile_mode.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/name_formatter.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';
import 'package:my_food_my_price/widgets/dilogue/logout_dilogue.dart';
import 'package:my_food_my_price/widgets/drawer_list_tile.dart';
import 'package:my_food_my_price/widgets/heading_section.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  late Future<ProfileModel?> profileFuture;
  @override
  void initState() {
    super.initState();
    debugPrint("📦 Loaded from storage: vikiiii");
    profileFuture = loadProfile();
  }

  Future<ProfileModel?> loadProfile() async {
    debugPrint("🔄 AppConstants.profile: ${AppConstants.profile}");

    if (AppConstants.profile != null) {
      debugPrint("✅ Using cached profile: ${AppConstants.profile!.name}");
      return AppConstants.profile;
    }

    final stored = await SecureStorageService.readProfile();
    debugPrint("📦 Loaded from storage: $stored");

    if (stored != null) {
      AppConstants.profile = stored;
      debugPrint("✅ AppConstants.profile updated from storage: ${stored.name}");
    } else {
      debugPrint("❌ No profile found in secure storage.");
    }

    return AppConstants.profile;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileModel?>(
      future: profileFuture,
      builder: (context, snapshot) {
        debugPrint("📡 FutureBuilder snapshot: ${snapshot.connectionState}");
        debugPrint("📡 Profile from snapshot: ${snapshot.data}");
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: FullScreenLoader()));
        }
        final profile = snapshot.data;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const CommonAppBar(title: "Menu", showBack: true),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  profileCard(profile),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      AppRouteName.rewards.push(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 18,
                            offset: const Offset(10, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon inside circular background
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColor.maincolor.withAlpha(20),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColor.maincolor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Text column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Wallet & Rewards",
                                style: Styles.textStyleMedium(context),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${profile?.wallet ?? '0'}",
                                style: Styles.textStyleMedium(
                                  context,
                                  color: Colors.green,
                                ),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  HeadingSection(
                    title: "My Orders",
                    children: [
                      DrawerListTile(
                        icon: Icons.list_alt,
                        title: "Fixed Orders",
                        onTap: () {
                          // AppRouteName.myOrdersPage.push(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.receipt,
                        title: "Bidding Orders",
                        onTap: () {
                          // AppRouteName.myOrdersPage.push(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  HeadingSection(
                    title: "Enquirys & Supports",
                    children: [
                      DrawerListTile(
                        icon: Icons.support_agent,
                        title: "Customer Supports ",
                        onTap: () {
                          // AppRouteName.myOrdersPage.push(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.store_mall_directory,
                        title: "Franchise Enquiry",
                        onTap: () {
                          // AppRouteName.myOrdersPage.push(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.menu_book,
                        title: "App Guide",
                        onTap: () {
                          AppRouteName.appGuide.push(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  HeadingSection(
                    title: "More",
                    children: [
                      DrawerListTile(
                        icon: Icons.info_outline,
                        title: "About",
                        onTap: () {
                          AppRouteName.aboutPage.push(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.settings,
                        title: "Settings",
                        onTap: () {
                          AppRouteName.settingsPage.push(context);
                        },
                      ),
                      DrawerListTile(
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () {
                          LogoutDialog.show(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget profileCard(ProfileModel? profile) {
    debugPrint("👤 Profile received in UI: ${profile?.toJson()}");
    String userName = profile?.name ?? "Guest User";
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : "U";

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 10), // slight spacing if needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // more visible than withAlpha(10)
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColor.blackColor,
            backgroundImage:
                (profile?.imageUrl ?? "").isNotEmpty
                    ? NetworkImage(AppConstants.profile!.imageUrl)
                    : null,
            child:
                (profile?.imageUrl ?? "").isEmpty
                    ? Text(
                      firstLetter,
                      style: Styles.textStyleLarge(
                        context,
                        color: AppColor.whiteColor,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    )
                    : null,
          ),
          const SizedBox(width: 15),

          // Name and mobile
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.titleCase,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textStyleMedium(
                    context,
                    color: AppColor.blackColor,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 5),
                Text(
                  profile?.mobile ?? "No Mobile Number",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Styles.textSmall(context, color: AppColor.maincolor),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ],
            ),
          ),

          // Edit Button
          GestureDetector(
            onTap: () {
              AppRouteName.editProfilePage.push(context);
            },
            child: Row(
              children: [
                Text(
                  "Edit",
                  style: Styles.textStyleMedium(
                    context,
                    color: Colors.red,
                  ).copyWith(decoration: TextDecoration.underline),
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.edit, color: Colors.red, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
