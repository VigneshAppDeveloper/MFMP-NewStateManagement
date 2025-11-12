import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/dilogue/dilogue.dart';
import '../widgets/shimmer_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  bool initializedRestaurant = false;
  late VoidCallback _locationListener;
  late final LocationProvider _locationProvider;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider = context.read<RestaurantProvider>();
      _locationProvider = context.read<LocationProvider>(); 

      if (!initializedRestaurant) {
        getRestaurantsList(); // first load
        restaurantProvider.getFoodCategory();
        initializedRestaurant = true;
      }

      // 🔹 Listen for location updates globally
      _locationListener = () async {
       final newLocation = _locationProvider.currentLocation;
        if (newLocation != null) {
          await restaurantProvider.getRestaurants(
            lat: newLocation.latitude,
            lng: newLocation.longitude,
            isFlash: false,
          );
        }
      };

       _locationProvider.addListener(_locationListener);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _locationProvider.removeListener(_locationListener);

    super.dispose();
  }

  void _onScroll() async {
    final provider = context.read<RestaurantProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final location = _locationProvider.currentLocation;
      if (location != null) {
        await provider.loadNextPageIfNeeded(
          lat: location.latitude,
          lng: location.longitude,
          isFlash: false,
        );
      }
    }
  }

  Future<void> getRestaurantsList() async {
    try {
      final location = context.read<LocationProvider>().currentLocation;
      if (location != null) {
        await context.read<RestaurantProvider>().getRestaurants(
          lat: location.latitude,
          lng: location.longitude,
        );
      } else {
        debugPrint("⚠️ No location found in LocationProvider");
      }
    } catch (e) {
      debugPrint("❌ Error fetching restaurants: $e");
    } finally {
      // ✅ Always reset filters and flags after reload
      setState(() {
        _searchController.clear();
      });
    }
  }

  // ✅ Local search function

  // 🔹 Opens bottom sheet with filters

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getRestaurantsList,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: Stack(
              children: [
                // ✅ White overlay only when searching
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(child: HomeAppBar()),
                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.02),
                    ),

                    // ✅ Floating Search Bar (uses local search)
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      floating: true,
                      snap: true,
                      elevation: 0,
                      toolbarHeight: size.height * 0.075,
                      automaticallyImplyLeading: false,
                      flexibleSpace: HomeSearchBar(
                        controller: _searchController,
                        enableNavigation:
                            true, // default, opens RestaurantSearchPage
                        isFlash: false,
                        hintText: "Search for restaurants",
                        onFilterTap: () {
                          AppRouteName.restaurantSearchPage.push(
                            context,
                            args: {'isFlash': false},
                          );
                        },
                        onChanged: (_) {},
                      ),
                    ),

                    // ✅ Only show banners and categories when not searching
                    SliverToBoxAdapter(child: HomeBanner()),
                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.001),
                    ),

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

                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.02),
                    ),
                    _buildDivider(size),

                    // ✅ Restaurant List (search or default)
                    _buildRestaurantList(provider),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setStatusBarStyle(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
  }

  Widget _buildDivider(Size size) => SliverToBoxAdapter(
    child: Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: .5)),
        Container(
          height: size.height * 0.055,
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
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
        const Expanded(child: Divider(color: Colors.grey, thickness: .5)),
      ],
    ),
  );

  // ✅ Restaurant list (local search logic)
  Widget _buildRestaurantList(RestaurantProvider provider) {
    if (provider.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const AppShimmer(type: ShimmerType.restaurant),
        ),
      );
    }

    // ✅ Start with either search or all restaurants
    final list = provider.restaurants;

    if (list.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text("No restaurants found", textAlign: TextAlign.center),
        ),
      );
    }

    // ✅ Normal list rendering
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // 👇 bottom loader row
        if (provider.isPaginating && index == list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
          );
        }

        // 👇 valid restaurant rows
        if (index < list.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                AppRouteName.menuPage.push(
                  context,
                  args: {'restaurant': list[index], 'showPriceTabs': true},
                );
              },
              child: RestaurantCard(data: list[index]),
            ),
          );
        }

        return const SizedBox.shrink(); // fallback safety
      }, childCount: list.length + (provider.isPaginating ? 1 : 0)),
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
                  return GestureDetector(
                    onTap: () {
                      final location =
                          context.read<LocationProvider>().currentLocation;
                      if (location != null) {
                        AppRouteName.categoryRestaurantsPage.push(
                          context,
                          args: {
                            'category': c,
                            'lat': location.latitude,
                            'lng': location.longitude,
                          },
                        );
                      } else {
                        AppDialogue.toast("Location not available");
                      }
                    },
                    child: Column(
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
                    ),
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
