import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Providers/restaurant_provider.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/shimmer_type.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // ✅ Fetch banners only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RestaurantProvider>();
      if (provider.banners.isEmpty) {
        provider.getBanners();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final size = MediaQuery.of(context).size;

    // ✅ Loading shimmer
    if (provider.isBannerLoading && provider.banners.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: AppShimmer(type: ShimmerType.banner),
      );
    }

    // ✅ No banner case
    if (provider.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final banners = provider.banners;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: banners.length,
          options: CarouselOptions(
            height: size.height * 0.18,
            autoPlay: true,
            viewportFraction: 1,
            aspectRatio: 2.0,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, _) {
            final banner = banners[index];
            return GestureDetector(
              onTap: () async {
                final uri = Uri.tryParse(banner.redirectUrl);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: banner.bannerImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => AppShimmer(type: ShimmerType.banner),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: size.height * 0.012),

        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: banners.length,
          effect: const WormEffect(
            activeDotColor: Colors.black,
            dotColor: Colors.grey,
            dotHeight: 7,
            dotWidth: 7,
            spacing: 6,
            paintStyle: PaintingStyle.fill,
          ),
        ),

        SizedBox(height: size.height * 0.012),

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