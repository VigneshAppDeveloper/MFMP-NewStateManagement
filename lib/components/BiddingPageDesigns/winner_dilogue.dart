import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/Providers/menu_provider.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../../models/BidderModels/winner_model.dart';
import '../../models/Resturant Model/resturant.dart';

class WinnerLooserDialog {
  /// 🏆 Show Winner Dialog
  static void showWinnerDialog(
    BuildContext context,
    List<WinnerModel> winners,
    Restaurant restaurant,
  ) {
    if (context.mounted == false) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Congratulations!",
                    style: Styles.textStyleLarge(
                      context,
                      color: AppColor.maincolor,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You are the winner of the Flash Offer.",
                    textAlign: TextAlign.center,
                    style: Styles.textStyleMedium(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    "assets/icons/winner-finals.gif",
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  ...winners.map(
                    (w) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              w.menuName,
                              style: Styles.textStyleMedium(context),
                              textScaler: const TextScaler.linear(1.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "₹${w.finalPrice}",
                            style: Styles.textStyleMediumBold(
                              context,
                              color: Colors.green,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(); // Close dialog first
                      }

                      final menuProvider = context.read<MenuProvider>();
                      menuProvider.stopAutoUpdaters();
                      final selectedDate = menuProvider.selectedPickupDate!;
                      final selectedPoint = menuProvider.selectedPickupPoint!;

                      AppRouteName.biddingPaymentPage.pushReplacement(
                        context,
                        args: {
                          "winners": winners,
                          "pickup_date": DateFormat(
                            'yyyy-MM-dd',
                          ).format(selectedDate),
                          "pickup_point": selectedPoint.pickupLocation,
                          "restaurant": restaurant,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// 😔 Show Loser Dialog
  static void showLoserDialog(BuildContext context) {
    if (context.mounted == false) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/icons/looser-2.png",
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Better Luck Next Time!",
                    style: Styles.textStyleLarge(context, color: Colors.red),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You didn’t win this round, but keep trying!",
                    textAlign: TextAlign.center,
                    style: Styles.textStyleMedium(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(); // close dialog
                      }

                      // ✅ Safely go back to the previous screen after dialog
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).maybePop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
