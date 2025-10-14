import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';

import '../../models/FoodModels/resturant_menu_model.dart';
import '../../util/color_constant.dart';
import '../../widgets/expandable_text.dart';

class RestaurantBiddingCard extends StatefulWidget {
  final RestaurantMenuModel menu;
  final double currentBid;
  final String highestBidder;
  final bool priceExceeded;
  final bool isFrozen;
  final Function(double) onBid;
  final bool isLiveUpdating;

  const RestaurantBiddingCard({
    super.key,
    required this.menu,
    required this.currentBid,
    required this.highestBidder,
    required this.priceExceeded,
    required this.isFrozen,
    required this.onBid,
    this.isLiveUpdating = false,
  });

  @override
  State<RestaurantBiddingCard> createState() => _RestaurantBiddingCardState();
}

class _RestaurantBiddingCardState extends State<RestaurantBiddingCard> {
  bool showFullDesc = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.menu;
    final size = MediaQuery.of(context).size;
    final h = size.height;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          // 🔹 Header (Image + Name + Rating)
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: m.menuImage,
                    height: h / 10,
                    width: h / 10,
                    fit: BoxFit.cover,
                    placeholder:
                        (_, __) => const Center(child: FullScreenLoader()),
                    errorWidget:
                        (_, __, ___) =>
                            Image.asset("assets/icons/product-1.jpg"),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.menuName,
                        style: Styles.textStyleMediumBold(context),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.green, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "3.5 Ratings", // static rating
                            style: Styles.textExtraSmall(context),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ExpandableText(
                        m.description,
                        trimLines: 1,
                        style: Styles.textExtraSmall(
                          context,
                          color: Colors.black87,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 🔹 Price box (Original + Current)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFFF1F0F0),
              ),
              child: Row(
                children: [
                  _priceBox(
                    context,
                    "Original Price",
                    "₹${m.basePrice.toStringAsFixed(2)}",
                    Colors.black,
                  ),
                  Container(width: 1, height: 80, color: Colors.grey),
                  _priceBox(
                    context,
                    "Current Price",
                    "₹${widget.currentBid.toStringAsFixed(2)}",
                    AppColor.maincolor,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Last Bidder Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Colors.black54, size: 24),
              const SizedBox(width: 8),

              // 🔹 If this menu’s price is NOT exceeded
              if (!widget.priceExceeded) ...[
                if (!widget.isLiveUpdating)
                  Flexible(
                    child: Text(
                      widget.highestBidder.isEmpty
                          ? "No Bidders Yet"
                          : widget.highestBidder,
                      textAlign: TextAlign.center,
                      style: Styles.textStyleMedium(context),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                else
                  const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColor.maincolor,
                      ),
                    ),
                  ),
              ] else ...[
                // 🔸 For capped menu — no loader, show static bidder
                Flexible(
                  child: Text(
                    widget.highestBidder.isEmpty
                        ? "Max Limit Reached"
                        : widget.highestBidder,
                    textAlign: TextAlign.center,
                    style: Styles.textStyleMedium(
                      context,
                    ).copyWith(color: Colors.red.shade700),
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade400, thickness: 0.6),

          // 🔸 Warning if exceeded
          if (widget.priceExceeded)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "⚠️ Maximum Rate Reached. Please wait for end of TimeSlot.",
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0),
                style: Styles.textStyleMedium(
                  context,
                  color: Colors.red.shade600,
                ),
              ),
            ),

          // 🔹 Bid Now header
          if (!widget.priceExceeded) ...[
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey)),
                Text(
                  "  BID NOW  ",
                  style: Styles.textStyleMedium(
                    context,
                    color: AppColor.maincolor,
                  ),
                  textScaler: const TextScaler.linear(1.0),
                ),
                Expanded(child: Divider(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),

            // 🔹 Bid Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  [10, 20, 30].map((v) {
                    final newBid = widget.currentBid + v;
                    return ElevatedButton(
                      onPressed:
                          widget.isFrozen ? null : () => widget.onBid(newBid),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.isFrozen
                                ? Colors.grey
                                : const Color(0xFF05B90B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "+₹$v",
                        style: Styles.textSmall(context, color: Colors.white),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    );
                  }).toList(),
            ),
          ],

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _priceBox(
    BuildContext context,
    String label,
    String price,
    Color color,
  ) {
    final bool showLoader =
        widget.isLiveUpdating &&
        label == "Current Price" &&
        !widget.priceExceeded; // ✅ no loader if capped

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            label,
            style: Styles.textStyleMediumBold(context, color: Colors.black),
            textScaler: const TextScaler.linear(1.0),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🔹 Smooth transition: price hides when loader shows
              if (!showLoader)
                Flexible(
                  child: Text(
                    price,
                    textAlign: TextAlign.center,
                    style: Styles.textStyleMediumBold(context, color: color),
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.maincolor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
