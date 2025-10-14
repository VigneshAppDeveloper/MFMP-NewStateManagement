import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';

import '../../../models/BidderModels/winner_model.dart';
import '../../../util/styles.dart';
import '../helper/payment_helper.dart';


class BidFailureScreen extends StatelessWidget {
  final List<WinnerModel> winners;
  final String franchiseId;
  final String timerId;

  const BidFailureScreen({
    super.key,
    required this.winners,
    required this.franchiseId,
    required this.timerId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg/bp_profile-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade600,
                radius: size.width * 0.12,
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 60),
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                "Payment Failed!",
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
                style: Styles.textStyleMediumBold(context, ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Order not confirmed.\nPlease try again.",
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
                style: Styles.textStyleMedium(context, color: Colors.black87),
              ),
              SizedBox(height: size.height * 0.06),
              SizedBox(
                height: 55,
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.backgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Retry Payment",
                    textScaler: const TextScaler.linear(1.0),
                    style: Styles.textStyleMediumBold(
                      context,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                height: 55,
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    await PaymentHelpers.saveFailedPaymentDetails(
                      winners: winners,
                      franchiseId: franchiseId,
                      timerId: timerId,
                    );
                    //AppRouteName.homePage.pushAndRemoveUntil(context);
                  },
                  child: Text(
                    "Cancel",
                    textScaler: const TextScaler.linear(1.0),
                    style: Styles.textStyleMediumBold(
                      context,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}