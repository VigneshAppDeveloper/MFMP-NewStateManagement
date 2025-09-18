import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

class RefundPolicy extends StatefulWidget {
  const RefundPolicy({super.key});

  @override
  State<RefundPolicy> createState() => _RefundPolicyState();
}

class _RefundPolicyState extends State<RefundPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:const CommonAppBar(title: "Cancellation & Refund Policy", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(children: [const SizedBox(height: 10),
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
                        onTap: () => UrlLauncherHelper.launchInBrowser(
                          context,
                          'https://www.biryanipalayam.com/copy-of-terms-conditions',
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

                Text(
                  'Last updated: May 17, 2024',
                  style: Styles.textSmall(context),
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 24),

                policyPoint(
                    "Biryanipalayam believes in helping its customers as far as possible, and has therefore a liberal cancellation policy. Under this policy:"),
                policyPoint(
                    "Cancellations will be considered only if the request is made within 10 minutes after placing the order."),
                policyPoint(
                    "Biryanipalayam does not accept cancellation requests after the above duration after placing the order. However, refund/replacement can be made if the customer establishes that the quality of product purchased is not good. This should be reported to the customer service team within 2 hours of the pickup time of the food items. The Customer Service Team after looking into your complaint will take an appropriate decision. Validation of the customer claim will be done independently by Biryanipalayam."),
                policyPoint(
                    "In case of any refunds approved by Biryanipalayam, it’ll take 1-2 days for the refund to be processed to the customer."),
              ],
            )
            ),
          ),
        ),
      ),
    );
  }

  Widget policyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: Styles.textStyleMedium(context),
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }
}
