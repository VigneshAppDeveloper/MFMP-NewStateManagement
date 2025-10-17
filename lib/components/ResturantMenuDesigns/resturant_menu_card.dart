import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/cart_provider.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:provider/provider.dart';

import '../../Providers/menu_provider.dart';
import '../../models/FoodModels/resturant_menu_model.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../util/name_formatter.dart';
import '../../util/styles.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/dilogue/dilogue.dart';
import '../../widgets/expandable_text.dart';

class RestaurantMenuCard extends StatefulWidget {
  final RestaurantMenuModel menu;
  final Restaurant restaurant;

  const RestaurantMenuCard({
    super.key,
    required this.menu,
    required this.restaurant,
  });

  @override
  State<RestaurantMenuCard> createState() => _RestaurantMenuCardState();
}

class _RestaurantMenuCardState extends State<RestaurantMenuCard> {
  int quantity = 0;

  List<String> _foodTypeAssets() {
    final type = widget.menu.dietType.toLowerCase();
    final halal = widget.menu.halal.toLowerCase();

    final icons = <String>[];
    if (type.contains('non-veg'))
      icons.add("assets/figmaIcons/non-veg.png");
    else if (type.contains('veg'))
      icons.add("assets/figmaIcons/veg.png");
    if (halal == 'yes') icons.add("assets/figmaIcons/halal.png");
    if (icons.isEmpty) icons.add("assets/figmaIcons/veg.png");
    return icons;
  }

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    quantity = cart.items[widget.menu] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final provider = context.read<MenuProvider>();
    final size = MediaQuery.of(context).size;
    quantity = cartProvider.items[widget.menu] ?? 0;
   final displayPrice =
    widget.menu.getDisplayPrice(fromFlashPage: provider.isFlashMode);
    final basePrice = widget.menu.basePrice;

    final maxStock = widget.menu.avaliableStocks; // ✅ available stock

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Left Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        NameFormatter.titleCase(widget.menu.menuName),
                        style: Styles.textSmall(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.linear(1.0),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children:
                          _foodTypeAssets()
                              .map(
                                (path) => Padding(
                                  padding: const EdgeInsets.only(left: 3),
                                  child: Image.asset(
                                    path,
                                    height: size.height * 0.022,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.005),
                Row(
                  children: [
                    Text(
                      "₹${displayPrice.toStringAsFixed(1)}",
                      style: Styles.textSmall(context).copyWith(
                        color: AppColor.maincolor,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "₹${basePrice.toStringAsFixed(1)}",
                      style: Styles.textSmall(context).copyWith(
                        color: Colors.black54,
                        decoration: TextDecoration.lineThrough,
                      ),
                      textScaler: TextScaler.linear(1.0),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.005),
                Row(
                  children: [
                    if (widget.menu.avgStarRating != null &&
                        widget.menu.avgStarRating! > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.green, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            widget.menu.avgStarRating!.toStringAsFixed(1),
                            style: Styles.textExtraSmall(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                            textScaler: TextScaler.linear(1.0),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    Text(
                      "Available Qty: $maxStock",
                      style: Styles.textExtraSmall(context),
                      textScaler: TextScaler.linear(1.0),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.005),
                ExpandableText(
                  widget.menu.description,
                  trimLines: 1,
                  style: Styles.textExtraSmall(context, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 🔹 Right Section — Image & Quantity Control
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.menu.menuImage,
                  height: size.height * 0.13,
                  width: size.width * 0.25,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => const Center(child: FullScreenLoader()),
                  errorWidget:
                      (_, __, ___) => Image.asset("assets/icons/product-1.jpg"),
                ),
              ),
              Positioned(
                bottom: 5,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      quantity == 0
                          ? GestureDetector(
                            key: const ValueKey('addButton'),
                            onTap: () {
                              if (maxStock <= 0) {
                                AppDialogue.toast("Out of stock");
                                return;
                              }
                              setState(() => quantity = 1);
                              cartProvider.addItem(widget.menu, 1);
                            },
                            child: Container(
                              width: size.width * 0.24,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "ADD",
                                style: Styles.textSmall(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textScaler: TextScaler.linear(1.0),
                              ),
                            ),
                          )
                          : Container(
                            key: const ValueKey('qtySelector'),
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12B400),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _qtyButton("-", () {
                                  setState(() {
                                    if (quantity > 1) {
                                      quantity--;
                                    } else {
                                      quantity = 0;
                                    }
                                    cartProvider.addItem(widget.menu, quantity);
                                  });
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    "$quantity",
                                    style: Styles.textStyleMedium(
                                      context,
                                    ).copyWith(color: Colors.white),
                                    textScaler: TextScaler.linear(1.0),
                                  ),
                                ),
                                _qtyButton("+", () {
                                  if (quantity >= maxStock) {
                                    AppDialogue.toast(
                                      "Only $maxStock items available",
                                    );
                                    return;
                                  }
                                  setState(() => quantity++);
                                  cartProvider.addItem(widget.menu, quantity);
                                }),
                              ],
                            ),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Styles.textStyleMediumBold(context),
          textScaler: TextScaler.linear(1.0),
        ),
      ),
    );
  }
}
