import 'package:flutter/material.dart';
import 'package:my_food_my_price/models/FoodModels/food_model.dart';
import 'package:my_food_my_price/util/styles.dart';


class FoodCategoryGrid extends StatelessWidget {
  final List<FoodCategory> categories;

  const FoodCategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    height: size.width * 0.18,
                    width: size.width * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(item.image, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

