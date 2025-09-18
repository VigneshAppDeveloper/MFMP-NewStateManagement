import 'package:flutter/material.dart';
import 'package:my_food_my_price/pages/Profile%20Settings/profile_edit.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isAccountSettings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: isAccountSettings ? "Account settings" : "Settings",
        onBack: () {
          if (isAccountSettings) {
            setState(() => isAccountSettings = false);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAccountSettings) accountSettings()
              else settingsTitles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingsTitles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        settingsTitle(
          title: "Edit profile",
          subtitle: "Change your name, description and profile photo",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileEdit()),
          ),
        ),
        divider(),
        settingsTitle(
          title: "Account settings",
          subtitle: "Delete your account.",
          onTap: () => setState(() => isAccountSettings = true),
        ),
        divider(),
      ],
    );
  }

  Widget accountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        accountSettingsTitles(
          "Delete account",
            () => AppRouteName.deleteAccount.push(context), 
        ),
        divider(),
      ],
    );
  }

  Widget settingsTitle({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Styles.textStyleMedium(context, color: Colors.black),
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Styles.textSmall(context, color: Colors.black),
              textScaler: const TextScaler.linear(1.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget accountSettingsTitles(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: Styles.textStyleMedium(context, color: Colors.black),
          textScaler: const TextScaler.linear(1.0),
        ),
      ),
    );
  }

  Widget divider() {
    return const Divider(
      color: Colors.black26,
      thickness: 0.3,
      height: 0,
    );
  }
}