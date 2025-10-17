import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';

class BidSuccessScreen extends StatelessWidget {
  const BidSuccessScreen({super.key});

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
              Icon(
                Icons.check_circle,
                color: AppColor.backgroundColor,
                size: size.width * 0.25,
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                "Payment Successful!",
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
                style: Styles.textStyleMediumBold(context),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Order Placed Successfully\nKindly check your order book to view status",
                textScaler: const TextScaler.linear(1.0),
                textAlign: TextAlign.center,
                style: Styles.textStyleMedium(context, color: Colors.black87),
              ),
              SizedBox(height: size.height * 0.05),
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
                  onPressed: () {
                      AppRouteName.appPage.pushAndRemoveUntil(
                        context,
                        (route) => false,
                        args: {"initialTab": 0},
                      );

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        AppRouteName.orderHistoryPage.push(
                          context,
                          args: {"initialTab": 1, "forceRefresh": true},
                        );
                      });
                    },

                  child: Text(
                    "View Order",
                    textScaler: const TextScaler.linear(1.0),
                    style: Styles.textStyleMediumBold(
                      context,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              GestureDetector(
                onTap: () {
                  AppRouteName.appPage.pushAndRemoveUntil(
                    context,
                    (route) => false,
                    args: {"initialTab": 0}, // 👈 home tab
                  );
                },

                child: Text(
                  "Done",
                  textScaler: const TextScaler.linear(1.0),
                  style: Styles.textStyleMediumBold(
                    context,
                    color: AppColor.backgroundColor,
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
