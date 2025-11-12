import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import '../util/styles.dart';

class NewFranchiseEnquiry extends StatefulWidget {
  const NewFranchiseEnquiry({super.key});

  @override
  State<NewFranchiseEnquiry> createState() => _NewFranchiseEnquiryState();
}

class _NewFranchiseEnquiryState extends State<NewFranchiseEnquiry> {


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      appBar: CommonAppBar(title: " Franchise Enquiry",showBack: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.1),
            Image.asset('assets/icons/MFMP-logo-1.jpg', height: 90),
      
            SizedBox(height: height * 0.04),
      
            _textBlock("MyFoodMyPrice isn't in your city yet!"),
            _textBlock("But you can change that!"),
            _textBlock("Become the MyFoodMyPrice Franchise Owner in Your City!"),
            _textBlock(
              "Bring the MyFoodMyPrice experience to your city, offer our unique prebooking option to your community, and earn passive income. Click the link below to register as a potential franchise owner and help us bring MyFoodMyPrice to your city.",
            ),
      
            SizedBox(height: height * 0.05),
      
            GestureDetector(
             onTap:
                            () => 
                            UrlLauncherHelper.launchInBrowser(
                              context,
                              'https://franchise.myfoodmyprice.com',
                            ),
              child: Container(
                width: width * 0.7,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF02704),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 0.5),
                ),
                child: Text(
                  'Get Started',
                  textAlign: TextAlign.center,
                  style: Styles.textStyleMedium(context, color: Colors.white),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _textBlock(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Styles.textStyleMedium(context),
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }
}