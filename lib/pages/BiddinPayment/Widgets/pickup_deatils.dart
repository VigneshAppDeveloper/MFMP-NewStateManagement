import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/Providers/fixed_order_provider.dart';
import 'package:my_food_my_price/Providers/menu_provider.dart';
import 'package:provider/provider.dart';

import '../../../Providers/bidding_order_provider.dart';
import '../../../models/PickUptModels/pickup_point.dart';
import '../../../models/PickUptModels/pickup_time_model.dart';
import '../../../models/Resturant Model/resturant.dart';
import '../../../services/ntp_service.dart';
import '../../../util/color_constant.dart';
import '../../../util/styles.dart';

class PickupDetailsSection extends StatefulWidget {
  final String pickupDate;
  final String pickupPoint;
  final String franchiseId;
  final Restaurant restaurant;
  final bool isFixedOrder; // ✅ new flag
  final ValueChanged<String>? onDateChange;
  final ValueChanged<String>? onPickupPointChange;
  final bool fromFlashPage;

  const PickupDetailsSection({
    super.key,
    required this.pickupDate,
    required this.pickupPoint,
    required this.franchiseId,
    required this.restaurant,
    this.isFixedOrder = false, // default = bidding
    this.onDateChange,
    this.onPickupPointChange,
    this.fromFlashPage = false,
  });

  @override
  State<PickupDetailsSection> createState() => _PickupDetailsSectionState();
}

class _PickupDetailsSectionState extends State<PickupDetailsSection> {
  late DateTime selectedDate;
  PickpointModel? selectedPickupPoint;
  PickupTimeModel? selectedPickupTime;

  String formatTime(String time24h) {
    try {
      final parts = time24h.split(':');
      if (parts.length < 2) return time24h;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(0, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt); // e.g., 10:00 AM
    } catch (_) {
      return time24h;
    }
  }

  int _compareTime(String a, String b) {
    try {
      final timeA = _parseTo24Hour(a);
      final timeB = _parseTo24Hour(b);
      return timeA.compareTo(timeB);
    } catch (_) {
      return 0;
    }
  }

  DateTime _parseTo24Hour(String timeStr) {
    // Handles formats like "10:00", "2.15pm", "2:20 PM"
    String normalized = timeStr.toLowerCase().replaceAll('.', ':').trim();
    if (!normalized.contains('am') && !normalized.contains('pm')) {
      // assume 24-hour style
      final parts = normalized.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts.length > 1 ? parts[1] : '0');
      return DateTime(0, 1, 1, hour, minute);
    }

    final formatter = DateFormat("h:mm a");
    return formatter.parse(
      normalized.replaceAll('am', ' AM').replaceAll('pm', ' PM'),
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      // Handles both ISO strings and dd-MM-yyyy
      if (widget.pickupDate.contains('-') && widget.pickupDate.length > 8) {
        selectedDate = DateTime.parse(widget.pickupDate); // e.g. 2025-10-16
        debugPrint("Parsed ISO date: $selectedDate");
      } else {
        selectedDate = DateFormat('dd-MM-yyyy').parse(widget.pickupDate);
      }
    } catch (_) {
      selectedDate = DateTime.now(); // fallback to today
    }

