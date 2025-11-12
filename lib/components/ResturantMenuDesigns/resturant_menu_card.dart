import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/cart_provider.dart';
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
import 'pickup_date_pickup_point.dart';

class RestaurantMenuCard extends StatefulWidget {
  final RestaurantMenuModel menu;
  final Restaurant restaurant;
  final GlobalKey<PickupDatePickupPointState>? pickupKey;

  const RestaurantMenuCard({
    super.key,
    required this.menu,
    required this.restaurant,
    this.pickupKey,
  });

  @override
  State<RestaurantMenuCard> createState() => _RestaurantMenuCardState();
}

class _RestaurantMenuCardState extends State<RestaurantMenuCard> {
  int quantity = 0;
  Timer? _flashTimer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  List<String> _foodTypeAssets() {
    final type = widget.menu.dietType.toLowerCase();
    final halal = widget.menu.halal.toLowerCase();

    final icons = <String>[];
    if (type.contains('non-veg')) {
      icons.add("assets/figmaIcons/non-veg.png");
    } else if (type.contains('veg')) {
      icons.add("assets/figmaIcons/veg.png");
    }
    if (halal == 'yes') icons.add("assets/figmaIcons/halal.png");
    if (icons.isEmpty) icons.add("assets/figmaIcons/veg.png");
    return icons;
  }

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    quantity = cart.items[widget.menu] ?? 0;

