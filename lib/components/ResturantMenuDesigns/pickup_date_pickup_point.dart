import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:provider/provider.dart';

import '../../Providers/menu_provider.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../services/ntp_service.dart';
import '../../util/styles.dart';

class PickupDatePickupPoint extends StatefulWidget {
  final Restaurant restaurant;
  final bool fromFlashPage;
  const PickupDatePickupPoint({
    super.key,
    required this.restaurant,
    this.fromFlashPage = false,
  });

  @override
  State<PickupDatePickupPoint> createState() => PickupDatePickupPointState();
}

class PickupDatePickupPointState extends State<PickupDatePickupPoint> {
  DateTime? _selectedDate;
  // PickpointModel? _selectedPickup;

  @override
  void initState() {
    super.initState();
    if (widget.fromFlashPage) {
      // ✅ Always set current date for flash offers
      final today = DateTime.now();
      _selectedDate = today;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MenuProvider>().setPickupDate(today);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        // 🔹 Date Selector
        Expanded(
          child: GestureDetector(
            onTap:
                widget.fromFlashPage
                    ? null // ❌ Disable calendar open for flash
                    : () => showCalendar(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.015,
                horizontal: size.width * 0.04,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? "Select Your Pickup Date"
                          : DateFormat("dd/MM/yyyy").format(_selectedDate!),
                      style: Styles.textSmall(context),
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color:
                        widget.fromFlashPage
                            ? Colors
                                .grey
                                .shade400 // muted color
                            : Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),

       
      ],
    );
  }

  void showCalendar(BuildContext context) async {
    debugPrint(
      "🗓 Opening calendar for restaurant: ${widget.restaurant.franchiseId}",
    );
  
    final blockedDates = widget.restaurant.blockoutDates;
    final Map<String, String> blockedReasons = {
      for (var b in blockedDates)
        DateFormat('dd-MM-yyyy').format(DateTime.parse(b.date)): b.reason,
    };

    final ntpService = NtpService();
    final DateTime ntpTime = await ntpService.getCurrentIST();
    DateTime firstDate;
    DateTime lastDate;
  
    // ✅ Business rule: if current time >= 2 PM, skip today
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
        blockedDates.isEmpty
            ? []
            : blockedDates
                .where((b) {
                  try {
                    final parsed = DateTime.parse(b.date);
                    return parsed.isAfter(DateTime(2000)); // sanity
                  } catch (_) {
                    debugPrint(
                      "⚠️ Invalid date format in block date: ${b.date}",
                    );
                    return false;
                  }
                })
                .map((b) => DateTime.parse(b.date))
                .toList();

    debugPrint(
      "📆 Final Blocked Dates: ${blockedDateList.map((e) => e.toIso8601String()).toList()}",
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: CalendarCarousel(
                onDayPressed: (date, events) async {
                  String formattedISO = DateFormat('yyyy-MM-dd').format(date);
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
                      context,
                      formattedDisplay,
                      blockedReasons,
                    );
                  } else {
                    setState(() {
                      _selectedDate = date;
                    });
                    context.read<MenuProvider>().setPickupDate(date);
                    Navigator.of(context).pop();
                    final formatted = DateFormat('yyyy-MM-dd').format(date);
                    await context.read<MenuProvider>().getRestaurantMenu(
                      widget.restaurant.franchiseId,
                      forceRefresh: true,
                      isFlash: widget.fromFlashPage, // false for normal
                      pickupDate: formatted, // ✅ send selected date
                    );
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

                // 🔘 Custom cell for blocked dates
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
            textScaler: const TextScaler.linear(1.0),
            style: Styles.textStyleMediumBold(
              context,
              color: AppColor.maincolor,
            ),
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
                textScaler: const TextScaler.linear(1.0),
                style: Styles.textStyleMediumBold(
                  context,
                  color: AppColor.maincolor,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
