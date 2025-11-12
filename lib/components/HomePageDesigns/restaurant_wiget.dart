import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/Resturant%20Model/resturant.dart';
import 'package:my_food_my_price/util/name_formatter.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/expandable_text.dart';

import '../../util/color_constant.dart';
import '../../widgets/app_loader.dart';

class RestaurantCard extends StatefulWidget {
  final Restaurant data;
  const RestaurantCard({super.key, required this.data});
  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}


class _RestaurantCardState extends State<RestaurantCard> {
  List<String> _foodTypeAssets() {
    final icons = <String>[];
    final isVeg = (widget.data.pureVeg ?? '').toLowerCase() == 'yes';
    final isNonVeg = (widget.data.pureVeg ?? '').toLowerCase() == 'no';
    final isHalal = (widget.data.halal ?? 0) == 1;
    if (isVeg)
      icons.add("assets/figmaIcons/veg.png");
    else if (isNonVeg)
      icons.add("assets/figmaIcons/non-veg.png");
    if (isHalal) icons.add("assets/figmaIcons/halal.png");
    if (icons.isEmpty) icons.add("assets/figmaIcons/veg.png");
    return icons;
  }

Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _startTimerIfFlash();
  }

  void _startTimerIfFlash() {
    if (widget.data.flashMenuTiming == null) return;

    final endTime = DateTime.tryParse(widget.data.flashMenuTiming!.flashEnd);
    if (endTime == null) return;

    _updateRemaining(endTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateRemaining(endTime);
    });
  }

  void _updateRemaining(DateTime end) {
    final now = DateTime.now();
    final diff = end.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
      _expired = diff.isNegative;
    });
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
  
void _showCertificateDialog(
  BuildContext context,
  String title,
  String imageUrl,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      final size = MediaQuery.of(context).size;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: size.width * 0.9,
                    fit: BoxFit.contain,
                    placeholder:
                        (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black87, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final size = MediaQuery.of(context).size;
    final imageSide = size.width * 0.28;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(18), blurRadius: 22),
        ],
      ),
      padding: EdgeInsets.all(size.width * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Franchise Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: data.image,
                  height: imageSide,
                  width: imageSide,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(child: FullScreenLoader()),
                  errorWidget:
                      (_, __, ___) => Image.asset(
                        "assets/icons/product-1.jpg",
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              if (data.flashMenuTiming != null)
                Positioned(
                  top: 0,
                  left: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColor.maincolor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _expired
                            ? "Offer Ended"
                            : "Ends in ${_twoDigits(_remaining.inHours)}:"
                                "${_twoDigits(_remaining.inMinutes.remainder(60))}:"
                                "${_twoDigits(_remaining.inSeconds.remainder(60))}",
                        style: Styles.textExtraSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: size.width * 0.04),

          // 🧾 Details
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Name + Certificates
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          data.name.titleCase,
                          style: Styles.textStyleMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                      if (data.fssaiCertificate.isNotEmpty)
                        GestureDetector(
                          onTap:
                              () => _showCertificateDialog(
                                context,
                                "FSSAI Certificate",
                                data.fssaiCertificate,
                              ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Tooltip(
                              message: "FSSAI Certificate",
                              child: Image.asset(
                                "assets/figmaIcons/fssi.jpeg",
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.006),

                  // ⭐ Rating + Food Type Icons in same row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rate_rounded,
                        color: Colors.green,
                        size: size.width * 0.045,
                      ),
                      SizedBox(width: size.width * 0.01),
                      Text(
                        "${data.franchiseRating} Ratings",
                        style: Styles.textSmall(context, color: Colors.black87),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      //  const Spacer(),
                      // ✅ Safe bounded food type icons
                      SizedBox(
                        height: size.height * 0.028,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:
                              _foodTypeAssets()
                                  .map(
                                    (path) => Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Image.asset(
                                        path,
                                        height: size.height * 0.022,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.004),

                  // 📍 Address + Distance
                  _iconLine(
                    context,
                    Icons.location_on_outlined,
                    "${(data.distanceKm ?? 0).toStringAsFixed(2)} km • ${data.address}",
                  ),
                  SizedBox(height: size.height * 0.004),

                  // 🍽 Description
                  _iconLine(
                    context,
                    Icons.ramen_dining_outlined,
                    data.description.titleCase,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconLine(
    BuildContext context,
    IconData icon,
    String text, {
    Color leadingColor = Colors.black54,
    int maxLines = 2,
  }) {
    final size = MediaQuery.of(context).size;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: size.width * 0.045, color: leadingColor),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: ExpandableText(
            text.titleCase,
            style: Styles.textSmall(context, color: Colors.black87),
            textScaler: const TextScaler.linear(1.0),
          ),
        ),
      ],
    );
  }
}
