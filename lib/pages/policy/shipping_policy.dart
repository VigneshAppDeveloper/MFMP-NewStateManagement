import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

class ShippingPolicy extends StatefulWidget {
  const ShippingPolicy({super.key});

  @override
  State<ShippingPolicy> createState() => _ShippingPolicyState();
}

class _ShippingPolicyState extends State<ShippingPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: "Shipping & Delivery Policy",
        showBack: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Link: ",
                        style: Styles.textStyleMediumBold(
                          context,
                          color: AppColor.maincolor,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              () =>
                              UrlLauncherHelper.launchInBrowser(
                                context,
                                'https://myfoodmyprice.com/shipping-delivery-policy',
                              ),
                          child: Text(
                            'https://myfoodmyprice.com/shipping-delivery-policy',
                            style: Styles.textStyleMediumBold(
                              context,
                              color: Colors.blueAccent,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Last updated
                  Text(
                    'Last updated: November 13, 2025',
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 24),

                  // Policy Content
                  _policyText(
                    "Orders placed through the MyFoodMyPrice (MFMP) app are generally pickup-only.",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Policy :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                   const SizedBox(height: 5),
                   _policyText(
                    ". Customers can select their preferred pickup point from the options provided in the MFMP app.",
                  ),
                  _policyText(
                    ". Orders will be prepared and kept ready for pickup at the selected pickup location and time.",
                  ),
                     Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Deliver Policy :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                   const SizedBox(height: 5),
                    _policyText(
                    ". Home delivery is not the default option on MFMP.",
                  ),
                  _policyText(
                    ". Delivery can be arranged upon request, subject to availability, at an additional nominal cost.",
                  ),
                  _policyText(
                    ". Delivery availability and charges will be communicated at the time of order or coordination.",
                  ),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Delays & Exceptions :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                   const SizedBox(height: 5),
                   _policyText(
                    ". MyFoodMyPrice shall not be held liable for delays caused due to factors beyond its control, including traffic congestion, road closures, or adverse weather conditions.",
                  ),
                  _policyText(
                    ". While we strive to ensure timely readiness of orders, customers are requested to allow a leeway of up to 30 minutes from the selected pickup or delivery time in case of unforeseen delays.",
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                   const SizedBox(height: 5),
                  _policyText(
                    ". Order status and pickup details can be tracked through the MyFoodMyPrice app.",
                  ),
                 
                  _policyTextWithLink(
                    prefix:
                        "For any issues related to orders or services, customers may contact us at: ",
                    linkText: "Info@myfoodmyprice.com",
                    onTap:
                        () => UrlLauncherHelper.launchInBrowser(
                          context,
                          "Info@myfoodmyprice.com",
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _policyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: Styles.textStyleMedium(context),
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }

  Widget _policyTextWithLink({
    required String prefix,
    required String linkText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        textScaler: const TextScaler.linear(1.0),
        text: TextSpan(
          text: prefix,
          style: Styles.textStyleMedium(context),
          children: [
            TextSpan(
              text: linkText,
              style: Styles.textStyleMediumBold(
                context,
                color: Colors.blueAccent,
              ),

              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
