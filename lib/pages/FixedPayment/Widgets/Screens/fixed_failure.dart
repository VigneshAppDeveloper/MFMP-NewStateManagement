import 'package:flutter/material.dart';

import '../../../../util/color_constant.dart';
import '../../../../util/styles.dart';


class FixedFailureScreen extends StatefulWidget {
  const FixedFailureScreen({super.key});

  @override
  State<FixedFailureScreen> createState() => _FixedFailureScreenState();
}

class _FixedFailureScreenState extends State<FixedFailureScreen> {
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
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 40,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                SizedBox(height: 20),
                RichText(
                  textScaler: TextScaler.linear(1.0),
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Payment Failed ! ',
                    style: Styles.textStyleLarge(context),
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
                    text: 'Order not confirmed, Please \n',
                    style: Styles.textStyleMedium(context),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'try again',
                          style: Styles.textStyleMedium(context)),
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
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Navigate back to PaymentPage
                    },
                    child: Text(
                      textScaler: TextScaler.linear(1.0),
                      "Retry Payment",
                      style: Styles.textStyleMedium(
                        context,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 55,
                  width: 200,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(244, 240, 39, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.white),
                      ),
                      elevation: 1,
                    ),
                    onPressed: () async {
                     
                    },
                    child: Text(
                      textScaler: TextScaler.linear(1.0),
                      "Cancel",
                      style: Styles.textStyleMedium(
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
      ),
    );
  }
}

