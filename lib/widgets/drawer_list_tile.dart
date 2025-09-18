import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';

class DrawerListTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;

  const DrawerListTile({
    super.key,
    this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.maincolor.withAlpha(20),
                ),
                child: Icon(icon, color: AppColor.maincolor, size: 20),
              ),
            if (icon != null) const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Styles.textSmall(context),
                overflow: TextOverflow.ellipsis,
                textScaler: const TextScaler.linear(1.0),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  

  
}
