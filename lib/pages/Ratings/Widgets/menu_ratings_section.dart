import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_food_my_price/util/color_constant.dart';

import '../../../Providers/ratings_provider.dart';
import '../../../util/styles.dart';

class MenuRatingsSection extends StatelessWidget {
  final List<String> menuNames;
  final List<String> menuCategoryIds;
  final RatingsProvider provider;

  const MenuRatingsSection({
    super.key,
    required this.menuNames,
    required this.menuCategoryIds,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ratings",
          style: Styles.textSmall(
            context,
            color: AppColor.maincolor,
          ).copyWith(fontWeight: FontWeight.bold),
          textScaler: const TextScaler.linear(1.0),
        ),
        const SizedBox(height: 8),
        ...List.generate(menuNames.length, (index) {
          final menuName = menuNames[index];
          final id = menuCategoryIds[index];
          final rating = provider.menuRatings[id] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    menuName,
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
                RatingBar.builder(
                  initialRating: rating,
                  minRating: 0,
                  allowHalfRating: true, // ✅ enables .5 steps
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 28,
                  unratedColor: Colors.grey.shade300,
                  itemBuilder:
                      (_, __) => const Icon(Icons.star, color: Colors.orange),
                  onRatingUpdate:
                      (value) => provider.updateMenuRating(id, value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
