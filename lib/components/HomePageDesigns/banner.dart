import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _currentIndex = 0;

  final List<String> bannerList = [
    'assets/bg/slider1 1.png',
    'assets/bg/slider1 1.png',
    'assets/bg/slider1 1.png',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: size.height * 0.15,
            autoPlay: true,
            viewportFraction: 1,
            aspectRatio: 2.0,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          items:
              bannerList.map((imagePath) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                );
              }).toList(),
        ),

        SizedBox(height: size.height * 0.012),

        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: bannerList.length,
          effect: const WormEffect(
            activeDotColor: Colors.black,
            dotColor: Colors.grey,
            dotHeight: 7,
            dotWidth: 7,
            spacing: 6,
            paintStyle: PaintingStyle.fill,
          ),
        ),

        SizedBox(height: size.height * 0.01),

        Text(
          "Quantity or Quality. Always the best in Biryani Palayam",
          textAlign: TextAlign.center,
          style: Styles.textSmall(
            context,
            color: AppColor.maincolor,
          ).copyWith(fontWeight: FontWeight.bold),
          textScaler: const TextScaler.linear(1.0),
        ),
      ],
    );
  }
}
