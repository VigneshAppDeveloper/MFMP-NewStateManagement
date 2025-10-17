import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';

import '../../../models/FoodModels/resturant_menu_model.dart';
import '../../../util/color_constant.dart';
import '../../../util/styles.dart';
import '../../../widgets/dilogue/dilogue.dart';

class FixedMenuList extends StatelessWidget {
  final List<RestaurantMenuModel> menus;
  final List<int> quantities;
  final Function(List<int>) onQuantityChange;
  final bool fromFlashPage;

  const FixedMenuList({
    super.key,
    required this.menus,
    required this.quantities,
    required this.onQuantityChange,
    required this.fromFlashPage,
  });

  void updateQuantity(BuildContext context, int index, int newValue) {
    final updated = List<int>.from(quantities);
    updated[index] = newValue;
    onQuantityChange(updated);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          menus.asMap().entries.map((entry) {
            final index = entry.key;
            final menu = entry.value;
            final qty = quantities[index];
            final price = menu.getDisplayPrice(fromFlashPage: fromFlashPage);
            final maxStock = menu.avaliableStocks;

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
                        placeholder:
                            (_, __) => const Center(child: FullScreenLoader()),
                        errorWidget:
                            (_, __, ___) =>
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
                            style: Styles.textSmall(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                            textScaler: TextScaler.linear(1.0),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "₹${price.toStringAsFixed(2)}",
                            style: Styles.textSmall(
                              context,
                              color: Colors.grey.shade700,
                            ),
                            textScaler: TextScaler.linear(1.0),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Available: $maxStock",
                            style: Styles.textSmall(
                              context,
                              color: AppColor.maincolor,
                            ),
                            textScaler: TextScaler.linear(1.0),
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              _qtySelector(context, index, qty, maxStock),
                              const Spacer(),
                              Text(
                                "₹ ${(price * qty).toStringAsFixed(2)}",
                                style: Styles.textStyleMediumBold(
                                  context,
                                  color: Colors.green,
                                ),
                                textScaler: TextScaler.linear(1.0),
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

  Widget _qtySelector(
    BuildContext context,
    int index,
    int quantity,
    int maxStock,
  ) {
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
          _qtyButton(context, "-", () {
            if (quantity > 0) {
              updateQuantity(context, index, quantity - 1);
            }
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "$quantity",
              style: Styles.textStyleMedium(context, color: Colors.white),
              textScaler: TextScaler.linear(1.0),
            ),
          ),
          _qtyButton(context, "+", () {
            if (quantity >= maxStock) {
              AppDialogue.toast("Only $maxStock items available");
              return;
            }
            updateQuantity(context, index, quantity + 1);
          }),
        ],
      ),
    );
  }

  Widget _qtyButton(BuildContext context, String label, VoidCallback onTap) {
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
