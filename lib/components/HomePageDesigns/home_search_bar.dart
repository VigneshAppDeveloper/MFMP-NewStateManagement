import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
  });

  @override
    Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        // 🔍 Search Field
        buildSearchField(context, controller),

        const SizedBox(width: 10),

        // ✅ Filter Button with proper callback
        buildFilterButton(context, onFilterTap),
      ],
    );
  }

  /// Search input with custom UI
  Widget buildSearchField(BuildContext context, TextEditingController controller) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
        child: TextField(
          controller: controller,
          cursorColor: Colors.grey,
          style: Styles.textSmall(context),
          decoration: InputDecoration(
            hintText: "Search for Biryani",
            hintStyle: Styles.textSmall(context),
            filled: true,
            fillColor: Colors.grey.shade100,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 1,
                    height: size.height * 0.035,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.mic_none_rounded, size: 20, color: Colors.black),
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
            ),
          ),
        ),
      ),
    );
  }

  /// Filter button next to search bar
  Widget buildFilterButton(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_alt_outlined, size: 20),
            const SizedBox(width: 6),
            Text(
              "Filter",
              style: Styles.textSmall(context),
              textScaler: const TextScaler.linear(1.0),
            ),
          ],
        ),
      ),
    );
  }
}