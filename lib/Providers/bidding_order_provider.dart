import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/url_path.dart';

import '../models/OrderModels/order_bidding_reponse.dart';
import '../models/OrderModels/paymnet_reponse.dart';
import '../models/PickUptModels/pickup_time_model.dart';
import '../services/api_service.dart';

class BiddingOrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OrderBiddingResponse? _lastResponse;
  OrderBiddingResponse? get lastResponse => _lastResponse;

  PaymentStatusResponse? _paymentStatus;
  PaymentStatusResponse? get paymentStatus => _paymentStatus;

  String? errorMessage;

  List<PickupTimeModel> _pickupTimes = [];
  List<PickupTimeModel> get pickupTimes => _pickupTimes;

  PickupTimeModel? _selectedPickupTime;
  PickupTimeModel? get selectedPickupTime => _selectedPickupTime;
  set selectedPickupTime(PickupTimeModel? val) {
    _selectedPickupTime = val;
    notifyListeners();
  }

  bool _isPickupTimeLoading = false;
  bool get isPickupTimeLoading => _isPickupTimeLoading;

  /// ✅ Place Bidding Order
  Future<bool> placeBiddingOrder({
    required String franchiseId,
    required String userId,
    required List<String> menuIds,
    required List<String> menuNames,
    required List<String> menuQuantities,
    required List<String> totalMenuPrices,
    required String name,
    required String pickupPoint,
    required String pickupTime,
    required String mobile,
    required String transactionAmount,
    required String merchantTransactionId,
    required String wallet,
    required String gst,
    required String pickupDate,
    required String contactCustomer,
    required String timerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> data = {
      "franchise_id": franchiseId,
      "user_id": userId,
      "menu_ids": menuIds,
      "menu_names": menuNames,
      "menu_quantities": menuQuantities,
      "total_menu_prices": totalMenuPrices,
      "name": name,
      "pickup_point": pickupPoint,
      "pickup_time": pickupTime,
      "mobile": mobile,
      "transaction_amount": transactionAmount,
      "merchant_transaction_id": merchantTransactionId,
      "wallet": wallet,
      "gst": gst,
      "pickup_date": pickupDate,
      "contact_customer": contactCustomer,
      "timer_id": timerId,
    };

    try {
      final resp = await APIService.post(
        UrlPath.biddingUrl.addBiddingOrderDetails,
        data: data,
        auth: true,
        shownoInternet: true,
        console: true,
        timeout: const Duration(seconds: 30),
      );

      debugPrint("📡 [BIDDING ORDER] RESPONSE BODY: ${resp.fullBody}");

      if (resp.status) {
        // ✅ Success - parse into model
        final model = OrderBiddingResponse.fromJson(resp.fullBody);
        _lastResponse = model;
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // ❌ API returned failure
        errorMessage = resp.message ?? "Failed to place order";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // ❌ Exception handling
      debugPrint("❌ Error in placeBiddingOrder: $e");
      errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWallet({required String wallet}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {"wallet": wallet};

      final resp = await APIService.post(
        UrlPath.loginUrl.userWalletUpdate, // 🔹 endpoint from UrlPath
        data: data,
        auth: true,
        shownoInternet: true,
        console: true,
        timeout: const Duration(seconds: 30),
      );

      debugPrint("📡 [UPDATE WALLET] RESPONSE BODY: ${resp.fullBody}");

      if (resp.status) {
        debugPrint("✅ Wallet updated successfully: ${resp.message}");
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("⚠️ Wallet update failed: ${resp.message}");
        errorMessage = resp.message ?? "Wallet update failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception in updateWallet: $e");
      errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<PaymentStatusResponse?> fetchPaymentStatus({
    required String merchantTransactionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url =
          "${UrlPath.biddingUrl.getPhonePeResponse}/$merchantTransactionId";
      debugPrint("🌍 [FETCH PAYMENT STATUS] URL: $url");

      final resp = await APIService.get(
        url,
        auth: true,
        shownoInternet: true,
        console: true,
        timeout: const Duration(seconds: 25),
      );

      debugPrint("📡 [PAYMENT STATUS] RESPONSE: ${resp.fullBody}");

      if (resp.status || resp.data != null) {
        _paymentStatus = PaymentStatusResponse.fromJson(resp.fullBody);
        errorMessage = null;
      } else {
        errorMessage = resp.message ?? "Failed to fetch payment status";
        _paymentStatus = null;
      }

      _isLoading = false;
      notifyListeners();
      return _paymentStatus;
    } catch (e) {
      debugPrint("❌ Error fetching payment status: $e");
      errorMessage = e.toString();
      _isLoading = false;
      _paymentStatus = null;
      notifyListeners();
      return null;
    }
  }

  /// 🔁 VERIFY PAYMENT & UPDATE WALLET (only if wallet used)
  Future<bool> verifyAndUpdateWallet({
    required String merchantTransactionId,
    required String walletUsed,
  }) async {
    try {
      debugPrint(
        "🔍 Verifying payment for transaction: $merchantTransactionId",
      );

      final status = await fetchPaymentStatus(
        merchantTransactionId: merchantTransactionId,
      );

      if (status == null) {
        debugPrint("⚠️ Could not fetch payment status");
        return false;
      }

      if (status.isSuccess) {
        debugPrint("✅ Payment Successful");

        if (walletUsed != "0") {
          debugPrint("💰 Wallet used. Updating user wallet...");
          await updateWallet(wallet: walletUsed);
        } else {
          debugPrint("🚫 No wallet used. Skipping update.");
        }

        return true;
      } else if (status.isPending) {
        debugPrint("⌛ Payment Pending — waiting for confirmation.");
        return false;
      } else {
        debugPrint("❌ Payment Failed");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error in verifyAndUpdateWallet: $e");
      return false;
    }
  }

 Future<void> getPickupTime({
  required String franchiseId,
  required String pickupDate,
}) async {
  _isPickupTimeLoading = true;
  notifyListeners();

  final url = "${UrlPath.biddingUrl.getPickupTime}/$franchiseId/$pickupDate";
  debugPrint("🌍 [PICKUP TIME] URL: $url");

  try {
    final resp = await APIService.post(
      url,
      data: {},
      auth: true,
      shownoInternet: true,
      console: true,
      timeout: const Duration(seconds: 20),
    );

    if (resp.status && resp.fullBody['data'] != null) {
      final List data = resp.fullBody['data'];
      _pickupTimes = PickupTimeModel.listFromJson(data);
      errorMessage = null;

      // ✅ Auto-select first available slot
      if (_pickupTimes.isNotEmpty) {
        _selectedPickupTime = _pickupTimes.first;
      }

      debugPrint("✅ Pickup times loaded: ${_pickupTimes.length}");
    } else {
      _pickupTimes = [];
      _selectedPickupTime = null;
      errorMessage = resp.message ?? "No pickup times available";
      debugPrint("⚠️ Pickup time load failed: ${resp.message}");
    }
  } catch (e) {
    debugPrint("❌ Exception in getPickupTime: $e");
    _pickupTimes = [];
    _selectedPickupTime = null;
    errorMessage = e.toString();
  } finally {
    _isPickupTimeLoading = false;
    notifyListeners();
  }
}

/// 🔁 Reload pickup times when date changes
Future<void> reloadPickupTime(String franchiseId, String newDate) async {
  debugPrint("🔁 Reloading pickup times for $newDate");
  await getPickupTime(franchiseId: franchiseId, pickupDate: newDate);
}
}
