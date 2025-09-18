import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/styles.dart';

class UpdatePopup extends StatelessWidget {
  final VoidCallback no;
  final VoidCallback yes;
  final String title;
  final String description;

  const UpdatePopup({
    super.key,
    required this.no,
    required this.yes,
    this.title = "Update Available",
    this.description = "A new version is available. Please update to continue.",
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        content: Container(
          height: 180,
          padding: const EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Styles.textStyleLarge(context),
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1.0),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      description,
                      style: Styles.textStyleMedium(context),
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1.0),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    _buildActionButton(
                      context,
                      'Exit',
                      Colors.red,
                      no,
                      bottomLeft: true,
                    ),
                    _buildActionButton(
                      context,
                      'Update',
                      Colors.blue,
                      yes,
                      bottomRight: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap, {
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.only(
              bottomLeft: bottomLeft ? const Radius.circular(15) : Radius.zero,
              bottomRight:
                  bottomRight ? const Radius.circular(15) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: Styles.textStyleMedium(context, color: color),
              textScaler: TextScaler.linear(1.0),
            ),
          ),
        ),
      ),
    );
  }
}
