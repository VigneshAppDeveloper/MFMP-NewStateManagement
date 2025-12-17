import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../Providers/location_provider.dart';
import '../Providers/restaurant_provider.dart';
import '../components/FlashSalePageDesign/flash_app_bar.dart';
import '../components/HomePageDesigns/food_category_header.dart';
import '../components/HomePageDesigns/restaurant_wiget.dart';
import '../models/FoodModels/food_model.dart';

import '../widgets/app_shimmer.dart';
import '../widgets/dilogue/dilogue.dart';
import '../widgets/shimmer_type.dart';

class FlashSalePage extends StatefulWidget {
  const FlashSalePage({super.key});

  @override
  State<FlashSalePage> createState() => _FlashSalePageState();
}

class _FlashSalePageState extends State<FlashSalePage> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  double lastOffset = 0;
  bool initializedRestaurant = false;

  Duration _remaining = const Duration(hours: 1);
  Timer? _countdownTimer;
  late VoidCallback _locationListener;
  late final LocationProvider _locationProvider;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
    _startCountdownTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurantProvider = context.read<RestaurantProvider>();
      _locationProvider = context.read<LocationProvider>();

      if (!initializedRestaurant) {
        getRestaurantsList();
        restaurantProvider.getFoodCategory();
        initializedRestaurant = true;
      }

      // 🔹 Auto-refresh on location change
      _locationListener = () async {
        final newLocation = _locationProvider.currentLocation;
        if (newLocation != null) {
          await restaurantProvider.getRestaurants(
            lat: newLocation.latitude,
            lng: newLocation.longitude,
            isFlash: true,
          );
        }
      };

      _locationProvider.addListener(_locationListener);
    });
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
          isFlash: true, // 👈 Flash pagination
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _countdownTimer?.cancel();
    _locationProvider.removeListener(_locationListener);
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel(); // clear if running
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> getRestaurantsList() async {
    try {
      final location = context.read<LocationProvider>().currentLocation;
      if (location != null) {
        await context.read<RestaurantProvider>().getRestaurants(
          lat: location.latitude,
          lng: location.longitude,
          isFlash: true, // 👈 added
        );
        final provider = context.read<RestaurantProvider>();
        debugPrint(
          "✅ Restaurants fetched: ${provider.flashRestaurants.length} items",
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
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
           color: AppColor.maincolor,
        onRefresh: getRestaurantsList,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: FlashBanner(
                    searchController: _searchController,
                    onFilterTap: () {
                      AppRouteName.restaurantSearchPage.push(
                        context,
                        args: {'isFlash': true},
                      );
                    },
                  ),
                ),

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
                          "",
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
                _buildDivider(size),

                _buildRestaurantList(provider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(Size size) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            "Choose your Favourite Restaurant",
            textScaler: const TextScaler.linear(1.0),
            style: Styles.textStyleMedium(context),
          ),
          SizedBox(width: 5),
          Expanded(child: Divider()),
        ],
      ),
    ),
  );

  Widget _buildRestaurantList(RestaurantProvider provider) {
    if (provider.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const AppShimmer(type: ShimmerType.restaurant),
        ),
      );
    }

    final list = provider.flashRestaurants;

    if (list.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            "No Flash restaurants found",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // ✅ Safe pagination builder
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // loader cell at bottom
        if (provider.isPaginating && index == list.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // valid restaurant items only
        if (index < list.length) {
          final restaurant = list[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                AppRouteName.menuPage.push(
                  context,
                  args: {'restaurant': restaurant, 'showPriceTabs': false},
                );
              },
              child: RestaurantCard(data: restaurant),
            ),
          );
        }

        // fallback safety (never reached)
        return const SizedBox.shrink();
      }, childCount: list.length + (provider.isPaginating ? 1 : 0)),
    );
  }
}

class _FoodCategoryHeader extends SliverPersistentHeaderDelegate {
  final List<FoodCategory> categories;
  _FoodCategoryHeader(this.categories);

  // heights
  double get _headerHeight => 40.0; // title row height
  double get _spacing => 5.0; // gap below title
  double get _listHeight => 100.0; // horizontal list height
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
                            'fromFlashPage': true, // ✅ mark Flash flow
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
                          height: size.height * 0.07,
                          width: size.height * 0.07,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: c.image,
                              fit: BoxFit.cover,
                              width: size.height * 0.07,
                              height: size.height * 0.07,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.fastfood,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(
                                        Icons.fastfood,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
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
