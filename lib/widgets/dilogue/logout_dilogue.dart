import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';


class LogoutDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  "Logout Confirmation",
                  style: Styles.textStyleLarge(context, color: AppColor.maincolor),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to logout?",
                  style: Styles.textStyleMedium(context, color: AppColor.blackColor),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "Cancel",
                        style: Styles.textStyleMedium(context, color: Colors.black),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),

                    // Logout
                    ElevatedButton(
                      onPressed: () async {
                        await SecureStorageService.clearAllAppData();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
                        // ignore: use_build_context_synchronously
                        AppRouteName.login.pushAndRemoveUntil(context, (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.maincolor,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "Logout",
                        style: Styles.textStyleMedium(context, color: Colors.white),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
