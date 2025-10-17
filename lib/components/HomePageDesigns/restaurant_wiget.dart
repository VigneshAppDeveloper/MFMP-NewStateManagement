import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/Resturant%20Model/resturant.dart';
import 'package:my_food_my_price/util/name_formatter.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/expandable_text.dart';

import '../../widgets/app_loader.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant data;
  const RestaurantCard({super.key, required this.data});

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
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 22,
                  ),
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
                      // if (data.gstCertificate.isNotEmpty)
                      //   GestureDetector(
                      //     onTap: () => _showCertificateDialog(
                      //         context, "GST Certificate", data.gstCertificate),
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(left: 6),
                      //       child: Tooltip(
                      //         message: "GST Certificate",
                      //         child: const Icon(Icons.receipt_long,
                      //             color: Colors.orange, size: 20),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.006),

                  // ⭐ Rating
                  _iconLine(
                    context,
                    Icons.star_rate_rounded,
                    "${data.franchiseRating} Ratings",
                    leadingColor: Colors.green,
                  ),
                  SizedBox(height: size.height * 0.004),

                  // 📍 Address + Distance
                  _iconLine(
                    context,
                    Icons.location_on_outlined,
                    "${data.distanceKm.toStringAsFixed(2)} km • ${data.address}",
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