    // ✅ Initialize timer for flash sale
    if (widget.menu.flashEnd != null) {
      _updateRemaining();
      _flashTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining();
      });
    }
  }

  void _updateRemaining() {
    if (!mounted) return;
    final provider = context.read<MenuProvider>();
    if (!provider.isFlashMode) return; // ✅ Skip countdown if not flash page

    final now = DateTime.now();
    final end = widget.menu.flashEnd!;
    final diff = end.difference(now);

    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
      _isExpired = diff.isNegative;
    });

    if (diff.isNegative) {
      _flashTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final provider = context.read<MenuProvider>();
    final bool isFlashPage = provider.isFlashMode;

    final size = MediaQuery.of(context).size;
    quantity = cartProvider.items[widget.menu] ?? 0;

    final displayPrice = widget.menu.getDisplayPrice(
      fromFlashPage: provider.isFlashMode,
    );
    final basePrice = widget.menu.basePrice;
    final maxStock =
        isFlashPage ? widget.menu.flashStock : widget.menu.avaliableStocks;
    final isOutOfStock = maxStock <= 0;

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
      child: Stack(
        children: [
          Row(
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
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.005),
                    if (isFlashPage)
                      Row(
                        children: [
                          Text(
                            "₹${displayPrice.toStringAsFixed(1)}",
                            style: Styles.textSmall(context).copyWith(
                              color: AppColor.maincolor,
                              fontWeight: FontWeight.bold,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "₹${basePrice.toStringAsFixed(1)}",
                            style: Styles.textSmall(context).copyWith(
                              color: Colors.black54,
                              decoration: TextDecoration.lineThrough,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          SizedBox(width: size.width * 0.025),
                          if (widget.menu.flashEnd != null)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.004,
                                  horizontal: size.width * 0.025,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        _isExpired ? Colors.red : Colors.green,
                                    width: 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _isExpired
                                        ? "Offer Ended"
                                        : "Ends in : ${_twoDigits(_remaining.inHours)}:"
                                            "${_twoDigits(_remaining.inMinutes.remainder(60))}:"
                                            "${_twoDigits(_remaining.inSeconds.remainder(60))}",
                                    style: Styles.textExtraSmall(
                                      context,
                                    ).copyWith(
                                      color:
                                          _isExpired
                                              ? Colors.red
                                              : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textScaler: const TextScaler.linear(1.0),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    Row(
                      children: [
                        if (widget.menu.avgStarRating != null &&
                            widget.menu.avgStarRating! > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${widget.menu.avgStarRating!.toStringAsFixed(1)} Ratings",
                                style: Styles.textExtraSmall(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w600),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            ],
                          ),
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

                    // 💰 Pricing
                    if (!isFlashPage)
                      Row(
                        children: [
                          Text(
                            "₹${basePrice.toStringAsFixed(1)}",
                            style: Styles.textSmall(context).copyWith(
                              color: Colors.black54,
                              decoration: TextDecoration.lineThrough,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Original Price",
                            style: Styles.textExtraSmall(
                              context,
                            ).copyWith(color: Colors.black54),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ],
                      ),

                    if (!isFlashPage) SizedBox(height: size.height * 0.005),
                    if (!isFlashPage)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.006,
                          horizontal: size.width * 0.03,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Our Rate : ₹ ${displayPrice.toStringAsFixed(1)}",
                            style: Styles.textExtraSmall(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ),

                    if (!isFlashPage) SizedBox(height: size.height * 0.005),
                    if (!isFlashPage && widget.menu.popDelvApps > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.006,
                          horizontal: size.width * 0.03,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Popular Delivery Apps ₹${widget.menu.popDelvApps.toStringAsFixed(1)}",
                            style: Styles.textExtraSmall(context).copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ),

                    SizedBox(height: size.height * 0.005),
                    Text(
                      isFlashPage
                          ? "Flash Stock: $maxStock"
                          : "Available Qty: $maxStock",
                      style: Styles.textExtraSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    SizedBox(height: size.height * 0.005),
                    ExpandableText(
                      widget.menu.description,
                      trimLines: 1,
                      style: Styles.textExtraSmall(
                        context,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // 🔹 Right Section
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColorFiltered(
                      colorFilter:
                          isOutOfStock
                              ? ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
                                BlendMode.srcATop,
                              )
                              : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.srcATop,
                              ),
                      child: CachedNetworkImage(
                        imageUrl: widget.menu.menuImage,
                        height: size.height * 0.13,
                        width: size.width * 0.25,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => const Center(child: FullScreenLoader()),
                        errorWidget:
                            (_, __, ___) =>
                                Image.asset("assets/icons/product-1.jpg"),
                      ),
                    ),
                  ),
                  if (!isOutOfStock)
                    Positioned(
                      bottom: 5,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            quantity == 0
                                ? GestureDetector(
                                  key: const ValueKey('addButton'),
                                  onTap: () {
                                    if (_isExpired && isFlashPage) {
                                      AppDialogue.toast("Offer has ended");
                                      return;
                                    }
                                    if (!isFlashPage &&
                                        provider.selectedPickupDate == null) {
                                      final pickupWidgetState =
                                          widget.pickupKey?.currentState;
                                      if (pickupWidgetState != null) {
                                        pickupWidgetState.showCalendar(
                                          context,
                                        ); // ✅ open calendar directly
                                      } else {
                                        AppDialogue.toast(
                                          "Please select your pickup date.",
                                        );
                                      }
                                      return;
                                    }
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
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ),
                                )
                                : Container(
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
                                          if (quantity > 1) {
                                            quantity--;
                                          } else {
                                            quantity = 0;
                                          }
                                          cartProvider.addItem(
                                            widget.menu,
                                            quantity,
                                          );
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
                                          textScaler: const TextScaler.linear(
                                            1.0,
                                          ),
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
                                        cartProvider.addItem(
                                          widget.menu,
                                          quantity,
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: size.width * 0.25,
                        height: size.height * 0.13,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "OUT OF STOCK",
                          style: Styles.textSmall(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 🔹 Blur when offer expired
          if (isFlashPage && _isExpired)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    alignment: Alignment.center,
                    child: Text(
                      "FLASH SALE ENDED",
                      style: Styles.textSmall(context).copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ),
              ),
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
          textScaler: const TextScaler.linear(1.0),
        ),
      ),
    );
  }
}
