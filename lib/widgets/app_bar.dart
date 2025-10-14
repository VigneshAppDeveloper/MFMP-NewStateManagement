import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack ;
  final VoidCallback? onBack;

  const CommonAppBar({
    super.key,
    required this.title,
    this.showBack  = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: onBack ?? () => Navigator.pop(context),
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: Styles.textStyleLarge(context, color: Colors.black),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}