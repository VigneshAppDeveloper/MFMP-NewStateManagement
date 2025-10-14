import 'package:ntp/ntp.dart';
import 'package:timezone/data/latest_all.dart'; // ✅ correct import
import 'package:timezone/timezone.dart' as tz;

/// ✅ Centralized NTP service for accurate Indian time (IST)
/// Used across providers (MenuProvider, TimeSlotProvider, etc.)
class NtpService {
  static final NtpService _instance = NtpService._internal();
  factory NtpService() => _instance;
  NtpService._internal();

  DateTime? _lastFetchedUtc;
  late tz.Location _istLocation;
  DateTime _lastUpdated = DateTime.now();

  /// Initialize timezone once (must be called before first use)
  Future<void> initialize() async {
    initializeTimeZones(); // ✅ works now
    _istLocation = tz.getLocation('Asia/Kolkata');
  }

  /// Fetch time from NTP server (Google / pool.ntp.org)
  Future<DateTime?> _fetchServerTime() async {
    try {
      final ntpTime = await NTP.now();
      _lastFetchedUtc = ntpTime.toUtc();
      _lastUpdated = DateTime.now();
      return _convertToIST(_lastFetchedUtc!);
    } catch (e) {
      if (_lastFetchedUtc != null) return _convertToIST(_lastFetchedUtc!);
      return _convertToIST(DateTime.now().toUtc());
    }
  }

  /// Converts any UTC DateTime → IST
  DateTime _convertToIST(DateTime utcTime) {
    return tz.TZDateTime.from(utcTime, _istLocation);
  }

  /// Returns current Indian time (fetch every 30 sec for accuracy)
  Future<DateTime> getCurrentIST({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (forceRefresh ||
        _lastFetchedUtc == null ||
        now.difference(_lastUpdated).inSeconds > 30) {
      return await _fetchServerTime() ?? _convertToIST(DateTime.now().toUtc());
    }

    final diff = now.difference(_lastUpdated);
    final estimatedUtc = _lastFetchedUtc!.add(diff);
    return _convertToIST(estimatedUtc);
  }
}
