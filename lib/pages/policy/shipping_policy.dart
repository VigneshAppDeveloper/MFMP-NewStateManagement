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
      appBar:const CommonAppBar(title: "Shipping & Delivery Policy", showBack: true),

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
                                'https://www.biryanipalayam.com/copy-of-cancellation-refund-policy-1',
                              ),
                          child: Text(
                            'www.biryanipalayam.com',
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
                    'Last updated: May 17, 2024',
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 24),

                  // Policy Content
                  _policyText(
                    "Orders done through the MyFoodMyPrice app are for Pickup only. Customers will choose their desired pickup point from the options provided. Biryanipalayam will bring your orders to your desired pickup point and keep it ready for pickup at your selected pickup time.",
                  ),
                  _policyText(
                    "No home deliveries will be done for orders through the MyFoodMyPrice app.",
                  ),
                  _policyText(
                    "Biryanipalayam is not to be held liable for delays due to reasons beyond its control, like unexpected traffic blockades, or extreme inclement weather. While we strive to deliver your orders at your desired time, please allow a leeway of approximately 30 minutes from the specified delivery time for unexpected delays.",
                  ),
                  _policyText(
                    "Delivery of all orders will be to the pickup point address provided by the customer. Status of the deliveries can be checked on the MyFoodMyPrice App.",
                  ),
                  _policyTextWithLink(
                    prefix:
                        "For any issues in utilizing our services you may contact our helpdesk on or ",
                    linkText: "support@biryanipalayam.com",
                    onTap:
                        () => UrlLauncherHelper.launchInBrowser(
                          context,
                          "mailto:support@biryanipalayam.com",
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
