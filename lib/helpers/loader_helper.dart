import 'package:flutter/material.dart';
import 'package:my_food_my_price/widgets/app_loader.dart';

class LoaderHelper {
  static void showFullScreenLoader(
    BuildContext context, {
    double size = 40.0,
    Color? color,
    double strokeWidth = 3.0,
    Color backgroundColor = const Color(0x80000000),
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => FullScreenLoader(
        size: size,
        color: color,
        strokeWidth: strokeWidth,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void hideLoader(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}