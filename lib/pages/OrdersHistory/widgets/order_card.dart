import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/services/ntp_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Providers/order_history_provider.dart';
import '../../../Providers/ratings_provider.dart';
import '../../../models/OrderModels/order_model.dart';
import '../../../route_generator.dart';
import '../../../util/color_constant.dart';
import '../../../util/styles.dart';

class OrderCard extends StatelessWidget {
  final OrderDetailModel order;
  const OrderCard({super.key, required this.order});

  // ✅ Common date formatter (yyyy-mm-dd → dd-mm-yyyy)
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final d = DateTime.parse(date);
      return "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
    } catch (_) {
      return date;
    }
  }

  // ✅ Common time formatter (24h → 12h with AM/PM)
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return '-';
    try {
      final t = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      );
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      final formatted = TimeOfDay.fromDateTime(dt);
      final period = formatted.period == DayPeriod.am ? 'AM' : 'PM';
      final hour = formatted.hourOfPeriod == 0 ? 12 : formatted.hourOfPeriod;
      final minute = formatted.minute.toString().padLeft(2, '0');
      return "$hour:$minute $period";
    } catch (_) {
      return time;
    }
  }

  Future<bool> canCancelOrder(String pickupDate, String pickupTime) async {
    try {
      // ✅ Use accurate server time instead of device time
      final now = await NtpService().getCurrentIST();

      // Parse pickup date and time safely
      final parsedDate = DateFormat("yyyy-MM-dd").parse(pickupDate);
      final parsedTime = DateFormat("HH:mm:ss").parse(pickupTime);

      final pickupDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
        parsedTime.second,
      );

      // ✅ Cancellation allowed only if pickup is more than 24 h away
      return now.isBefore(pickupDateTime.subtract(const Duration(hours: 24)));
    } catch (e) {
      debugPrint("Cancel-check error: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final franchise = order.franchise;
    final user = order.user;
    final menu = order.menu;
    final pickup = order.pickupPoint;

    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.02),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header (status + rating)
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    order.paymentStatus.toLowerCase() == 'success'
                        ? Icons.check_circle
                        : Icons.cancel,
                    color:
                        order.paymentStatus.toLowerCase() == 'success'
                            ? Colors.green
                            : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.paymentStatus.toUpperCase(),
                    style: Styles.textSmall(
                      context,
                      color:
                          order.paymentStatus.toLowerCase() == 'success'
                              ? Colors.green
                              : Colors.red,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const Spacer(),
                  if (order.paymentStatus.toLowerCase() == 'success') ...[
                    const SizedBox(width: 8),
                    Consumer<RatingsProvider>(
                      builder: (context, ratingsProvider, _) {
                        final hasGivenRating =
                            (order.ratingsAvgStarRating ?? 0) >
                            0; // fallback local field

                        return GestureDetector(
                          onTap: () async {
                            if (hasGivenRating)
                              return; // Already rated → do nothing

                            final result = await AppRouteName.ratingsPage.push(
                              context,
                              args: {
                                "franchiseId": order.franchiseId,
                                "franchiseName":
                                    order.franchise?.franchise ?? '',
                                "menuCategoryNames": [
                                  order.menu?.menuName ?? '',
                                ],
                                "menuCategoryIds": [order.menuId],
                                "orderIds": [order.orderId],
                                "location":
                                    order.franchise?.district?.district ?? '',
                                "franchiseImage": order.menu?.menuImage ?? '',
                                "orderType": "fixed",
                              },
                            );

                            if (result == true) {
                              await ratingsProvider.getFeedback(
                                franchiseId: order.franchiseId,
                                forceRefresh: true,
                              );
                              // optional: refresh order list
                              context
                                  .read<OrderHistoryProvider>()
                                  .getFixedOrders(forceRefresh: true);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  hasGivenRating
                                      ? Colors.transparent
                                      : AppColor
                                          .maincolor, // filled for unrated
                              border: Border.all(
                                color:
                                    hasGivenRating
                                        ? AppColor.maincolor
                                        : Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color:
                                      hasGivenRating
                                          ? Colors.orange
                                          : Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  hasGivenRating
                                      ? "Your Ratings (${order.ratingsAvgStarRating?.toStringAsFixed(1) ?? '0'})"
                                      : "Give Ratings",
                                  style: Styles.textSmall(
                                    context,
                                    color:
                                        hasGivenRating
                                            ? AppColor.maincolor
                                            : Colors.white,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                  textScaler: const TextScaler.linear(1.0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
              SizedBox(height: size.height * 0.008),

              // ✅ IDs
              _infoText(context, "Trans ID: ${order.transactionId ?? '-'}"),
              _infoText(context, "Order ID: ${order.orderId}"),

              SizedBox(height: size.height * 0.01),

              // ✅ Franchise + user
              // ✅ Franchise info with location icon
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.black54,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "${franchise?.franchise ?? ''}, ${franchise?.district?.district ?? ''}",
                      style: Styles.textSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              // ✅ User info with user icon and phone at end
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.black54, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user?.name ?? '',
                      style: Styles.textSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.black54, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        user?.mobile ?? '',
                        style: Styles.textSmall(context),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ],
              ),

              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Pickup Details",
                      style: Styles.textSmall(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.place, color: Colors.black54, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pickup?.pickupLocation ?? '-',
                      style: Styles.textSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final link = pickup?.googleMapLink ?? '';
                        if (link.isNotEmpty &&
                            await canLaunchUrl(Uri.parse(link))) {
                          await launchUrl(
                            Uri.parse(link),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.maps_home_work_sharp,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: Text(
                        "Map Location",
                        style: Styles.textSmall(context).copyWith(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      formatDate(order.pickupDate),
                      style: Styles.textSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatTime(order.pickupTime),
                    style: Styles.textSmall(context),
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Booking Deatils : ${formatDate(order.date)} | ${formatTime(order.time)}",
                      style: Styles.textSmall(context, color: Colors.black54),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Text(
                    "Item Details",
                    style: Styles.textSmall(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                    textScaler: const TextScaler.linear(1.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(child: const Divider()),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              // ✅ Item details
              _infoText(
                context,
                "${menu?.menuName ?? 'Unknown'} × ${order.menuQuantity}",
              ),
              SizedBox(height: size.height * 0.01),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bill Total",
                      style: Styles.textSmall(context),
                      textScaler: const TextScaler.linear(1.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Flexible(
                      child: Text(
                        "₹ ${order.transactionAmount ?? '0.00'}",
                        style: Styles.textSmall(context, color: Colors.black),
                        textScaler: const TextScaler.linear(1.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ✅ Cancel option + support
              if (order.paymentStatus.toLowerCase() == "success")
                FutureBuilder<bool>(
                  future: canCancelOrder(
                    order.pickupDate,
                    order.pickupTime ?? "00:00:00",
                  ),
                  builder: (context, snapshot) {
                    final allowed = snapshot.data ?? false;
                    return GestureDetector(
                      onTap: () {
                        if (!allowed) return; // Disabled if within 24 h
                        // 👉 your dialog or cancel API call here
                      },
                      child: Text(
                        allowed
                            ? "❌ Cancel Order"
                            : "Cancellation Unavailable (within 24 h)",
                        style: Styles.textSmall(
                          context,
                          color: allowed ? Colors.red : Colors.grey,
                        ),
                        textScaler: const TextScaler.linear(1.0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),

              SizedBox(height: size.height * 0.01),
              Text(
                "For any order issues or modifications, please call the owner at 📞 ${pickup?.ownerNumber ?? '-'}",
                style: Styles.textSmall(context, color: Colors.black54),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoText(BuildContext context, String text, {Color? color}) {
    return Text(
      text,
      style: Styles.textSmall(context, color: color ?? Colors.black),
      textScaler: const TextScaler.linear(1.0),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
