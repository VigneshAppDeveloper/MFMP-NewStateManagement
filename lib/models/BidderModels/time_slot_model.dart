import 'package:intl/intl.dart';

class TimeSlotModel {
  final String franchiseId;
  final String timerId;
  final DateTime startTime;
  final DateTime endTime;

  bool isActive;
  bool isUpcoming;
  bool isCompleted;

  TimeSlotModel({
    required this.franchiseId,
    required this.timerId,
    required this.startTime,
    required this.endTime,
    this.isActive = false,
    this.isUpcoming = false,
    this.isCompleted = false,
  });

  /// ✅ Factory with auto DateTime parsing (safe & production-ready)
  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();

    DateTime _parseTime(String? timeStr, {bool addDayIfBeforeNow = false}) {
      try {
        if (timeStr == null || timeStr.isEmpty) return now;

        final parts = timeStr.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;

        DateTime parsed = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
          second,
        );

        // ✅ Handle overnight slot (e.g., 23:00 -> 01:00)
        if (addDayIfBeforeNow && parsed.isBefore(now)) {
          parsed = parsed.add(const Duration(days: 1));
        }

        return parsed;
      } catch (e) {
        print("⚠️ Invalid time format: $timeStr ($e)");
        return now;
      }
    }

    final startRaw = json['starting_time']?.toString() ?? '';
    final endRaw = json['end_time']?.toString() ?? '';

    final start = _parseTime(startRaw);
    final end = _parseTime(endRaw, addDayIfBeforeNow: endRaw.compareTo(startRaw) < 0);

    return TimeSlotModel(
      franchiseId: json['franchise_id']?.toString() ?? '',
      timerId: json['timer_id']?.toString() ?? '',
      startTime: start,
      endTime: end,
    );
  }

  /// 🕒 Return formatted time for UI (12-hour with AM/PM)
  String get formattedStart => DateFormat('hh:mm a').format(startTime);
  String get formattedEnd => DateFormat('hh:mm a').format(endTime);
}
