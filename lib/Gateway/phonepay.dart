import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonePeGateway {
  static const String _merchantId = "BIRYANIPALAYAMONLINE";
  static const String _saltKey = "a6ca06a7-8b49-45f1-89b6-483e63a6076c";
  static const String _saltIndex = "1";
  static const String _callbackUrl =
      "https://mfmpdev.tsitcloud.com/tsit_biriyani_palayam-dev/public/api/phonepe_response";

  static const bool _enableLogs = true;
  static const String _environment = "PRODUCTION";
  static const String _packageName = "com.biryanipalayam.myfoodmyprice";

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await PhonePePaymentSdk.init(
        _environment,
        _packageName,
        _merchantId,
        _enableLogs,
      );
      _initialized = true;
      debugPrint("✅ PhonePe SDK initialized successfully");
    } catch (e) {
      debugPrint("❌ Error initializing PhonePe SDK: $e");
    }
  }

  // ✅ Proper Base64 encoding
  static String _createTransactionBody({
    required double amount,
    required String merchantTransactionId,
    required String merchantUserId,
  }) {
    final Map<String, dynamic> reqData = {
      "merchantId": _merchantId,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": merchantUserId,
      "amount": (amount * 100).toInt(), // paise
      "callbackUrl": _callbackUrl,
      "paymentInstrument": {"type": "PAY_PAGE"},
    };

    // Encode once — JSON → UTF8 → Base64
    final String base64Body = base64Encode(utf8.encode(jsonEncode(reqData)));

    debugPrint("📦 Transaction JSON: ${jsonEncode(reqData)}");
    debugPrint("📦 Encoded Body: $base64Body");

    return base64Body;
  }

  // ✅ Generate checksum
  static String _generateChecksum(String base64Body) {
    final String rawData = base64Body + "/pg/v1/pay" + _saltKey;
    final String hash = sha256.convert(utf8.encode(rawData)).toString();
    final String checksum = "$hash###$_saltIndex";
    debugPrint("🔑 Generated Checksum: $checksum");
    return checksum;
  }

  static Future<Map<String, dynamic>?> startPayment({
    required double amount,
    required String transactionId,
    required String userId,
  }) async {
    try {
      await init();

      final String base64Body = _createTransactionBody(
        amount: amount,
        merchantTransactionId: transactionId,
        merchantUserId: userId,
      );

      final String checksum = _generateChecksum(base64Body);

      // ✅ 4 parameters: (body, callbackUrl, checksum, packageName)
      final response = await PhonePePaymentSdk.startTransaction(
        base64Body,
        _callbackUrl,
        checksum,
        _packageName,
      );

      debugPrint("📡 Payment Response: $response");

      if (response != null && response is Map<String, dynamic>) {
        return {
          "status": response["status"]?.toString() ?? "UNKNOWN",
          "error": response["error"]?.toString(),
        };
      } else {
        return {"status": "FAILED", "error": "Invalid response"};
      }
    } catch (e, s) {
      debugPrint("❌ startPayment error: $e\n$s");
      return {"status": "FAILED", "error": e.toString()};
    }
  }
}
// class PhonePeGateway {
//   static const String _merchantId = "BIRYANIPALAYAMONLINE";
//   static const String _saltKey = "a6ca06a7-8b49-45f1-89b6-483e63a6076c";
//   static const String _saltIndex = "1";
//   static const String _callbackUrl =
//       "https://tabsquareinfotech.com/App/Clients/biriyani_palayam/public/api/phonepe_response";

//   static const bool _enableLogs = true;
//   static const String _environment = "PRODUCTION";
//   static const String _appSchema = "com.biryanipalayam.myfoodmyprice"; // must match AndroidManifest.xml intent-filter

//   static bool _initialized = false;

//   /// ✅ Initialize SDK once
//   static Future<void> init({String userId = "defaultFlow"}) async {
//     if (_initialized) return;
//     try {
//       await PhonePePaymentSdk.init(
//         _environment,
//         _merchantId,
//         userId,
//         _enableLogs,
//       );
//       _initialized = true;
//       debugPrint("✅ PhonePe SDK initialized successfully");
//     } catch (e) {
//       debugPrint("❌ Error initializing PhonePe SDK: $e");
//     }
//   }

//   /// ✅ Build payment request payload
//   static String _createRequestBody({
//     required double amount,
//     required String merchantTransactionId,
//     required String merchantUserId,
//   }) {
//     final Map<String, dynamic> data = {
//       "merchantId": _merchantId,
//       "merchantTransactionId": merchantTransactionId,
//       "merchantUserId": merchantUserId,
//       "amount": (amount * 100).toInt(),
//       "callbackUrl": _callbackUrl,
//       "paymentInstrument": {"type": "PAY_PAGE"},
//     };

//     final encoded = base64.encode(utf8.encode(json.encode(data)));
//     debugPrint("📦 Encoded Payment Request: $data");
//     return encoded;
//   }

//   /// ✅ Generate checksum
//   static String _generateChecksum(String base64Body) {
//     String rawData = base64Body + "/pg/v1/pay" + _saltKey;
//     String sha = sha256.convert(utf8.encode(rawData)).toString();
//     return "$sha###$_saltIndex";
//   }

//   /// ✅ Start a payment
//   static Future<Map<String, dynamic>?> startPayment({
//     required double amount,
//     required String transactionId,
//     required String userId,
//   }) async {
//     try {
//       await init(userId: userId);
//       final request = _createRequestBody(
//         amount: amount,
//         merchantTransactionId: transactionId,
//         merchantUserId: userId,
//       );
//       final checksum = _generateChecksum(request);

//       final response = await PhonePePaymentSdk.startTransaction(
//         request,
//         _appSchema,
//       );

//       debugPrint("📡 Payment Response: $response");

//       if (response != null && response is Map<String, dynamic>) {
//         return {
//           "status": response["status"]?.toString() ?? "UNKNOWN",
//           "error": response["error"]?.toString(),
//         };
//       } else {
//         return {"status": "FAILED", "error": "Invalid response"};
//       }
//     } catch (e, s) {
//       debugPrint("❌ startPayment error: $e\n$s");
//       return {"status": "FAILED", "error": e.toString()};
//     }
//   }

//   /// ✅ Fetch installed UPI apps (for your custom UI)
//   static Future<List<Map<String, dynamic>>> getInstalledUpiApps() async {
//     try {
//       if (Platform.isAndroid) {
//         final result = await PhonePePaymentSdk.getUpiAppsForAndroid();
//         if (result != null) {
//           final decoded = json.decode(result);
//           return List<Map<String, dynamic>>.from(decoded);
//         }
//       } else if (Platform.isIOS) {
//         final result = await PhonePePaymentSdk.getInstalledUpiAppsForiOS();
//         if (result != null) {
//           return List<Map<String, dynamic>>.from(
//               result.map((e) => {"appName": e}));
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Error fetching installed UPI apps: $e");
//     }
//     return [];
//   }
// }