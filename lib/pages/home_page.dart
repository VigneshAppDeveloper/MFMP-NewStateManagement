import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/location_provider.dart';
import 'package:my_food_my_price/Providers/restaurant_provider.dart';
import 'package:my_food_my_price/components/HomePageDesigns/banner.dart';
import 'package:my_food_my_price/components/HomePageDesigns/food_category_header.dart';
import 'package:my_food_my_price/components/HomePageDesigns/home_app_bar.dart';
import 'package:my_food_my_price/components/HomePageDesigns/home_search_bar.dart';
import 'package:my_food_my_price/components/HomePageDesigns/restaurant_wiget.dart';
import 'package:my_food_my_price/models/FoodModels/food_model.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../route_generator.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/shimmer_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  late final TextEditingController _searchController;

  bool initalizedResturant = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    final provider = context.read<RestaurantProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!initalizedResturant) {
        getRestaurantsList();
        provider.getFoodCategory();
        initalizedResturant = true;
      }
    });
  }

  Future<void> getRestaurantsList() async {
    try {
      final location = context.read<LocationProvider>().currentLocation;

      if (location != null) {
        final provider = context.read<RestaurantProvider>();
        await provider.getRestaurants(
          lat: location.latitude,
          lng: location.longitude,
        );
      } else {
        debugPrint("⚠️ No location found in LocationProvider");
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

                Consumer<RestaurantProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.categories.isEmpty) {
                      return SliverToBoxAdapter(
                        child: AppShimmer(
                          type: ShimmerType.category,
                          itemCount: 6,
                        ),
                      );
                    }

                    if (provider.categories.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Text(
                          "No categories available",
                          textAlign: TextAlign.center,
                          style: Styles.textStyleMedium(context),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      );
                    }

                    return SliverPersistentHeader(
                      pinned: true,
                      delegate: _FoodCategoryHeader(provider.categories),
                    );
                  },
                ),

                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
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

                //      SliverList(
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
                //               'showPriceTabs': true, // 👈
                //             },
                //           );
                //         },
                //         child: RestaurantCard(data: restaurant),
                //       ),
                //     );
                //   }, childCount: restaurants.length),
                // ),
                // 🔻 Sliver list of cards
                Consumer<RestaurantProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: const AppShimmer(type: ShimmerType.restaurant),
                        ),
                      );
                    }

                    if (provider.restaurants.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Text(
                          "No restaurants nearby",
                          style: Styles.textStyleMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w700),

                          textScaler: const TextScaler.linear(1.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: GestureDetector(
                            onTap: () {
                              AppRouteName.menuPage.push(
                                context,
                                args: {
                                  'restaurant': provider.restaurants[index],
                                  'showPriceTabs': true,
                                },
                              );
                            },
                            child: RestaurantCard(
                              data: provider.restaurants[index],
                            ),
                          ),
                        ),
                        childCount: provider.restaurants.length,
                      ),
                    );
                  },
                ),
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

  // heights
  double get _headerHeight => 48.0; // title row height
  double get _spacing => 8.0; // gap below title
  double get _listHeight => 120.0; // horizontal list height
  double get _totalHeight => _headerHeight + _spacing + _listHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: _totalHeight,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: _headerHeight, child: const FoodCategoryHeader()),
            SizedBox(height: _spacing),
            SizedBox(
              height: _listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final c = categories[index];
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
                        child: Image.network(
                          c.image,
                          height: size.height * 0.06,
                          width: size.height * 0.06,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.fastfood),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ✅ Flexible prevents tiny overflow
                      Flexible(
                        child: Text(
                          c.name,
                          style: Styles.textSmall(
                            context,
                          ).copyWith(fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      //  const SizedBox(height: 6),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => _totalHeight;

  @override
  double get minExtent => _totalHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
