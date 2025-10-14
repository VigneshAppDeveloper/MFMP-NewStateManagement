import 'package:flutter/material.dart';

import '../../models/Resturant Model/resturant.dart';
import '../../util/styles.dart';


class ResturantMenuHeader extends StatelessWidget {
  final Restaurant restaurant;
  const ResturantMenuHeader({super.key,required this.restaurant});

  @override
   Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: Styles.textStyleMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
                textScaler: const TextScaler.linear(1.0),
              ),
              const SizedBox(height: 4),
              Text(
                "${restaurant.address}, ${restaurant.distanceKm}",
                style: Styles.textSmall(context, color: Colors.black54),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],
          ),
        ),
        Row(
          children: [
            
            const Icon(Icons.star, color: Colors.green, size: 16),
            
            const SizedBox(width: 4),
            Text(
              restaurant.franchiseRating.toString(),
              style: Styles.textSmall(context),
              textScaler: const TextScaler.linear(1.0),
            ),
          ],
        ),
      ],
    );
  }
}