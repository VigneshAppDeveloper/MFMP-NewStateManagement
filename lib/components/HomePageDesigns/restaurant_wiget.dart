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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSide = size.width * 0.28; // responsive square

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: data.image,
              height: imageSide,
              width: imageSide,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(child: FullScreenLoader()),
              errorWidget:
                  (_, __, ___) => Image.asset("assets/icons/product-1.jpg"),
            ),
          ),
          // Image
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(14),
          //   child: Image.network(
          //     data.image,
          //     width: imageSide,
          //     height: imageSide,
          //     fit: BoxFit.cover,
          //   ),
          // ),
          SizedBox(width: size.width * 0.04),

          // Texts
          Expanded(
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  ExpandableText(
                    data.name.titleCase,
                    style: Styles.textStyleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                    trimLines: 1, // show only 1 line before expanding
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  SizedBox(height: size.height * 0.006),

                  // Rating
                  _iconLine(
                    context,
                    Icons.star_rate_rounded,
                    "${data.franchiseRating} Ratings",
                    leadingColor: Colors.green,
                  ),
                  SizedBox(height: size.height * 0.004),

                  // Area + distance
                  _iconLine(
                    context,
                    Icons.location_on_outlined,

                    " ${data.distanceKm} ${data.address}",
                  ),
                  SizedBox(height: size.height * 0.004),

                  // // Cuisines
                  _iconLine(
                    context,
                    Icons.ramen_dining_outlined,
                    //data.cuisines.titleCase,
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
