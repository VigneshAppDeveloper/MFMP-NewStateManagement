import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main heading
              Text(
                "You have requested the deletion of your account",
                style: Styles.textStyleLarge(context, color: Colors.black),
                textScaler: const TextScaler.linear(1.0),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                "Please note that your account will be deleted permanently. "
                "By proceeding, you acknowledge that all your order history, wallet data, and personal information "
                "will be removed and cannot be recovered. For more details, please refer to our privacy policy.",
                style: Styles.textSmall(context, color: Colors.black54),
                textScaler: const TextScaler.linear(1.0),
              ),
              const SizedBox(height: 30),

              // Delete button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onDeletePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.maincolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Delete my account",
                    style: Styles.textStyleMedium(context, color: Colors.white),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Back to settings
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Back to Account",
                    style: Styles.textSmall(context, color: Colors.red),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDeletePressed() {
    // TODO: Add your deletion logic here (API + navigation)
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text(
              "Confirm Deletion",
              textScaler: TextScaler.linear(1.0),
            ),
            content: const Text(
              "Are you sure you want to permanently delete your account?",
              textScaler: TextScaler.linear(1.0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", textScaler: TextScaler.linear(1.0)),
              ),
              TextButton(
                onPressed: () {
                  // Handle confirmed deletion
                  Navigator.pop(context);
                  Navigator.pop(context); // go back to settings
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
