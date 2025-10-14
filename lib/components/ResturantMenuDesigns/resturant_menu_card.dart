import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/FoodModels/resturant_menu_model.dart';
import '../../util/name_formatter.dart';
import '../../util/styles.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/expandable_text.dart';

class RestaurantMenuCard extends StatefulWidget {
  final RestaurantMenuModel menu;
  const RestaurantMenuCard({super.key, required this.menu});

  @override
  State<RestaurantMenuCard> createState() => _RestaurantMenuCardState();
}

class _RestaurantMenuCardState extends State<RestaurantMenuCard> {
  int quantity = 0;

  String _foodTypeAsset() {
    final type = widget.menu.dietType.toLowerCase();
    final halal = widget.menu.halal.toLowerCase();

    if (type.contains('non-veg')) {
      return "assets/figmaIcons/non-veg.png";
    } else if (type.contains('veg')) {
      return "assets/figmaIcons/veg.png";
    } else if (halal == 'yes') {
      return "assets/figmaIcons/halal.png";
    }
    return "assets/figmaIcons/veg.png"; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          // 🔹 Left section — details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        NameFormatter.titleCase(widget.menu.menuName),
                        style: Styles.textSmall(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(
                      "assets/figmaIcons/halal.png",
                      height: size.height * 0.025,
                    ),
                    const SizedBox(width: 2),
                    Image.asset(_foodTypeAsset(), height: size.height * 0.022),
                  ],
                ),
                SizedBox(height: size.height * 0.005),

                // Price row
                Row(
                  children: [
                    Text(
                      "₹${widget.menu.currentPrice.toStringAsFixed(1)}",
                      style: Styles.textSmall(context).copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "₹${widget.menu.basePrice.toStringAsFixed(1)}",
                      style: Styles.textSmall(context).copyWith(
                        color: Colors.black54,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.005),

                // Rating + Available qty placeholder
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "3.5 Ratings", // static for now (can add from backend)
                      style: Styles.textExtraSmall(context),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Available Qty : ${widget.menu.menuStock ?? '—'}",
                      style: Styles.textExtraSmall(context),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.005),

                // Description
                ExpandableText(
                  widget.menu.description,
                  trimLines: 1,

                  style: Styles.textExtraSmall(context, color: Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 🔹 Right section — image & button
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
                // Image.network(
                //   widget.menu.menuImage,
                //   height: size.height * 0.13,
                //   width: size.width * 0.25,
                //   fit: BoxFit.cover,
                //   errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50),
                // ),
              ),
              Positioned(
                bottom: 5,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      quantity == 0
                          ? GestureDetector(
                            key: const ValueKey('addButton'),
                            onTap: () => setState(() => quantity = 1),
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
                                  ),
                                ),
                                _qtyButton("+", () {
                                  setState(() => quantity++);
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
        child: Text(label, style: Styles.textStyleMediumBold(context)),
      ),
    );
  }
}
