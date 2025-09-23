import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../Providers/restaurant_provider.dart';
import '../components/FlashSalePageDesign/flash_app_bar.dart';
import '../components/HomePageDesigns/food_category_header.dart';
import '../components/HomePageDesigns/home_search_bar.dart';
import '../components/HomePageDesigns/restaurant_wiget.dart';
import '../models/FoodModels/food_model.dart';
import '../models/Resturant Model/resturant.dart';
import '../services/secure_storage.dart';
import '../util/app_contant.dart';
import '../widgets/full_shimmer_loader.dart';

class FlashSalePage extends StatefulWidget {
  const FlashSalePage({super.key});

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  late ScrollController scrollController;
  late final TextEditingController searchController;
  bool initialized = false;

  // final restaurants = <Restaurant>[
  //   Restaurant(
  //     name: "biryani palayam",
  //     rating: 4.2,
  //     area: "Kollampalayam",
  //     distanceKm: "6.7 km",
  //     cuisines: "Chicken Biryani, Mutton Biryani..",
  //     image: "assets/figmaIcons/bpm.png",
  //   ),
  //   Restaurant(
  //     name: "palmshore",
  //     rating: 4.5,
  //     area: "Porur",
  //     distanceKm: "1.8 km",
  //     cuisines: "Grill, BBQ, Arabian..",
  //     image: "assets/figmaIcons/palmshore.png",
  //   ),
  //   Restaurant(
  //     name: "SS Hydrababad Biryani",
  //     rating: 4.5,
  //     area: "viyasarbadi",
  //     distanceKm: "5.3 km",
  //     cuisines: "Biryani, Kebabs..",
  //     image: "assets/figmaIcons/hydbiryani.png",
  //   ),
  //   Restaurant(
  //     name: "palmshore",
  //     rating: 4.5,
  //     area: "Porur",
  //     distanceKm: "1.8 km",
  //     cuisines: "Grill, BBQ, Arabian..",
  //     image: "assets/figmaIcons/palmshore.png",
  //   ),
  //   Restaurant(
  //     name: "ss hydrababad Biryani",
  //     rating: 4.5,
  //     area: "Viyasarbadi",
  //     distanceKm: "5.3 km",
  //     cuisines: "Biryani, Kebabs..",
  //     image: "assets/figmaIcons/hydbiryani.png",
  //   ),
  //   Restaurant(
  //     name: "Palmshore",
  //     rating: 4.5,
  //     area: "Porur",
  //     distanceKm: "1.8 km",
  //     cuisines: "Grill, BBQ, Arabian..",
  //     image: "assets/figmaIcons/palmshore.png",
  //   ),
  //   Restaurant(
  //     name: "SS Hydrababad Biryani",
  //     rating: 4.5,
  //     area: "Viyasarbadi",
  //     distanceKm: "5.3 km",
  //     cuisines: "Biryani, Kebabs..",
  //     image: "assets/figmaIcons/hydbiryani.png",
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!initialized) {
        getFlashRestaurants();
        initialized = true;
      }
    });
  }

  Future<void> getFlashRestaurants() async {
    try {
      final lat = await SecureStorageService.read(AppConstants.latitude);
      final lng = await SecureStorageService.read(AppConstants.longitude);
      if (lat != null && lng != null) {
        final provider = context.read<RestaurantProvider>();
        // await provider.getFlashSaleRestaurants(
        //   lat: double.parse(lat),
        //   lng: double.parse(lng),
        // );
      }
    } catch (e) {
      debugPrint("❌ Flash API error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: getFlashRestaurants,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            FlashAppBar(
              countdown: "00:10:45",
              searchController: searchController,
            ),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/figmaIcons/discount.png",
                      height: 48,
                      width: 103,
                      fit: BoxFit.contain,
                    ),
                    Expanded(child: Image.asset("assets/figmaIcons/offer.png")),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FoodCategoryHeader([
                FoodCategory(
                  name: "Biryani",
                  image: "assets/figmaIcons/briyani.png",
                ),
                FoodCategory(
                  name: "South Indian",
                  image: "assets/figmaIcons/southindian.png",
                ),
                FoodCategory(
                  name: "Chinese",
                  image: "assets/figmaIcons/chinese.png",
                ),
                FoodCategory(
                  name: "North Indian",
                  image: "assets/figmaIcons/northindian.png",
                ),
                FoodCategory(
                  name: "Noodles",
                  image: "assets/figmaIcons/noodles.png",
                ),
              ]),
            ),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.01)),

            // SliverList(
            //   delegate: SliverChildBuilderDelegate((context, index) {
            //     final restaurant = restaurants[index];

            //     return Padding(
            //       padding: EdgeInsets.symmetric(
            //         vertical: MediaQuery.of(context).size.height * 0.012,
            //       ),
            //       child: GestureDetector(
            //         onTap: () {
            //           AppRouteName.menuPage.push(
            //             context,
            //             args: {
            //               'restaurant': restaurants[index],
            //               'showPriceTabs': false, // 👈
            //             },
            //           );
            //         },
            //         child: RestaurantCard(data: restaurant),
            //       ),
            //     );
            //   }, childCount: restaurants.length),
            // ),

            // Consumer<RestaurantProvider>(
            //   builder: (context, provider, _) {
            //     if (provider.isLoading) {
            //       return SliverToBoxAdapter(
            //         child: SizedBox(
            //           height: size.height,
            //           child: const FullScreenShimmer(),
            //         ),
            //       );
            //     }
            //     if (provider.flashSaleRestaurants.isEmpty) {
            //       return SliverToBoxAdapter(
            //         child: Center(
            //           child: Text(
            //             "No flash sale offers right now",
            //             style: Styles.textStyleMedium(context),
            //             textScaler: TextScaler.linear(1.0),
            //           ),
            //         ),
            //       );
            //     }
            //     return SliverList(
            //       delegate: SliverChildBuilderDelegate(
            //         (context, index) => Padding(
            //           padding: EdgeInsets.symmetric(vertical: 12),
            //           child: RestaurantCard(
            //             data: provider.flashSaleRestaurants[index],
            //             //  showDiscount: true, // 👈 add discount badge
            //           ),
            //         ),
            //         childCount: provider.flashSaleRestaurants.length,
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class _FoodCategoryHeader extends SliverPersistentHeaderDelegate {
  final List<FoodCategory> categories;

  _FoodCategoryHeader(this.categories);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 Removed extra vertical padding (already in FoodCategoryHeader)
          const FoodCategoryHeader(),

          SizedBox(height: size.height * 0.01),

          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        category.image,
                        height: size.height * 0.06,
                        width: size.height * 0.06,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      style: Styles.textSmall(
                        context,
                      ).copyWith(fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent {
    final screenHeight =
        WidgetsBinding.instance.window.physicalSize.height /
        WidgetsBinding.instance.window.devicePixelRatio;

    final double padding = 0; // 👉 No vertical padding outside
    final double headerHeight =
        screenHeight * 0.015 * 2; // from FoodCategoryHeader
    final double spacing = screenHeight * 0.01;
    final double gridHeight = screenHeight * 0.11;

    return headerHeight + spacing + gridHeight;
  }

  @override
  double get minExtent => maxExtent;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