    selectedPickupPoint = context.read<MenuProvider>().selectedPickupPoint;
  }

  // ✅ Same logic as MenuPage (blocked calendar)
  void _showCalendar(BuildContext context) async {
    final parentContext = context; // keep outer context for provider access
    final blockedDates = selectedPickupPoint?.blockoutDates ?? [];

    final Map<String, String> blockedReasons = {
      for (var b in blockedDates)
        DateFormat('dd-MM-yyyy').format(DateTime.parse(b.date)): b.reason,
    };

    // ✅ Get accurate current IST time using global NtpService
    final ntpService = NtpService();
    final DateTime ntpTime = await ntpService.getCurrentIST();

    // ✅ Business rule: if current time >= 2 PM, skip today
    DateTime firstDate;
    DateTime lastDate;

    // ✅ Flash Sale flow → only today allowed
    if (widget.fromFlashPage) {
      firstDate = DateTime(ntpTime.year, ntpTime.month, ntpTime.day);
      lastDate = firstDate; // only today selectable
      debugPrint(
        "⚡ Flash Sale Mode: limiting calendar to today (${firstDate.toIso8601String()})",
      );
    } else {
      // ✅ Normal flow → respect 2 PM cutoff and +30 days
      firstDate =
          ntpTime.hour < 14
              ? DateTime(ntpTime.year, ntpTime.month, ntpTime.day)
              : DateTime(ntpTime.year, ntpTime.month, ntpTime.day + 1);
      lastDate = firstDate.add(const Duration(days: 30));
    }

    final List<DateTime> blockedDateList =
        blockedDates.map((b) => DateTime.parse(b.date)).toList();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Builder(
            builder: (innerContext) {
              return SizedBox(
                width: MediaQuery.of(innerContext).size.width * 0.9,
                height: MediaQuery.of(innerContext).size.height * 0.6,
                child: MediaQuery(
                  data: MediaQuery.of(
                    innerContext,
                  ).copyWith(textScaler: const TextScaler.linear(1.0)),
                  child: CalendarCarousel(
                    onDayPressed: (date, events) async {
                      String formattedDisplay = DateFormat(
                        'dd-MM-yyyy',
                      ).format(date);

                      if (date.isBefore(firstDate) || date.isAfter(lastDate)) {
                        return;
                      } else if (blockedDateList.any(
                        (d) =>
                            d.year == date.year &&
                            d.month == date.month &&
                            d.day == date.day,
                      )) {
                        _showBlockedDateReasonDialog(
                          innerContext,
                          formattedDisplay,
                          blockedReasons,
                        );
                      } else {
                        setState(() {
                          selectedDate = date;
                          selectedPickupTime = null; // ✅ clear previous time
                        });

                        // Optional: also clear from provider so UI stays in sync
                        if (widget.isFixedOrder) {
                          parentContext
                              .read<FixedOrderProvider>()
                              .selectedPickupTime = null;
                        } else {
                          parentContext
                              .read<BiddingOrderProvider>()
                              .selectedPickupTime = null;
                        }

                        final formatted = DateFormat(
                          'dd-MM-yyyy',
                        ).format(selectedDate);
                        widget.onDateChange?.call(formatted);

                        // ✅ use parentContext here — it has BiddingOrderProvider
                        if (widget.isFixedOrder) {
                          await parentContext
                              .read<FixedOrderProvider>()
                              .reloadPickupTime(widget.franchiseId, formatted);
                        } else {
                          await parentContext
                              .read<BiddingOrderProvider>()
                              .reloadPickupTime(widget.franchiseId, formatted);
                        }

                        Navigator.of(innerContext).pop();
                      }
                    },
                    todayTextStyle: Styles.textStyleMediumBold(
                      context,
                      color: Colors.white,
                    ),
                    headerTextStyle: Styles.textStyleMediumBold(context),
                    weekdayTextStyle: Styles.textSmall(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                    todayButtonColor: Colors.black,
                    selectedDayButtonColor: Colors.black,
                    selectedDayTextStyle: const TextStyle(color: Colors.white),
                    weekendTextStyle: const TextStyle(color: Colors.black),
                    todayBorderColor: Colors.transparent,
                    daysHaveCircularBorder: true,
                    customDayBuilder: (
                      bool isSelectable,
                      int index,
                      bool isSelectedDay,
                      bool isToday,
                      bool isPrevMonthDay,
                      TextStyle textStyle,
                      bool isNextMonthDay,
                      bool isThisMonthDay,
                      DateTime date,
                    ) {
                      if (date.isBefore(firstDate) || date.isAfter(lastDate)) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.grey),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ),
                        );
                      }

                      bool isBlocked = blockedDateList.any(
                        (d) =>
                            d.year == date.year &&
                            d.month == date.month &&
                            d.day == date.day,
                      );

                      if (isBlocked) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.white),
                              textScaler: const TextScaler.linear(1.0),
                            ),
                          ),
                        );
                      }

                      return null;
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showBlockedDateReasonDialog(
    BuildContext context,
    String date,
    Map<String, String> blockedReasons,
  ) {
    final reason = blockedReasons[date] ?? 'Unavailable';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Blocked Date",
            style: Styles.textStyleMediumBold(
              context,
              color: AppColor.maincolor,
            ),
            textScaler: const TextScaler.linear(1.0),
          ),
          content: Text(
            "Reason: $reason",
            style: Styles.textStyleMedium(context),
            textScaler: const TextScaler.linear(1.0),
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: Styles.textStyleMediumBold(
                  context,
                  color: AppColor.maincolor,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isFixed = widget.isFixedOrder; // added flag earlier
    final biddingProvider =
        isFixed
            ? context.watch<FixedOrderProvider>() as dynamic
            : context.watch<BiddingOrderProvider>() as dynamic;
    final pickupPoints = widget.restaurant.pickupPoints;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pickup Point",
              style: Styles.textStyleMediumBold(context),
              textScaler: const TextScaler.linear(1.0),
            ),
            SizedBox(height: size.height * 0.008),
            _pickupPointDropdown(context, pickupPoints),

            Divider(height: size.height * 0.04, thickness: 0.6),

            Text(
              "Pickup Date",
              style: Styles.textStyleMediumBold(context),
              textScaler: const TextScaler.linear(1.0),
            ),
            SizedBox(height: size.height * 0.008),
            _dateContainer(
              context,
              icon: Icons.calendar_today,
              date: DateFormat('dd-MM-yyyy').format(selectedDate),
              onTap: () => _showCalendar(context),
            ),

            Divider(height: size.height * 0.04, thickness: 0.6),

            Text(
              "Pickup Time",
              style: Styles.textStyleMediumBold(context),
              textScaler: const TextScaler.linear(1.0),
            ),
            SizedBox(height: size.height * 0.008),
            _dropdownContainer(
              context,
              icon: Icons.access_time,
              value: selectedPickupTime?.time,
              hint:
                  biddingProvider.isLoading
                      ? "Loading..."
                      : (biddingProvider.pickupTimes.isEmpty
                          ? "No pickup times"
                          : "Select Pickup Time"),
              items: List<String>.from(
                (biddingProvider.pickupTimes..sort(
                      (a, b) => _compareTime(a.time, b.time),
                    )) // ✅ Sort ascending
                    .map((e) => formatTime(e.time)),
              ),

              onChanged:
                  biddingProvider.pickupTimes.isEmpty
                      ? null // ✅ disable dropdown when no data
                      : (val) {
                        final match = biddingProvider.pickupTimes.firstWhere(
                          (t) => t.time == val,
                          orElse: () => PickupTimeModel(id: 0, time: val ?? ""),
                        );
                        setState(() => selectedPickupTime = match);
                        biddingProvider.selectedPickupTime = match;
                      },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickupPointDropdown(
    BuildContext context,
    List<PickpointModel> points,
  ) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PickpointModel>(
          isExpanded: true,
          value: selectedPickupPoint,
          hint: Text(
            "Select Pickup Point",
            style: Styles.textStyleMedium(context, color: Colors.grey),
            textScaler: const TextScaler.linear(1.0),
          ),
          items:
              points.map((point) {
                return DropdownMenuItem<PickpointModel>(
                  value: point,
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColor.maincolor,
                        size: 20,
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Text(
                          point.pickupLocation,
                          style: Styles.textStyleMedium(context),
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => selectedPickupPoint = value);
            if (value != null) {
              context.read<MenuProvider>().setPickupPoint(value);
              debugPrint(
                "📍 Selected pickup point: ${value.pickupLocation} (ID: ${value.pickupId})",
              );
              widget.onPickupPointChange?.call(value.pickupId.toString());
            }
          },
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _dropdownContainer(
    BuildContext context, {
    required IconData icon,
    required String? value,
    required String hint,
    required List<String> items,
    ValueChanged<String?>? onChanged,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: Styles.textStyleMedium(context, color: Colors.grey),
            textScaler: const TextScaler.linear(1.0),
          ),
          items:
              items.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColor.maincolor, size: 20),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Text(
                          e,
                          style: Styles.textStyleMedium(context),
                          overflow: TextOverflow.ellipsis,
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _dateContainer(
    BuildContext context, {
    required IconData icon,
    required String date,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.015,
          horizontal: size.width * 0.03,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColor.maincolor, size: 20),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Text(
                date,
                style: Styles.textStyleMedium(context),
                textScaler: const TextScaler.linear(1.0),
              ),
            ),
            const Icon(Icons.edit, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
