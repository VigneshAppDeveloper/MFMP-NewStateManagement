import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';

class MessageToRestaurant extends StatefulWidget {
  final TextEditingController controller;
  const MessageToRestaurant({super.key, required this.controller});

  @override
  State<MessageToRestaurant> createState() => _MessageToRestaurantState();
}

class _MessageToRestaurantState extends State<MessageToRestaurant> {
  bool _showField = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Message to Restaurant",
                      style: Styles.textStyleMediumBold(context),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      "Restaurant will try their best to comply.",
                      style: Styles.textExtraSmall(
                        context,
                      ).copyWith(color: Colors.black54),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showField = !_showField),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(
                    _showField
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                !_showField
                    ? const SizedBox.shrink()
                    : TextFormField(
                      key: const ValueKey("messageField"),
                      controller: widget.controller,
                      cursorColor: Colors.grey,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Write your food preferences or special requests…",
                        hintStyle: Styles.textExtraSmall(
                          context,
                        ).copyWith(color: Colors.grey.shade500),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.035,
                          vertical: size.height * 0.015,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 0.8,
                          ),
                        ),
                      ),
                      style: Styles.textExtraSmall(context),
                      
                    ),
          ),
        ],
      ),
    );
  }
}
