import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/restaurant_provider.dart';
import 'package:my_food_my_price/components/HomePageDesigns/banner.dart';
import 'package:my_food_my_price/components/HomePageDesigns/food_category_header.dart';
import 'package:my_food_my_price/components/HomePageDesigns/home_app_bar.dart';
import 'package:my_food_my_price/components/HomePageDesigns/home_search_bar.dart';
import 'package:my_food_my_price/components/HomePageDesigns/restaurant_wiget.dart';
import 'package:my_food_my_price/models/FoodModels/food_model.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/full_shimmer_loader.dart';
import 'package:provider/provider.dart';

import '../models/Resturant Model/resturant.dart';
import '../services/secure_storage.dart';
import '../util/app_contant.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  late final TextEditingController _searchController;

  bool initalizedResturant = false;

  final restaurants = <Restaurant>[
    Restaurant(
      name: "biryani palayam",
      rating: 4.2,
      area: "Kollampalayam",
      distanceKm: "6.7 km",
      cuisines: "Chicken Biryani, Mutton Biryani..",
      image: "assets/figmaIcons/bpm.png",
    ),
    Restaurant(
      name: "palmshore",
      rating: 4.5,
      area: "Porur",
      distanceKm: "1.8 km",
      cuisines: "Grill, BBQ, Arabian..",
      image: "assets/figmaIcons/palmshore.png",
    ),
    Restaurant(
      name: "SS Hydrababad Biryani",
      rating: 4.5,
      area: "viyasarbadi",
      distanceKm: "5.3 km",
      cuisines: "Biryani, Kebabs..",
      image: "assets/figmaIcons/hydbiryani.png",
    ),
      Restaurant(
      name: "palmshore",
      rating: 4.5,
      area: "Porur",
      distanceKm: "1.8 km",
      cuisines: "Grill, BBQ, Arabian..",
      image: "assets/figmaIcons/palmshore.png",
    ),
    Restaurant(
      name: "ss hydrababad Biryani",
      rating: 4.5,
      area: "Viyasarbadi",
      distanceKm: "5.3 km",
      cuisines: "Biryani, Kebabs..",
      image: "assets/figmaIcons/hydbiryani.png",
    ),
      Restaurant(
      name: "Palmshore",
      rating: 4.5,
      area: "Porur",
      distanceKm: "1.8 km",
      cuisines: "Grill, BBQ, Arabian..",
      image: "assets/figmaIcons/palmshore.png",
    ),
    Restaurant(
      name: "SS Hydrababad Biryani",
      rating: 4.5,
      area: "Viyasarbadi",
      distanceKm: "5.3 km",
      cuisines: "Biryani, Kebabs..",
      image: "assets/figmaIcons/hydbiryani.png",
    ),
  ];


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!initalizedResturant) {
    //   getRestaurantsList();
    //     initalizedResturant = true;
    //   }
    // });
  }

  Future<void> getRestaurantsList() async {
    try {
      final lat = await SecureStorageService.read(AppConstants.latitude);
      final lng = await SecureStorageService.read(AppConstants.longitude);

      if (lat != null && lng != null) {
        final provider = context.read<RestaurantProvider>(); // 👈 declare here
        await provider.getRestaurants(
          // 👈 await this
          lat: double.parse(lat),
          lng: double.parse(lng),
        );
      } else {
        debugPrint("⚠️ No lat/lng found in secure storage");
      }
    } catch (e) {
      debugPrint("❌ Error fetching restaurants: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await getRestaurantsList();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: HomeAppBar()),
                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

                SliverAppBar(
                  backgroundColor: Colors.white,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  toolbarHeight: size.height * 0.075,
                  automaticallyImplyLeading: false,
                  flexibleSpace: HomeSearchBar(
                    controller: _searchController,
                    onFilterTap: () {
                      // Handle filter tap
                    },
                  ),
                ),

                SliverToBoxAdapter(child: HomeBanner()),
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
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: .5),
                      ),
                      Container(
                        height: size.height * 0.055,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.06,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.blackColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white, width: 0.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Choose your Favourite Restaurant',
                          style: Styles.textSmall(context, color: Colors.white),
                          textScaler: const TextScaler.linear(1.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Colors.grey, thickness: .5),
                      ),
                    ],
                  ),
                ),
                // Static sample list (swap with Provider later)
                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.01)),

                 SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final restaurant = restaurants[index];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.012,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      AppRouteName.menuPage.push(
                        context,
                        args: {
                          'restaurant': restaurants[index],
                          'showPriceTabs': true, // 👈
                        },
                      );
                    },
                    child: RestaurantCard(data: restaurant),
                  ),
                );
              }, childCount: restaurants.length),
            ),
                // 🔻 Sliver list of cards
                // Consumer<RestaurantProvider>(
                //   builder: (context, provider, _) {
                //     if (provider.isLoading) {
                //       return SliverToBoxAdapter(
                //         child: SizedBox(
                //           height: MediaQuery.of(context).size.height,
                //           child: const FullScreenShimmer(),
                //         ),
                //       );
                //     }

                //     if (provider.restaurants.isEmpty) {
                //       return SliverToBoxAdapter(
                //         child: Text(
                //           "No restaurants nearby",
                //           style: Styles.textStyleMedium(
                //             context,
                //           ).copyWith(fontWeight: FontWeight.w700),

                //           textScaler: const TextScaler.linear(1.0),
                //           textAlign: TextAlign.center,
                //         ),
                //       );
                //     }

                //     return SliverList(
                //       delegate: SliverChildBuilderDelegate(
                //         (context, index) => Padding(
                //           padding: EdgeInsets.symmetric(vertical: 12),
                //           child: RestaurantCard(
                //             data: provider.restaurants[index],
                //           ),
                //         ),
                //         childCount: provider.restaurants.length,
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
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
