import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/Providers/menu_provider.dart';
import 'package:provider/provider.dart';

import '../../../Providers/bidding_order_provider.dart';
import '../../../models/PickUptModels/pickup_point.dart';
import '../../../models/PickUptModels/pickup_time_model.dart';
import '../../../models/Resturant Model/resturant.dart';
import '../../../util/color_constant.dart';
import '../../../util/styles.dart';

class PickupDetailsSection extends StatefulWidget {
  final String pickupDate;
  final String pickupPoint;
  final String franchiseId;
  final Restaurant restaurant;

  const PickupDetailsSection({
    super.key,
    required this.pickupDate,
    required this.pickupPoint,
    required this.franchiseId,
    required this.restaurant,
  });

  @override
  State<PickupDetailsSection> createState() => _PickupDetailsSectionState();
}

class _PickupDetailsSectionState extends State<PickupDetailsSection> {
  late DateTime selectedDate;
  PickpointModel? selectedPickupPoint;
  PickupTimeModel? selectedPickupTime;

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd-MM-yyyy').parse(widget.pickupDate);
    selectedPickupPoint = context.read<MenuProvider>().selectedPickupPoint;
  }

  // ✅ Same logic as MenuPage (blocked calendar)
  void _showCalendar(BuildContext context) async {
    final blockedDates = selectedPickupPoint?.blockoutDates ?? [];
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
                        context, formattedDisplay, blockedReasons);
                  } else {
                    setState(() {
                      selectedDate = date;
                    });
                    final formatted =
                        DateFormat('dd-MM-yyyy').format(selectedDate);
                    await context
                        .read<BiddingOrderProvider>()
                        .reloadPickupTime(widget.franchiseId, formatted);
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
                        child: Text('${date.day}',
                            style: const TextStyle(color: Colors.grey)),
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
                        child: Text('${date.day}',
                            style: const TextStyle(color: Colors.white)),
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
      BuildContext context, String date, Map<String, String> blockedReasons) {
    final reason = blockedReasons[date] ?? 'Unavailable';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Blocked Date",
              style: Styles.textStyleMediumBold(context,
                  color: AppColor.maincolor)),
          content: Text("Reason: $reason",
              style: Styles.textStyleMedium(context)),
          actions: [
            TextButton(
              child: Text("OK",
                  style: Styles.textStyleMediumBold(context,
                      color: AppColor.maincolor)),
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
    final biddingProvider = context.watch<BiddingOrderProvider>();
    final pickupPoints = widget.restaurant.pickupPoints;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pickup Point", style: Styles.textStyleMediumBold(context)),
            SizedBox(height: size.height * 0.008),
            _pickupPointDropdown(context, pickupPoints),

            Divider(height: size.height * 0.04, thickness: 0.6),

            Text("Pickup Date", style: Styles.textStyleMediumBold(context)),
            SizedBox(height: size.height * 0.008),
            _dateContainer(
              context,
              icon: Icons.calendar_today,
              date: DateFormat('dd-MM-yyyy').format(selectedDate),
              onTap: () => _showCalendar(context),
            ),

            Divider(height: size.height * 0.04, thickness: 0.6),

            Text("Pickup Time", style: Styles.textStyleMediumBold(context)),
            SizedBox(height: size.height * 0.008),
            _dropdownContainer(
              context,
              icon: Icons.access_time,
              value: selectedPickupTime?.time,
              hint: biddingProvider.isLoading
                  ? "Loading..."
                  : (biddingProvider.pickupTimes.isEmpty
                      ? "No pickup times"
                      : "Select Pickup Time"),
              items: biddingProvider.pickupTimes.map((e) => e.time).toList(),
              onChanged: (val) {
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
      BuildContext context, List<PickpointModel> points) {
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
          hint: Text("Select Pickup Point",
              style: Styles.textStyleMedium(context, color: Colors.grey)),
          items: points.map((point) {
            return DropdownMenuItem<PickpointModel>(
              value: point,
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: AppColor.maincolor, size: 20),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: Text(point.pickupLocation,
                        style: Styles.textStyleMedium(context),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedPickupPoint = value);
            if (value != null) {
              context.read<MenuProvider>().setPickupPoint(value);
            }
          },
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.black, size: 20),
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
    required ValueChanged<String?> onChanged,
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
          hint: Text(hint,
              style: Styles.textStyleMedium(context, color: Colors.grey)),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Row(
                children: [
                  Icon(icon, color: AppColor.maincolor, size: 20),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: Text(e,
                        style: Styles.textStyleMedium(context),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.black, size: 20),
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
              child: Text(date, style: Styles.textStyleMedium(context)),
            ),
            const Icon(Icons.edit, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}