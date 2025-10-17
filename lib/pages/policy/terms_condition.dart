import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

import '../../util/color_constant.dart';
import '../../util/url_launcher.dart';

class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Terms & Conditions", showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Terms & Conditions',
                    style: Styles.textStyleMediumBold(
                      context,
                      color: AppColor.maincolor,
                    ),
                    textScaler: TextScaler.linear(1.0),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Link',
                      style: Styles.textStyleMediumBold(
                        context,
                        color: AppColor.maincolor,
                      ),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            () => UrlLauncherHelper.launchInBrowser(
                              context,
                              'https://www.biryanipalayam.com/copy-of-privacy-policy',
                            ),
                        child: Text(
                          'https://www.biryanipalayam.com/copy-of-privacy-policy',
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Last updated on May 17 2024',
                      style: Styles.textStyleMediumBold(context),
                      textScaler: TextScaler.linear(1.0),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        "The Application Owner, including subsidiaries and affiliates (“Application” or “Application Owner” or “we” or “us” or “our”) provides the information contained on the Application or any of the pages comprising the website (“application”) to visitors (“visitors”) (cumulativelyreferred to as “you” or “your” hereinafter) subject to the terms and conditions set out in these website terms and conditions, the privacy policy and any other relevant terms and conditions, policies and notices which may be applicable to a specific section or module of the website.\n Welcome to our app. If you continue to browse and use this app you are agreeing to comply with and be bound by the following terms and conditions of use, which together with our privacy policy govern Biryanipalayam''s relationship with you in relation to this app.\n The term 'Biryanipalayam' or 'us' or 'we' refers to the owner of the app whose registered/operational office is 1, THAYUMANASUNDARAM STREET, KOLLAMPALAYAM Erode TAMIL NADU 638002. The term 'you' refers to the user or viewer of our app.\n The use of this app is subject to the following terms of use:\n ·        The content of the pages of this application is for your general information and use only. It is subject to change without notice \n ·        Neither we nor any third parties provide any warranty or guarantee as to the accuracy, timeliness, performance, completeness or suitability of the information and materials found or offered on this application for any particular purpose. You acknowledge that such information and materials may contain inaccuracies or errors and we expressly exclude liability for any such inaccuracies or errors to the fullest extent permitted by law.\n ·        Your use of any information or materials on this Application is entirely at your own risk, for which we shall not be liable. It shall be your own responsibility to ensure that any products, services or information available through this website meet your specific requirements.\n ·        This application contains material which is owned by or licensed to us. This material includes, but is not limited to, the design, layout, look, appearance and graphics. Reproduction is prohibited other than in accordance with the copyright notice, which forms part of these terms and conditions.\n ·        All trademarks reproduced in this application which are not the property of, or licensed to, the operator are acknowledged on the application.\n ·        Unauthorized use of this application may give rise to a claim for damages and/or be a criminal offense.\n ·        From time to time this application may also include links to other applications. These links are provided for your convenience to provide further information.\n ·        You may not create a link to this application from another application or document without Biryanipalayam’s prior written consent.\n ·        Your use of this application and any dispute arising out of such use of the application is subject to the laws of India or other regulatory authority.\n We as a merchant shall be under no liability whatsoever in respect of any loss or damage arising directly or indirectly out of the decline of authorization for any Transaction, on Account of the Cardholder having exceeded the preset limit mutually agreed by us with our acquiring bank from time to time",
                        style: Styles.textStyleMedium(
                          context,
                          color: Colors.black,
                        ),
                        textScaler: TextScaler.linear(1.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
