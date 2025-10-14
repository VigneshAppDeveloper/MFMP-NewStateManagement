import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:provider/provider.dart';

import '../../Providers/menu_provider.dart';
import '../../models/PickUptModels/pickup_point.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../util/styles.dart';

class PickupDatePickupPoint extends StatefulWidget {
  final Restaurant restaurant;
  const PickupDatePickupPoint({super.key, required this.restaurant});

  @override
  State<PickupDatePickupPoint> createState() => _PickupDatePickupPointState();
}

class _PickupDatePickupPointState extends State<PickupDatePickupPoint> {
  DateTime? _selectedDate;
  PickpointModel? _selectedPickup;

  @override
  void initState() {
    super.initState();

    // ❌ Remove default pickup point auto selection
    // User will explicitly select from dropdown
    _selectedPickup = null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        // 🔹 Date Selector
        Expanded(
          child: GestureDetector(
            onTap: () => _showCalendar(context),
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
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: size.width * 0.03),

        // 🔹 Pickup Location Dropdown
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.002,
              horizontal: size.width * 0.04,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PickpointModel>(
                isExpanded: true,
                value: _selectedPickup,
                hint: Text(
                  "Select Pickup Point",
                  style: Styles.textSmall(context).copyWith(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                items: widget.restaurant.pickupPoints.map((point) {
                  return DropdownMenuItem<PickpointModel>(
                    value: point,
                    child: Text(
                      point.pickupLocation,
                      style: Styles.textSmall(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPickup = value;
                    // ❌ Don’t clear date anymore
                    // _selectedDate = null;
                  });

                  final menuProvider = context.read<MenuProvider>();
                  if (value != null) {
                    menuProvider.setPickupPoint(value);
                  }
                },
                icon: const Icon(Icons.location_on_outlined, size: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCalendar(BuildContext context) async {
    // ✅ Now works even if pickup point not selected
    // since they are independent

    // If any pickup point is selected, show its blocked dates;
    // otherwise, show empty list (no restriction)
    final blockedDates = _selectedPickup?.blockoutDates ?? [];
    final Map<String, String> blockedReasons = {
      for (var b in blockedDates)
        DateFormat('dd-MM-yyyy').format(DateTime.parse(b.date)): b.reason,
    };

    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(now.year, now.month, now.day);
    DateTime lastDate = firstDate.add(const Duration(days: 30));
    List<DateTime> blockedDateList =
        blockedDates.map((b) => DateTime.parse(b.date)).toList();

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
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: CalendarCarousel(
                onDayPressed: (date, events) async {
                  String formattedISO =
                      DateFormat('yyyy-MM-dd').format(date);
                  String formattedDisplay =
                      DateFormat('dd-MM-yyyy').format(date);

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
                  }
                },
                todayTextStyle:
                    Styles.textStyleMediumBold(context, color: Colors.white),
                headerTextStyle: Styles.textStyleMediumBold(context),
                weekdayTextStyle: Styles.textSmall(context)
                    .copyWith(fontWeight: FontWeight.bold),
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
