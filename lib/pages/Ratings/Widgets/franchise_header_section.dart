import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';

import '../../../util/styles.dart';

class FranchiseHeaderSection extends StatelessWidget {
  final String franchiseName;
  final String location;
  final String franchiseImage;
  final double avgRating;
  final List<String> menuCategoryNames;

  const FranchiseHeaderSection({
    super.key,
    required this.franchiseName,
    required this.location,
    required this.franchiseImage,
    required this.avgRating,
    required this.menuCategoryNames,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: franchiseImage,
            width: 75,
            height: 75,
            fit: BoxFit.cover,
            placeholder: (_, __) => const Center(child: FullScreenLoader()),
            errorWidget:
                (_, __, ___) => Image.asset(
                  'assets/icons/product-1.jpg',
                  width: 75,
                  height: 75,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 2),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: Styles.textSmall(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      franchiseName,
                      style: Styles.textSmall(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                menuCategoryNames.join(", "),
                style: Styles.textSmall(context),
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1.0),
              ),
              SizedBox(height: 4),
              Text(
                location,
                style: Styles.textSmall(context, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
