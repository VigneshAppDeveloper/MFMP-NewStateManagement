import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';

import '../../route_generator.dart';

import 'package:flutter/material.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.onChanged,
    this.enableNavigation = true,
    this.isFlash = false, // default: used on Home/Flash page
    this.hintText = "Search for Biryani",
    
  });

  final TextEditingController controller;
  final bool enableNavigation; // 👈 added flag
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool isFlash;
  final String hintText;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (!mounted) return;
    setState(() {}); // rebuild to show/hide clear icon
  }

  // ✅ reusable TextField builder with your original design
  Widget _buildTextField(
    BuildContext context, {
    required bool readOnly,
    required bool showClearIcon,
  }) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.search,
        cursorColor: Colors.grey,
        style: Styles.textSmall(context),
        readOnly: readOnly,
        onChanged: readOnly ? null : widget.onChanged,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          hintText:  widget.hintText,
          hintStyle: Styles.textSmall(context),
          filled: true,
          fillColor: Colors.grey.shade100,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          suffixIcon:
              showClearIcon && widget.controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      widget.controller.clear();
                      FocusScope.of(context).unfocus();
                      widget.onChanged("");
                    },
                  )
                  : const Icon(Icons.search, size: 20, color: Colors.black),
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
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, VoidCallback onTap) {
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child:
              widget.enableNavigation
                  ? GestureDetector(
                    onTap: () {
                      AppRouteName.restaurantSearchPage.push(
                        context,
                        args: {'isFlash': widget.isFlash},
                      );
                    },
                    child: AbsorbPointer(
                      child: _buildTextField(
                        context,
                        readOnly: true,
                        showClearIcon: false,
                      ),
                    ),
                  )
                  : _buildTextField(
                    context,
                    readOnly: false,
                    showClearIcon: true,
                  ),
        ),
        const SizedBox(width: 10),
        _buildFilterButton(context, widget.onFilterTap),
      ],
    );
  }
}
