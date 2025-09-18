import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FullScreenShimmer extends StatelessWidget {
  const FullScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: size.height * 0.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.grey.shade300,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(18),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 16,
                  width: size.width * 0.6,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(
                  height: 14,
                  width: size.width * 0.4,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
