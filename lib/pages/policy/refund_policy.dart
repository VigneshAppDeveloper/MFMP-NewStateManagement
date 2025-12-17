import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';
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
              // Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         "Link: ",
              //         style: Styles.textStyleMediumBold(
              //           context,
              //           color: AppColor.maincolor,
              //         ),
              //         textScaler: const TextScaler.linear(1.0),
              //       ),
              //       const SizedBox(width: 8),
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: () => UrlLauncherHelper.launchInBrowser(
              //             context,
              //             'https://www.biryanipalayam.com/copy-of-terms-conditions',
              //           ),
              //           child: Text(
              //             'www.biryanipalayam.com',
              //             style: Styles.textStyleMediumBold(
              //               context,
              //               color: Colors.blueAccent,
              //             ),
              //             textScaler: const TextScaler.linear(1.0),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              //   const SizedBox(height: 20),

                Text(
                  'Last updated: Nov 26, 2025',
                  style: Styles.textSmall(context),
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 24),

                policyPoint(
                    "MyFoodMyPrice aims to support its customers wherever possible, and strives to be fair to restaurants and customers. Our cancellation policy is straightforward:"),
                policyPoint(
                    "Cancellations with a full refund are allowed only if done before 5:00 PM IST on the day before your chosen pickup date."),
                policyPoint(
                    "If the cancellation is done after 5:00 PM IST, we will not be able to issue a refund."),
                policyPoint(
                    "If you receive an item and feel the quality is not up to the mark, please report it to our customer service team within 2 hours of your pickup time. After reviewing the issue, the team will decide on the appropriate resolution. Any approved refunds will be processed within 1–2 days."),
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
