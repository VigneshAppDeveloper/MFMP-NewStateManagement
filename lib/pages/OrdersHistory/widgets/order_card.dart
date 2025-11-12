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
  final String orderType; // ✅ add this
  const OrderCard({super.key, required this.order, required this.orderType});

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
      // ✅ Always use server time for accuracy
      final now = await NtpService().getCurrentIST();

      // ✅ Parse pickup date (handles both yyyy-MM-dd or dd-MM-yyyy safely)
      DateTime parsedDate;
      try {
        parsedDate = DateFormat("yyyy-MM-dd").parse(pickupDate);
      } catch (_) {
        parsedDate = DateFormat("dd-MM-yyyy").parse(pickupDate);
      }

      // ✅ Normalize pickup time to 24-hour DateTime
      DateTime parsedTime = _parseFlexibleTime(pickupTime.trim());

      // ✅ Combine date + time
      final pickupDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
        parsedTime.second,
      );

      // ✅ Cancellation allowed if pickup > 24h from now
      final cutoff = pickupDateTime.subtract(const Duration(hours: 24));
      return now.isBefore(cutoff);
    } catch (e) {
      debugPrint("Cancel-check error: $e");
      return false;
    }
  }

  /// ✅ Utility: safely parse any time string like
  /// "16:30", "16:30:00", "4:30 PM", "04:30 pm", etc.
  DateTime _parseFlexibleTime(String time) {
    final formats = ["HH:mm:ss", "HH:mm", "h:mm a", "hh:mm a", "h:mm:ss a"];

    for (final f in formats) {
      try {
        return DateFormat(f).parse(time);
      } catch (_) {
        continue;
      }
    }

    // fallback midnight if parsing fails
    return DateTime(0, 1, 1, 0, 0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final franchise = order.franchise;
    final user = order.user;
    final menu = order.menu;
    //  final pickup = order.pickupPoint;

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
                                "orderType": orderType,
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
                      franchise?.address ?? '-',
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
                        // final link = pickup?.googleMapLink ?? '';
                        // if (link.isNotEmpty &&
                        //     await canLaunchUrl(Uri.parse(link))) {
                        //   await launchUrl(
                        //     Uri.parse(link),
                        //     mode: LaunchMode.externalApplication,
                        //   );
                        // }
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
                  if (orderType != "flash") ...[
                    // ✅ hide for flash
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
              if ((order.groupedMenus?.isNotEmpty ?? false)) ...[
                for (final m in order.groupedMenus!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _infoText(
                      context,
                      "${m?.menuName ?? 'Unknown'} × ${order.menuQuantity}",
                    ),
                  ),
              ] else ...[
                _infoText(
                  context,
                  "${menu?.menuName ?? 'Unknown'} × ${order.menuQuantity}",
                ),
              ],

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
            if (order.message != null && order.message!.trim().isNotEmpty)  SizedBox(height: size.height * 0.01),
              if (order.message != null && order.message!.trim().isNotEmpty)
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
                ],
              ),
               SizedBox(height: size.height * 0.01),
              if (order.message != null && order.message!.trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.message!,
                        style: Styles.textSmall(context),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: size.height * 0.01),
              // ✅ Cancel option + support
              // ✅ Cancel option + support OR Flash contact section
              if (orderType == "flash") ...[
                SizedBox(height: size.height * 0.01),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Restaurant Contact Details for this Order :",
                        style: Styles.textSmall(
                          context,
                        ).copyWith(fontWeight: FontWeight.bold),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      SizedBox(height: size.height * 0.008),
                      if ((order.flashContact?.isNotEmpty ?? false)) ...[
                        Text(
                          "Name: ${order.flashContact!.first.name} * (Res Contact person name).",
                          style: Styles.textSmall(context),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                        Text(
                          "Phone: ${order.flashContact!.first.contact} * (Res Contact person number).",
                          style: Styles.textSmall(context),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ] else
                        Text(
                          "Contact details not available.",
                          style: Styles.textSmall(context),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      SizedBox(height: size.height * 0.008),
                      Text(
                        "* No cancellations allowed on Flash Sale orders.",
                        style: Styles.textSmall(
                          context,
                          color: Colors.red,
                        ).copyWith(fontWeight: FontWeight.w500),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ],
                  ),
                ),
              ] else if (order.paymentStatus.toLowerCase() == "success") ...[
                FutureBuilder<bool>(
                  future: canCancelOrder(
                    order.pickupDate,
                    order.pickupTime ?? "00:00:00",
                  ),
                  builder: (context, snapshot) {
                    final allowed = snapshot.data ?? false;

                    if (!allowed) {
                      // ⛔ Within 24h – show disabled info text
                      return Center(
                        child: Text(
                          "Cancellation Unavailable (within 24h)",
                          style: Styles.textSmall(context, color: Colors.grey),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      );
                    }

                    // ✅ Allowed – show full-width button
                    return Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.012,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.055,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.maincolor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await showCancelInfoDialog(context);
                            // final confirmed = await Dialogs.confirmation(
                            //   context,
                            //   title: "Cancel Order?",
                            //   message:
                            //       "Are you sure you want to cancel this order?",
                            // );
                            // if (!confirmed) return;

                            // await context
                            //     .read<OrderHistoryProvider>()
                            //     .cancelOrder(order.orderId);

                            // AppDialogue.toast("Order canceled successfully");
                            // context.read<OrderHistoryProvider>().getFixedOrders(
                            //   forceRefresh: true,
                            // );
                          },
                          child: Text(
                            "Cancel Order",
                            style: Styles.textStyleMediumBold(
                              context,
                              color: Colors.white,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // SizedBox(height: size.height * 0.01),
              // Text(
              //   "For any order issues or modifications, please call the owner at 📞 ${pickup?.ownerNumber ?? '-'}",
              //   style: Styles.textSmall(context, color: Colors.black54),
              //   textScaler: const TextScaler.linear(1.0),
              // ),
            ],
          );
        },
      ),
    );
  }

  Future<void> showCancelInfoDialog(BuildContext context) async {
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.04,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🖼 optional illustration (replace with your asset)
                // Image.asset(
                //   "assets/images/cancel_info.png",
                //   width: size.width * 0.25,
                //   fit: BoxFit.contain,
                // ),
                // SizedBox(height: size.height * 0.02),

                // 📄 Info text
                Text(
                  "Cancellations or Modifications are not allowed if your scheduled pickup date is within 24 hours.\n\n"
                  "For assistance with Order Cancellation or Modification, reach out at:\n"
                  "+918062178089\n(Don't forget to add prefix 0 or +91)\n\n"
                  "WhatsApp: +919080461946",
                  style: Styles.textSmall(context, color: Colors.black87),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                ),
                SizedBox(height: size.height * 0.025),

                // ✅ OK button
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.055,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      "OK",
                      style: Styles.textStyleMediumBold(
                        context,
                        color: Colors.white,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
