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

  @override
  void initState() {
    super.initState();
    provider = context.read<RestaurantProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.getRestaurantsByCategory(
        lat: widget.lat,
        lng: widget.lng,
        menuTypeId: widget.category.id,
      );
    });
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
                : provider.restaurants.isEmpty
                ? Center(
                  child: Text(
                    "No restaurants found for ${widget.category.name}",
                    style: Styles.textStyleMedium(context),
                  ),
                )
                : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.015,
                  ),
                  itemCount: provider.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = provider.restaurants[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
