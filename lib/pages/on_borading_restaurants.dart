import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/url_launcher.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';

class OnBoradingRestaurants extends StatefulWidget {
  const OnBoradingRestaurants({super.key});

  @override
  State<OnBoradingRestaurants> createState() => _OnBoradingRestaurantsState();
}

class _OnBoradingRestaurantsState extends State<OnBoradingRestaurants> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(
        title: "Onboarding Restaurants",
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.04),

              /// 🏷️ MyFoodMyPrice Logo
              Center(
                child: Image.asset(
                  'assets/icons/MFMP-logo-1.jpg', // ✅ replace with your logo asset
                  height: size.height * 0.08,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: size.height * 0.019),

              /// ➕ Plus Icon inside circle
              Container(
                height: size.height * 0.06,
                width: size.height * 0.06,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              /// 🏠 Restaurant Icon Image
              Image.asset(
                'assets/figmaIcons/restaurant 1.png', // ✅ replace with your restaurant image asset
                height: size.height * 0.25,
                fit: BoxFit.contain,
              ),

              SizedBox(height: size.height * 0.04),

              /// 🧾 Title Text
              Text.rich(
                TextSpan(
                  text: "Get ",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: const [
                    TextSpan(
                      text: "Pre-Orders. Reduce Wastage. Increase Profits.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0),
              ),

              SizedBox(height: size.height * 0.02),

              /// 💬 Subtitle
              Text(
                "Join MyFoodMyPrice and start receiving confirmed, prepaid orders in advance.",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0),
              ),

              SizedBox(height: size.height * 0.06),

              /// ✅ Get Started Button
              SizedBox(
                width: double.infinity,
                //height: size.height * 0.055,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    UrlLauncherHelper.launchInBrowser(
                      context,
                      'https://myfoodmyprice.com/',
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textScaler: TextScaler.linear(1.0),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }
}
