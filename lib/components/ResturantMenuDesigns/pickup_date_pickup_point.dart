import 'package:flutter/material.dart';

import '../../util/styles.dart';


class PickupDatePickupPoint extends StatefulWidget {
  const PickupDatePickupPoint({super.key});

  @override
  State<PickupDatePickupPoint> createState() => _PickupDatePickupPointState();
}

class _PickupDatePickupPointState extends State<PickupDatePickupPoint> {
 DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        // Date Selector
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
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
                          : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", // formatted date
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
        // Pickup Location
        Expanded(
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
                    "2 Mainroad, 2A, Viyasarbadi - 12",
                    style: Styles.textSmall(context),
                    overflow: TextOverflow.ellipsis,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
                const Icon(Icons.location_on_outlined, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}