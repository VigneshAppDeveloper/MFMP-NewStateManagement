import 'package:flutter/material.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../Providers/restaurant_provider.dart';
import '../components/HomePageDesigns/restaurant_wiget.dart';
import '../models/FoodModels/food_model.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/shimmer_type.dart';

class CategoryRestaurantsPage extends StatefulWidget {
  final FoodCategory category;
  final double lat;
  final double lng;
  final bool fromFlashPage; // ✅ new flag

  const CategoryRestaurantsPage({
    super.key,
    required this.category,
    required this.lat,
    required this.lng,
    this.fromFlashPage = false, // ✅ default
  });

  @override
  State<CategoryRestaurantsPage> createState() =>
      _CategoryRestaurantsPageState();
}

class _CategoryRestaurantsPageState extends State<CategoryRestaurantsPage> {
  late final RestaurantProvider provider;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    provider = context.read<RestaurantProvider>();
    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.getRestaurantsByCategory(
        lat: widget.lat,
        lng: widget.lng,
        menuTypeId: widget.category.id,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      provider.loadNextCategoryPage(
        lat: widget.lat,
        lng: widget.lng,
        menuTypeId: widget.category.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = context.watch<RestaurantProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(title: widget.category.name, showBack: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.getRestaurantsByCategory(
            lat: widget.lat,
            lng: widget.lng,
            menuTypeId: widget.category.id,
            forceRefresh: true,
          );
        },
        child:
            provider.isLoading
                ? const Center(
                  child: const AppShimmer(type: ShimmerType.restaurant),
                )
                : provider.categoryRestaurants.isEmpty
                ? Center(
                  child: Text(
                    "No restaurants found for ${widget.category.name}",
                    style: Styles.textStyleMedium(context),
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),

                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.04,
                    size.height * 0.015,
                    size.width * 0.04,
                    MediaQuery.of(context).padding.bottom +
                        20, // prevent overlay bottom
                  ),

                  itemCount:
                      provider.categoryRestaurants.length +
                      (provider.isPaginatingCategory ? 1 : 0),

                  itemBuilder: (context, index) {
                    if (index == provider.categoryRestaurants.length) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final restaurant = provider.categoryRestaurants[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: GestureDetector(
                        onTap: () {
                          AppRouteName.menuPage.push(
                            context,
                            args: {
                              'restaurant': restaurant,
                              'showPriceTabs': !widget.fromFlashPage,
                            },
                          );
                        },
                        child: RestaurantCard(data: restaurant),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
