import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';

import '../../../models/BidderModels/winner_model.dart';
import '../../../util/styles.dart';

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
    quantities = List.from(widget.quantities); // default qty = 1
  }

  void updateQuantity(int index, int newValue) {
    setState(() => quantities[index] = newValue);
    widget.onQuantityChange(quantities); // ✅ Push updated list upward
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Responsive scroll-safe layout
        ...widget.winners.asMap().entries.map((entry) {
           final index = entry.key;
          final item = entry.value;
          final quantity = quantities[index];
          final price = double.tryParse(item.finalPrice) ?? 0.0;

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
                  // ✅ Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: item.menuImage,
                      height: size.height * 0.1,
                      width: size.height * 0.1,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            height: size.height * 0.1,
                            width: size.height * 0.1,
                            alignment: Alignment.center,
                            child: FullScreenLoader(),
                          ),
                      errorWidget:
                          (_, __, ___) =>
                              const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),

                  SizedBox(width: size.width * 0.04),

                  // ✅ Text + Quantity + Price section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🏷️ Menu Name
                        Text(
                          item.menuName,
                          style: Styles.textStyleMediumBold(context),
                          textScaler: const TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: size.height * 0.004),

                        // 💰 Base Price + Availability
                        Row(
                          children: [
                            Text(
                           "₹${price.toStringAsFixed(2)}",
                              style: Styles.textStyleMedium(
                                context,
                                color: Colors.grey.shade700,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              "Available Qty : 10",
                              style: Styles.textStyleMedium(
                                context,
                                color: Colors.red,
                              ),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.008),

                        // 🔘 Quantity control & total price
                        // 🔘 Quantity control & total price (updated)
                        Row(
                          children: [
                            // ✅ Green rounded quantity selector
                            Container(
                              key: const ValueKey('qtySelector'),
                              height: 42,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF12B400),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _qtyButton("-", () {
                                    setState(() {
                                    if (quantity > 0) {
                                      updateQuantity(index, quantity - 1);
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
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ),
                                 _qtyButton("+",
                                      () => updateQuantity(index, quantity + 1)),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // ✅ Total amount (aligned to right)
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
        }),
      ],
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
