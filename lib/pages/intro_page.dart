import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../route_generator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final List<String> imagePaths = [
    'assets/bg/i1.jpg',
    'assets/bg/i2-min.jpg',
    'assets/bg/i3-min.jpg',
    'assets/bg/i4-min.jpg',
    'assets/bg/i5-min.jpg',
    'assets/bg/i6-min.jpg',
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < imagePaths.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // ✅ Replace with your navigation logic
      AppRouteName.appPage.pushAndRemoveUntil(
        context,
        (route) => false,
        // 👈 home tab
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Background image slider
            PageView.builder(
              controller: _pageController,
              itemCount: imagePaths.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePaths[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    //color: Colors.black.withOpacity(0.35), // ✅ dark overlay
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(
                      bottom: size.height * 0.12,
                      left: size.width * 0.06,
                      right: size.width * 0.06,
                    ),
                    child: Text(
                      "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 26 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
        
            // 🔹 Page indicator
            // Positioned(
            //   bottom: size.height * 0.08,
            //   left: 0,
            //   right: 0,
            //   child: Center(
            //     child: SmoothPageIndicator(
            //       controller: _pageController,
            //       count: imagePaths.length,
            //       effect: WormEffect(
            //         dotHeight: isTablet ? 12 : 8,
            //         dotWidth: isTablet ? 12 : 8,
            //         activeDotColor: Colors.black,
            //         dotColor: Colors.black.withOpacity(0.4),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),

      // 🔹 Next button (floating but safe)
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.03),
        child: FloatingActionButton(
          onPressed: _nextPage,
          backgroundColor: AppColor.maincolor,
          child: const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
