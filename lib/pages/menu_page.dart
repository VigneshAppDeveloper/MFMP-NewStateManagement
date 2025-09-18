import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';

import '../components/HomePageDesigns/home_search_bar.dart';
import '../components/ResturantMenuDesigns/pickup_date_pickup_point.dart';
import '../components/ResturantMenuDesigns/resturant_menu_card.dart';
import '../components/ResturantMenuDesigns/resturant_menu_header.dart';
import '../models/FoodModels/resturant_menu_model.dart';
import '../models/Resturant Model/resturant.dart';

class MenuPage extends StatefulWidget {
  final Restaurant restaurant;
  final bool showPriceTabs; // 👈 added flag

  const MenuPage({
    super.key,
    required this.restaurant,
    this.showPriceTabs = false, // default false (Flash Sale case)
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late final TextEditingController searchController;

  final menuItems = [
    RestaurantMenuModel(
      title: "Pizza Meal",
      price: 200,
      oldPrice: 200,
      rating: 3.5,
      availableQty: 10,
      description: "Chicken pizza, Large special spicy..",
      image: "assets/figmaIcons/pizzameal.png",
      foodTypes: [FoodType.nonVeg], // 👈 required
    ),
    RestaurantMenuModel(
      title: "Pizza & Pasta Family Meal",
      price: 745,
      oldPrice: 1000,
      rating: 4.5,
      availableQty: 15,
      description: "Chicken pizza, Large special spicy",
      image: "assets/figmaIcons/pasta.png",
      foodTypes: [FoodType.veg], // 👈 example multiple
    ),
    RestaurantMenuModel(
      title: "Pizza Meal",
      price: 375,
      oldPrice: 400,
      rating: 4.5,
      availableQty: 20,
      description: "Chicken pizza, Large special spicy",
      image: "assets/figmaIcons/pizzameals.png",
      foodTypes: [FoodType.halal],
    ),
    RestaurantMenuModel(
      title: "Pizza combo",
      price: 500,
      oldPrice: 800,
      rating: 4.5,
      availableQty: 20,
      description:
          "Chicken pizza, Large special spicyjkdjkxksmxksxkxoxskxkxskxjiosjsxjkxsjxksjsxksjxo",
      image: "assets/figmaIcons/pizzacombo.png",
      foodTypes: [FoodType.nonVeg, FoodType.halal], // 👈 combo type
    ),
    RestaurantMenuModel(
      title: "Pizza Meal",
      price: 200,
      oldPrice: 200,
      rating: 3.5,
      availableQty: 10,
      description: "Chicken pizza, Large special spicy..",
      image: "assets/figmaIcons/pizzameal.png",
      foodTypes: [FoodType.nonVeg], // 👈 required
    ),
    RestaurantMenuModel(
      title: "Pizza & Pasta Family Meal",
      price: 745,
      oldPrice: 1000,
      rating: 4.5,
      availableQty: 15,
      description: "Chicken pizza, Large special spicy",
      image: "assets/figmaIcons/pasta.png",
      foodTypes: [FoodType.veg], // 👈 example multiple
    ),
    RestaurantMenuModel(
      title: "Pizza Meal",
      price: 375,
      oldPrice: 400,
      rating: 4.5,
      availableQty: 20,
      description: "Chicken pizza, Large special spicy",
      image: "assets/figmaIcons/pizzameals.png",
      foodTypes: [FoodType.halal],
    ),
    RestaurantMenuModel(
      title: "Pizza combo",
      price: 500,
      oldPrice: 800,
      rating: 4.5,
      availableQty: 20,
      description:
          "Chicken pizza, Large special spicyjkdjkxksmxksxkxoxskxkxskxjiosjsxjkxsjxksjsxksjxo",
      image: "assets/figmaIcons/pizzacombo.png",
      foodTypes: [FoodType.nonVeg, FoodType.halal], // 👈 combo type
    ),
  ];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // figma background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
              // 🔹 Restaurant Header (Name, location, rating)
              SliverToBoxAdapter(
                child: ResturantMenuHeader(restaurant: widget.restaurant),
              ),
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
              // 🔹 Date & Pickup row
              SliverToBoxAdapter(child: PickupDatePickupPoint()),
           if (widget.showPriceTabs)    SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
              if (widget.showPriceTabs)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Fixed Discount Price",
                              style: Styles.textSmall(
                                context,
                                color: Colors.white,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Price Discovery",
                              style: Styles.textSmall(
                                context,
                                color: Colors.white,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
              // 🔹 Pinned Search Bar
              SliverAppBar(
                backgroundColor: Colors.white,
                floating: true,
                snap: true,
                elevation: 0,
                toolbarHeight: size.height * 0.075,
                automaticallyImplyLeading: false,
                flexibleSpace: HomeSearchBar(
                  controller: searchController,
                  onFilterTap: () {
                    // Handle filter tap
                  },
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return RestaurantMenuCard(menu: menuItems[index]);
                }, childCount: menuItems.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
