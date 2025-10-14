import 'package:flutter/material.dart';

import '../../../../util/color_constant.dart';
import '../../../../util/styles.dart';

class FixedSuccessScreen extends StatefulWidget {
  const FixedSuccessScreen({super.key});

  @override
  State<FixedSuccessScreen> createState() => _FixedSuccessScreenState();
}

class _FixedSuccessScreenState extends State<FixedSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg/bp_profile-bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 150),
                Icon(
                  Icons.check_circle,
                  color: AppColor.backgroundColor,
                  size: 100,
                ),
                SizedBox(height: 20),
                RichText(
                  textScaler: TextScaler.linear(1.0),
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Payment Successful ! ',
                    style: Styles.textStyleMediumBold(context),
                    children: <TextSpan>[
                      TextSpan(
                        text: '',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 45,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                RichText(
                  textScaler: TextScaler.linear(1.0),
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Order Placed Successfully \n',
                    style: Styles.textStyleMediumBold(context),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Kindly check your order book to view status',
                        style: Styles.textStyleMedium(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 55,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.white),
                      ),
                      elevation: 1,
                    ),
                    onPressed: () {},
                    child: Text(
                      "View Order",
                      style: Styles.textStyleMediumBold(
                        context,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Done',
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
      ),
    );
  }
}
