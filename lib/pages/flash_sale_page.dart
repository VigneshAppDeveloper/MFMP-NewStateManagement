import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../Providers/location_provider.dart';
import '../Providers/restaurant_provider.dart';
import '../components/FlashSalePageDesign/flash_app_bar.dart';
import '../components/HomePageDesigns/food_category_header.dart';
import '../components/HomePageDesigns/home_search_bar.dart';
import '../components/HomePageDesigns/restaurant_wiget.dart';
import '../models/FoodModels/food_model.dart';

import '../models/Resturant Model/resturant.dart';
import '../util/color_constant.dart';
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
  Timer? _debounce;

  // ✅ Local search state
  List<Restaurant> filteredRestaurants = [];
  bool isSearching = false;

  Duration _remaining = const Duration(hours: 1);
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _searchController = TextEditingController();
    _startCountdownTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RestaurantProvider>();
      if (!initializedRestaurant) {
        getRestaurantsList();
        provider.getFoodCategory();
        initializedRestaurant = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _countdownTimer?.cancel();
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
        );
        final provider = context.read<RestaurantProvider>();
        debugPrint(
          "✅ Restaurants fetched: ${provider.restaurants.length} items",
        );
      } else {
        debugPrint("⚠️ No location found in LocationProvider");
      }
    } catch (e) {
      debugPrint("❌ Error fetching restaurants: $e");
    }
  }

  // ✅ Local search handler with detailed debug prints
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    final q = query.trim().toLowerCase();

    // 👇 switch layout instantly
    setState(() {
      isSearching = q.isNotEmpty;
    });

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = context.read<RestaurantProvider>();
      final all = provider.restaurants;

      if (q.isEmpty) {
        setState(() => filteredRestaurants.clear());
        return;
      }

      final results =
          all.where((r) {
            final name = r.name.toLowerCase().trim();
            final addr = r.address.toLowerCase().trim();
            return name.contains(q) || addr.contains(q);
          }).toList();

      setState(() => filteredRestaurants = results);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<RestaurantProvider>();
    // String _formatCountdown() {
    //   final h = _remaining.inHours.toString().padLeft(2, '0');
    //   final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    //   final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    //   return "$h:$m:$s";
    // }

    return PopScope(
      canPop: !isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (isSearching) {
          debugPrint("⬅️ Back pressed — clearing search state");
          setState(() {
            isSearching = false;
            filteredRestaurants.clear();
            _searchController.clear();
          });
          Future.delayed(const Duration(milliseconds: 200), () {
            FocusScope.of(context).unfocus();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: getRestaurantsList,
          child: Stack(
            children: [
              if (isSearching)
                Positioned.fill(
                  top: size.height * 0.30,
                  child: Container(color: Colors.white),
                ),

              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  if (!isSearching)
                    SliverToBoxAdapter(
                      child: FlashBanner(
                        // countdown: _formatCountdown(),
                        searchController: _searchController,
                        onSearchChanged: _onSearchChanged,
                      ),
                    )
                  else
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 2,
                      toolbarHeight: size.height * 0.075,
                      title: HomeSearchBar(
                        controller: _searchController,
                        onFilterTap: () {},
                        onChanged: _onSearchChanged,
                      ),
                    ),

                  if (!isSearching) ...[
                    SliverToBoxAdapter(
                      child: SizedBox(height: size.height * 0.02),
                    ),
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: size.width * 0.03,
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Image.asset(
                    //           "assets/figmaIcons/discount.png",
                    //           height: 48,
                    //           width: 103,
                    //           fit: BoxFit.contain,
                    //         ),
                    //         Expanded(
                    //           child: Image.asset(
                    //             "assets/figmaIcons/offer.png",
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SliverToBoxAdapter(
                    //   child: SizedBox(height: size.height * 0.02),
                    // ),
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
                  ],

                  _buildRestaurantList(provider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildRestaurantList(RestaurantProvider provider) {
    final list = isSearching ? filteredRestaurants : provider.restaurants;

    // debugPrint(
    //   "📊 Building restaurant list | Searching: $isSearching | Count: ${list.length}",
    // );

    if (provider.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const AppShimmer(type: ShimmerType.restaurant),
        ),
      );
    }

    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            "No restaurants found",
            style: Styles.textStyleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(1.0),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        //   debugPrint("🍽️ Showing: ${list[index].name}");
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              AppRouteName.menuPage.push(
                context,
                args: {'restaurant': list[index], 'showPriceTabs': false},
              );
            },
            child: RestaurantCard(data: list[index]),
          ),
        );
      }, childCount: list.length),
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
