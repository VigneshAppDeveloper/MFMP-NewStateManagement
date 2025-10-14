import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'shimmer_type.dart';

class AppShimmer extends StatelessWidget {
  final ShimmerType type;
  final int itemCount;

  const AppShimmer({
    super.key,
    required this.type,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    switch (type) {
      case ShimmerType.restaurant:
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 16, width: size.width * 0.6, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 14, width: size.width * 0.4, color: Colors.white),
                  ],
                ),
              ),
            );
          },
        );

      case ShimmerType.category:
        return SizedBox(
          height: size.height * 0.15,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: size.height * 0.07,
                      width: size.height * 0.07,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 12, width: size.width * 0.15, color: Colors.white),
                  ],
                ),
              );
            },
          ),
        );

     case ShimmerType.menu:
  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: itemCount,
    itemBuilder: (context, index) {
      final size = MediaQuery.of(context).size;

      return Padding(
        padding: EdgeInsets.only(
          bottom: size.height * 0.015,
          left: size.width * 0.03,
          right: size.width * 0.03,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side (text placeholders)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Container(
                        height: 14,
                        width: size.width * 0.4,
                        color: Colors.white,
                      ),
                      SizedBox(height: size.height * 0.01),

                      // Price
                      Container(
                        height: 12,
                        width: size.width * 0.25,
                        color: Colors.white,
                      ),
                      SizedBox(height: size.height * 0.008),

                      // Rating + qty
                      Row(
                        children: [
                          Container(
                            height: 10,
                            width: size.width * 0.1,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 10,
                            width: size.width * 0.2,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.008),

                      // Description
                      Container(
                        height: 10,
                        width: size.width * 0.5,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right side (image placeholder + button)
                Column(
                  children: [
                    Container(
                      height: size.height * 0.13,
                      width: size.width * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 36,
                      width: size.width * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
case ShimmerType.timeslot:
  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: itemCount,
    itemBuilder: (context, index) {
      final size = MediaQuery.of(context).size;

      return Padding(
        padding: EdgeInsets.only(
          bottom: size.height * 0.012,
          left: size.width * 0.04,
          right: size.width * 0.04,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🕓 Icon placeholder
                Container(
                  height: size.width * 0.08,
                  width: size.width * 0.08,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),

                SizedBox(width: size.width * 0.03),

                // Texts placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // “Timing” chip + time row
                      Row(
                        children: [
                          Container(
                            height: size.height * 0.028,
                            width: size.width * 0.18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Container(
                            height: size.height * 0.02,
                            width: size.width * 0.25,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),

                      // Status line
                      Container(
                        height: size.height * 0.018,
                        width: size.width * 0.3,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

      case ShimmerType.banner:
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: size.height * 0.18,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
          ),
        );
    }
  }
}