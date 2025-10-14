import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';

import '../../../models/FoodModels/resturant_menu_model.dart';
import '../../../util/styles.dart';
import '../../../widgets/dilogue/dilogue.dart';

class FixedMenuList extends StatefulWidget {
  final List<RestaurantMenuModel> menus;
  final List<int> quantities;
  final Function(List<int>) onQuantityChange;

  const FixedMenuList({
    super.key,
    required this.menus,
    required this.quantities,
    required this.onQuantityChange,
  });

  @override
  State<FixedMenuList> createState() => _FixedMenuListState();
}

class _FixedMenuListState extends State<FixedMenuList> {
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    quantities = List.from(widget.quantities);
  }

  void updateQuantity(int index, int newValue) {
    setState(() => quantities[index] = newValue);
    widget.onQuantityChange(List.from(quantities)); // keep sync with parent
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.menus.asMap().entries.map((entry) {
        final index = entry.key;
        final menu = entry.value;
        final qty = quantities[index];
        final price = menu.currentPrice;
        final maxStock = menu.menuStock; // ✅ available stock

        return Container(
          margin: EdgeInsets.only(bottom: size.height * 0.012),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.03),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: menu.menuImage,
                    height: size.height * 0.1,
                    width: size.height * 0.1,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Center(child: FullScreenLoader()),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
                SizedBox(width: size.width * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.menuName,
                        style: Styles.textStyleMediumBold(context),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${price.toStringAsFixed(2)}",
                        style: Styles.textStyleMedium(
                          context,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Available: $maxStock",
                        style: Styles.textExtraSmall(context,
                            color: Colors.black54),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          _qtySelector(index, qty, maxStock),
                          const Spacer(),
                          Text(
                            "₹ ${(price * qty).toStringAsFixed(2)}",
                            style: Styles.textStyleMediumBold(
                              context,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _qtySelector(int index, int quantity, int maxStock) {
    return Container(
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
            if (quantity > 0) {
              updateQuantity(index, quantity - 1);
            }
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "$quantity",
              style: Styles.textStyleMedium(context, color: Colors.white),
            ),
          ),
          _qtyButton("+", () {
            if (quantity >= maxStock) {
              AppDialogue.toast("Only $maxStock items available");
              return;
            }
            updateQuantity(index, quantity + 1);
          }),
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
