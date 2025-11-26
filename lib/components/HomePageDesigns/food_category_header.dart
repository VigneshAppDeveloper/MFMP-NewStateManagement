import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';

class FoodCategoryHeader extends StatelessWidget {
  const FoodCategoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "What's your favorite?",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: const TextScaler.linear(1.0),
          style: Styles.textStyleMedium(context),
        ),
        SizedBox(width: 5),
        Expanded(child: Divider()),
        // Text(
        //   "All",
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        //   textScaler: const TextScaler.linear(1.0),
        //   style: Styles.textSmall(context),
        // ),
      ],
    );
  }
}
