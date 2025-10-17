import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';
import 'package:provider/provider.dart';

import '../../../Providers/menu_provider.dart';
import '../../../models/BidderModels/winner_model.dart';
import '../../../util/color_constant.dart';
import '../../../util/styles.dart';
import '../../../widgets/dilogue/dilogue.dart';

class WinnerMenuList extends StatefulWidget {
  final List<WinnerModel> winners;
  final List<int> quantities;
  final Function(List<int>) onQuantityChange;

  const WinnerMenuList({
    super.key,
    required this.winners,
    required this.quantities,
    required this.onQuantityChange,
  });

  @override
  State<WinnerMenuList> createState() => _WinnerMenuListState();
}

class _WinnerMenuListState extends State<WinnerMenuList> {
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    quantities = List.from(widget.quantities);
  }

  void updateQuantity(int index, int newValue) {
    setState(() => quantities[index] = newValue);
    widget.onQuantityChange(List.from(quantities)); // sync upward
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final menuProvider = context.watch<MenuProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.winners.asMap().entries.map((entry) {
        final index = entry.key;
        final winner = entry.value;
        final quantity = quantities[index];
        final price = double.tryParse(winner.finalPrice) ?? 0.0;

        // 🔹 Find matching menu from provider to get live stock
        final matchingMenu = menuProvider.menus
            .where((m) => m.id.toString() == winner.menuId)
            .toList();

        if (matchingMenu.isEmpty) return const SizedBox.shrink();
        final menu = matchingMenu.first;

        // ✅ Always take live stock from provider
        final int maxStock = menu.avaliableStocks > 0 ? menu.avaliableStocks : 0;

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
                // 🖼️ Menu Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: winner.menuImage,
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

                // 📝 Menu Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        winner.menuName,
                        style: Styles.textStyleMediumBold(context),
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "₹${price.toStringAsFixed(2)}",
                        style: Styles.textStyleMedium(
                          context,
                          color: Colors.grey.shade700,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Available: $maxStock",
                        style: Styles.textSmall(
                          context,
                          color: AppColor.maincolor,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      SizedBox(height: 6),

                      // 🔹 Quantity Selector + Total
                      Row(
                        children: [
                          Container(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    "$quantity",
                                    style: Styles.textStyleMedium(
                                      context,
                                      color: Colors.white,
                                    ),
                                    textScaler:
                                        const TextScaler.linear(1.0),
                                  ),
                                ),
                                _qtyButton("+", () {
                                  if (quantity >= maxStock) {
                                    AppDialogue.toast(
                                        "Only $maxStock items available");
                                    return;
                                  }
                                  updateQuantity(index, quantity + 1);
                                }),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "₹ ${(price * quantity).toStringAsFixed(2)}",
                            style: Styles.textStyleMediumBold(
                              context,
                              color: Colors.green,
                            ),
                            textScaler: const TextScaler.linear(1.0),
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
          textScaler: const TextScaler.linear(1.0),
        ),
      ),
    );
  }
}
