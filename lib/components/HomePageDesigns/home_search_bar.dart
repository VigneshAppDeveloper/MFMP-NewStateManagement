import 'package:flutter/material.dart';
import 'package:my_food_my_price/pages/app_pages.dart';
import 'package:my_food_my_price/util/styles.dart';


class HomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChanged;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.onChanged,
  });

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

  void _handleTextChange() {
    if (!mounted) return;
    setState(() {}); // toggle clear icon dynamically
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              cursorColor: Colors.grey,
              style: Styles.textSmall(context),

              // ✅ Search logic now comes from parent page
              onChanged: widget.onChanged,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),

              onTap: () {
                _focusNode.requestFocus();

                // ✅ animate bottom bar (optional UX)
                Future.microtask(() {
                  final parent =
                      context.findAncestorStateOfType<AppPagesState>();
                  if (parent != null && parent.mounted) {
                    parent.bottomBarController.forward();
                  }
                });
              },

              onEditingComplete: () {
                Future.microtask(() {
                  final parent =
                      context.findAncestorStateOfType<AppPagesState>();
                  if (parent != null && parent.mounted) {
                    parent.bottomBarController.reverse();
                  }
                });
              },

              decoration: InputDecoration(
                hintText: "Search for Biryani",
                hintStyle: Styles.textSmall(context),
                filled: true,
                fillColor: Colors.grey.shade100,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),

                // ✅ Show clear or search icon
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          widget.controller.clear();
                          FocusScope.of(context).unfocus();
                          widget.onChanged(""); // ✅ clear search in parent
                        },
                      )
                    : const Icon(Icons.search,
                        size: 20, color: Colors.black),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade100, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade100, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
