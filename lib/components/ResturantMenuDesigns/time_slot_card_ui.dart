import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/Providers/menu_provider.dart';
import 'package:provider/provider.dart';

import '../../models/BidderModels/time_slot_model.dart';
import '../../util/styles.dart';



class TimeSlotCard extends StatelessWidget {
  final TimeSlotModel slot;
  final VoidCallback? onTap;

  const TimeSlotCard({
    super.key,
    required this.slot,
    this.onTap,
  });

  Color _backgroundColor() {
    if (slot.isActive) return const Color(0xFF12B400); // Green
    if (slot.isUpcoming) return const Color(0xFFF27405); // Orange
    return Colors.grey.shade400; // Completed
  }

  String _statusText() {
    if (slot.isActive) return "Active";
    if (slot.isUpcoming) return "Upcoming";
    return "Bidding Completed";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final start = (slot.formattedStart);
    final end = (slot.formattedEnd);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.012),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🕓 Icon
            Image.asset(
              "assets/icons/chronometer.png",
              width: size.width * 0.08,
              height: size.width * 0.08,
              color: Colors.white,
              fit: BoxFit.contain,
            ),

            SizedBox(width: size.width * 0.03),

            // 🕒 Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with “Timing” chip + time
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.025,
                          vertical: size.height * 0.004,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Timing",
                          style: Styles.textExtraSmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Flexible(
                        child: Text(
                          "$start - $end",
                          style: Styles.textStyleMediumBold(
                            context,
                            color: Colors.white,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.007),

                  // Status + Bidders Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _statusText(),
                          style: Styles.textSmall(
                            context,
                            color: Colors.white,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 👥 Show bidder count only if active
                      if (slot.isActive)
                        Consumer<MenuProvider>(
                          builder: (context, provider, _) {
                            final count = provider.bidderCounts[slot.timerId];
                            if (count == null) {
                              // not fetched yet → shimmer or dot animation
                              return Padding(
                                padding: EdgeInsets.only(right: size.width * 0.02),
                                child: Text(
                                  "Loading...",
                                  style: Styles.textSmall(
                                    context,
                                    color: Colors.white,
                                  ),
                                  textScaler: const TextScaler.linear(1.0),
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.only(right: size.width * 0.02),
                              child: Text(
                                "Bidders: $count",
                                style: Styles.textSmall(
                                  context,
                                  color: Colors.white,
                                ),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats HH:mm:ss or HH:mm to 12-hour time like 11:15 AM
  String _formatTime(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat("HH:mm").parse(time);
        return DateFormat("hh:mm a").format(parsed);
      } catch (_) {
        return time;
      }
    }
  }
}
