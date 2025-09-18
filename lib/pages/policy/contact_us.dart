import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:const CommonAppBar(title: "Contact Us", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Scrollbar(
            thumbVisibility: true,
            //radius: const Radius.circular(10),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Link Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Link:',
                        style: Styles.textStyleMediumBold(context),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap:
                              () => UrlLauncherHelper.launchInBrowser(
                                context,
                                'https://www.biryanipalayam.com/copy-of-cancellation-refund-policy',
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
                    'Last updated on Mar 21st 2024',
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 30),

                  contactDetail(
                    'Merchant Legal entity name:',
                    'Biryanipalayam',
                  ),
                  contactDetail(
                    'Registered Address:',
                    '1, THAYUMANASUNDARAM STREET, KOLLAMPALAYAM\nErode, TAMIL NADU 638002',
                  ),
                  contactDetail(
                    'Operational Address:',
                    '1, THAYUMANASUNDARAM STREET, KOLLAMPALAYAM\nErode, TAMIL NADU 638002',
                  ),
                  contactDetail('Telephone No:', '9994210404'),
                  contactDetail('E-Mail ID:', 'info@biryanipalayam.com'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget contactDetail(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              title,
              style: Styles.textStyleMedium(context),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              content,
              style: Styles.textStyleMedium(context, color: AppColor.maincolor),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
        ],
      ),
    );
  }

}
