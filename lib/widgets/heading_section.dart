import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';

class HeadingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const HeadingSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
         boxShadow: [
          BoxShadow(
            color: Colors.black12, // more visible than withAlpha(10)
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColor.maincolor, width: 4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: Text(
              title,
              style: Styles.textStyleMedium(context, color: Colors.black),
              textScaler: const TextScaler.linear(1.0),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
