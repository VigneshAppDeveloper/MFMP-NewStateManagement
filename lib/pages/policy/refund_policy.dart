import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

import '../../util/color_constant.dart';

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
      appBar: const CommonAppBar(
        title: "Cancellation & Refund Policy",
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
                            onTap: () => UrlLauncherHelper.launchInBrowser(
                              context,
                              'https://myfoodmyprice.com/cancellation-policy',
                            ),
                            child: Text(
                              'https://myfoodmyprice.com/cancellation-policy',
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
                    'Last updated: Nov 13, 2025',
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 24),

                  policyPoint(
                    "MyFoodMyPrice believes in helping its customers as far as possible and follows a transparent and fair cancellation policy.",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Cancellation Policy :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  policyPoint(
                    ". Orders are eligible for full cancellation and refund only if the cancellation request is made before 5:00 PM IST on the day prior to the scheduled pickup date.",
                  ),
                  policyPoint(
                    ". Cancellation requests received after 5:00 PM IST on the day prior to pickup will not be accepted, and no refund will be provided.",
                  ),
                  policyPoint(
                    "This policy is necessary as food preparation planning begins after the cutoff time.",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Quality Issues & Refunds :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  policyPoint(
                    ". In case a customer establishes that the quality of the food purchased is not satisfactory, a refund or replacement may be considered.",
                  ),
                  policyPoint(
                    ". Such issues must be reported to the customer service team within 2 hours of the pickup time.",
                  ),
                   policyPoint(
                    ". The customer service team will review the complaint and take an appropriate decision. Validation of the claim will be done independently by MyFoodMyPrice.",
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Refund Processing :',
                        style: Styles.textStyleMediumBold(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                   policyPoint(
                    ". Any refund approved by MyFoodMyPrice will be processed within 1–2 working days to the original mode of payment",
                  ),
                ],
              ),
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
