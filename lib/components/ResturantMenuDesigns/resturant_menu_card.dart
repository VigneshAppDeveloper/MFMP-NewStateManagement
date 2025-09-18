import 'package:flutter/material.dart';

import '../../models/FoodModels/resturant_menu_model.dart';
import '../../util/name_formatter.dart';
import '../../util/styles.dart';
import '../../widgets/expandable_text.dart';

class RestaurantMenuCard extends StatefulWidget {
  final RestaurantMenuModel menu;
  const RestaurantMenuCard({super.key, required this.menu});

  @override
  State<RestaurantMenuCard> createState() => _RestaurantMenuCardState();
}

class _RestaurantMenuCardState extends State<RestaurantMenuCard> {
  int quantity = 0;

  String _foodTypeAsset(FoodType type) {
    switch (type) {
      case FoodType.veg:
        return "assets/figmaIcons/veg.png";
      case FoodType.nonVeg:
        return "assets/figmaIcons/non-veg.png";
      case FoodType.halal:
        return "assets/figmaIcons/halal.png";
    }
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
            color: Colors.black.withAlpha(13), // 5% opacity

            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📝 Left section: text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  NameFormatter.titleCase(widget.menu.title),
                  style: Styles.textSmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                  textScaler: const TextScaler.linear(1.0),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: size.height * 0.005),

                // Price row
                Row(
                  children: [
                    Text(
                      "₹${widget.menu.price.toStringAsFixed(1)}",
                      style: Styles.textSmall(context).copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    if (widget.menu.oldPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        "₹${widget.menu.oldPrice!.toStringAsFixed(1)}",
                        style: Styles.textSmall(context).copyWith(
                          color: Colors.black54,
                          decoration: TextDecoration.lineThrough,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      const SizedBox(width: 8),
                      // ✅ Food type icons
                      ...widget.menu.foodTypes.map(
                        (type) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Image.asset(
                            _foodTypeAsset(type),
                            height: MediaQuery.of(context).size.height * 0.025,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: size.height * 0.005),

                // Rating + Qty
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.menu.rating.toString(),
                      style: Styles.textExtraSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Available Qty : ${widget.menu.availableQty}",
                      style: Styles.textExtraSmall(
                        context,
                        color: Colors.black,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.005),

                // Description with expandable text
                ExpandableText(
                  widget.menu.description,
                  trimLines: 1,
                  style: Styles.textExtraSmall(context, color: Colors.black87),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 🍕 Right section: image + button
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  widget.menu.image,
                  height: size.height * 0.13,
                  width: size.width * 0.25,
                  fit: BoxFit.cover,
                ),
              ),

              // Button state
              Positioned(
                bottom: 5,
                child:
                    quantity == 0
                        ? GestureDetector(
                          onTap: () {
                            setState(() => quantity = 1);
                          },
                          child: Container(
                            width: size.width * 0.24,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0000),
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
                          height: size.height * (35 / 812), // responsive height
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.02,
                          ), // flexible space
                          decoration: BoxDecoration(
                            color: const Color(0xFF12B400),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                          child: IntrinsicWidth(
                            // makes width depend on children
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // shrink to fit children
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _qtyButton("-", () {
                                  if (quantity > 1) {
                                    setState(() => quantity--);
                                  } else {
                                    setState(() => quantity = 0);
                                  }
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
