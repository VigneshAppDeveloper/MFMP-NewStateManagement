import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';

import '../route_generator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final List<String> imagePaths = [
    'assets/bg/i1.jpg',
    'assets/bg/i2.jpg',
    'assets/bg/i3.jpg',
    'assets/bg/i4.jpg',
    'assets/bg/i5.jpg',
    'assets/bg/i6.jpg',
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
      AppRouteName.registerPage.pushReplacement(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: PageView.builder(
              controller: _pageController,
              itemCount: imagePaths.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  imagePaths[index],
                  fit: BoxFit.cover,
                  width: size.width,
                  height: size.height,
                );
              },
            ),
          ),
          // Positioned(
          //   bottom: 50,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: SmoothPageIndicator(
          //       controller: _pageController,
          //       count: imagePaths.length,
          //       effect: WormEffect(
          //         dotHeight: 10,
          //         dotWidth: 10,
          //         activeDotColor: Colors.red,
          //         dotColor: Colors.grey.shade400,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextPage,
        backgroundColor: AppColor.maincolor,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
