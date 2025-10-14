import 'dart:convert';

import 'package:my_food_my_price/services/secure_storage.dart';

import '../../../models/BidderModels/winner_model.dart';

class PaymentHelpers {
  /// Save payment failure details for retry later (secure per-user)
  static Future<void> saveFailedPaymentDetails({
    required List<WinnerModel> winners,
    required String franchiseId,
    required String timerId,
  }) async {
    final winningItemsJson =
        jsonEncode(winners.map((w) => w.toJson()).toList());

    await SecureStorageService.write(
        'failed_payment_winning_items', winningItemsJson);
    await SecureStorageService.write(
        'failed_payment_franchise_id', franchiseId);
    await SecureStorageService.write('failed_payment_timer_id', timerId);
    await SecureStorageService.write(
        'failed_payment_date', DateTime.now().toIso8601String());
  }

  /// Clear all failed payment data after success
  static Future<void> clearFailedPaymentDetails() async {
    await SecureStorageService.delete('failed_payment_winning_items');
    await SecureStorageService.delete('failed_payment_franchise_id');
    await SecureStorageService.delete('failed_payment_timer_id');
    await SecureStorageService.delete('failed_payment_date');
  }

  /// Optional — read data if you ever want to retry payment automatically
  static Future<Map<String, dynamic>?> readFailedPaymentDetails() async {
    final itemsJson =
        await SecureStorageService.read('failed_payment_winning_items');
    if (itemsJson == null) return null;

    final franchiseId =
        await SecureStorageService.read('failed_payment_franchise_id');
    final timerId =
        await SecureStorageService.read('failed_payment_timer_id');
    final date = await SecureStorageService.read('failed_payment_date');

    final List<dynamic> decoded = jsonDecode(itemsJson);
    final winners =
        decoded.map((e) => WinnerModel.fromJson(e)).toList();

    return {
      "winners": winners,
      "franchiseId": franchiseId,
      "timerId": timerId,
      "date": date,
    };
  }
}