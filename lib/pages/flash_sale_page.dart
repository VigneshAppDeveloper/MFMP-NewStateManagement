import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../Providers/location_provider.dart';
import '../Providers/restaurant_provider.dart';
import '../components/FlashSalePageDesign/flash_app_bar.dart';
import '../components/HomePageDesigns/food_category_header.dart';
import '../components/HomePageDesigns/restaurant_wiget.dart';
import '../models/FoodModels/food_model.dart';

import '../util/color_constant.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/shimmer_type.dart';

class FlashSalePage extends StatefulWidget {
  const FlashSalePage({super.key});

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  late ScrollController scrollController;
  late final TextEditingController searchController;
  bool initialized = false;
  bool initalizedResturant = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    searchController = TextEditingController();
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
      body: RefreshIndicator(
        onRefresh: () async {
          await getRestaurantsList();
        },
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

            Consumer<RestaurantProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.categories.isEmpty) {
                  return SliverToBoxAdapter(
                    child: AppShimmer(type: ShimmerType.category, itemCount: 6),
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
                              'showPriceTabs': false,
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
