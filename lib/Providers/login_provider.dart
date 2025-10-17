import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_food_my_price/enums/enum.dart';
import 'package:my_food_my_price/models/LoginModels/login_model.dart';
import 'package:my_food_my_price/models/LoginModels/profile_mode.dart';
import 'package:my_food_my_price/models/api_validation_model.dart';
import 'package:my_food_my_price/services/api_service.dart';
import 'package:my_food_my_price/services/device_info.dart';
import 'package:my_food_my_price/services/location_service.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/exception.dart';
import 'package:my_food_my_price/util/global.dart';
import 'package:my_food_my_price/util/simple_stream.dart';
import 'package:my_food_my_price/util/url_path.dart';

import '../widgets/dilogue/dilogue.dart';

class LoginProvider extends ChangeNotifier {
  bool isApiValidationError = false;

  Future<void> initialFetch() async {
    AppGlobal.deviceInfo = await DeviceInfoServices.getDeviceInfo();
  }

  Future<APIResp> sendOTP({required String mobile}) async {
    debugPrint("🚀 Sending OTP to: $mobile"); // 👈

    final resp = await APIService.post(
      UrlPath.loginUrl.sendOTP,
      data: {"mobile": mobile},
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    debugPrint(
      "✅ sendOTP Response: status=${resp.status} | data=${resp.data}",
    ); // 👈

    if (resp.status) {
      isApiValidationError = false;
      return resp;
    }

    if (resp.data == "Validation Error") {
      debugPrint("⚠️ Validation Error: ${resp.fullBody}");
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    }

    debugPrint("❌ Throwing APIException: ${resp.data}");
    isApiValidationError = false;
    throw APIException(
      type: APIErrorType.auth,
      message: resp.data?.toString() ?? "Invalid credential. Please try again!",
    );
  }

  Future<APIResp> resendOTP({required String mobile}) async {
    final resp = await APIService.post(
      UrlPath.loginUrl.sendOTP,
      data: {"mobile": mobile},
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    if (resp.status) {
      isApiValidationError = false;
      return resp;
    }

    if (resp.data == "Validation Error") {
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    }

    isApiValidationError = false;
    throw APIException(
      type: APIErrorType.auth,
      message: resp.data?.toString() ?? "Invalid credential. Please try again!",
    );
  }

  Future<APIResp> verifyOtp({
    required String mobile,
    required String otp,
    required String tokenFCM,
  }) async {
    final resp = await APIService.post(
      UrlPath.loginUrl.otpVerify,
      data: {
        "mobile": mobile.replaceAll(RegExp(r'[^0-9]'), ''),
        "otp": otp,
        "device_token": tokenFCM,
      },
      shownoInternet: false,
      auth: false,
      forceLogout: false,
      console: true,
      timeout: const Duration(seconds: 30),
    );

    if (resp.status) {
      LoginModel data = LoginModel.fromMap(resp.fullBody);

      if (data.token != null && data.token!.isNotEmpty) {
        await SecureStorageService.write(AppConstants.token, data.token!);
        await getProfile();

        /// ✅ Optional: Fetch & save location
        await LocationService.fetchAndSaveLocation();
      }

      return resp;
    } else if (!resp.status && resp.data == "Validation Error") {
      AppConstants.apiValidationModel = ApiValidationModel.fromJson(
        resp.fullBody,
      );
      isApiValidationError = true;
      notifyListeners();
      return resp;
    } else {
      throw APIException(
        type: APIErrorType.toast,
        message:
            resp.data?.toString() ?? "Invalid credential. Please try again!",
      );
    }
  }

  SimpleStream<ProfileModel?> userData = SimpleStream<ProfileModel?>(null);

  Future<SimpleStream<ProfileModel?>> getProfile() async {
    final url = UrlPath.loginUrl.getProfile;

    return await APIService.basic.getStreamList<ProfileModel?>(
      data: userData,
      auth: true,
      isPost: false,
      postData: {}, // For GET, this is harmless
      refresh: () {}, // ✅ Fix for function type
      path: url,
      toJson: (resp) {
        if (resp.data is! Map<String, dynamic>) {
          throw Exception("Invalid response format");
        }

        final profile = ProfileModel.fromJson(
          resp.data as Map<String, dynamic>,
        );

        // ✅ Fix fromMap issue

        AppConstants.profile = profile;
        SecureStorageService.saveProfile(profile);

        return profile;
      },
    );
  }

  /// 🔹 Update User Profile
  Future<APIResp> updateUserProfile({
    String? name,
    String? email,
    File? userImage,
  }) async {
    final url = UrlPath.loginUrl.updateProfile;
    debugPrint("🚀 Updating user profile at: $url");

    try {
      // Build payload dynamically — only changed fields
      final Map<String, dynamic> payload = {};

      final profile = AppConstants.profile;
      if (name != null &&
          name.trim().isNotEmpty &&
          name.trim() != profile?.name) {
        payload["name"] = name.trim();
      }
      if (email != null &&
          email.trim().isNotEmpty &&
          email.trim() != profile?.email) {
        payload["email"] = email.trim();
      }
      if (userImage != null) {
        payload["user_image"] = await MultipartFile.fromFile(
          userImage.path,
          filename: userImage.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(payload);

      final resp = await APIService.post(
        url,
        data: formData,
        auth: true,
        shownoInternet: true,
        forceLogout: true,
        console: true,
        timeout: const Duration(seconds: 30),
      );

      debugPrint("✅ updateUserProfile Response: ${resp.fullBody}");

      if (resp.status) {
        await getProfile(); // refresh local profile
        AppDialogue.toast("Profile updated successfully");
        return resp;
      } else if (resp.message?.contains("Validation Error") ?? false) {
        final validation = resp.fullBody["validation Error"];
        if (validation != null) {
          final msg = validation.values.first.first ?? "Validation error";
          AppDialogue.toast(msg);
        }
        throw APIException(
          type: APIErrorType.toast,
          message: "Validation Error",
        );
      } else {
        throw APIException(
          type: APIErrorType.toast,
          message: resp.message ?? "Profile update failed",
        );
      }
    } catch (e, st) {
      debugPrint("❌ Error updating profile: $e\n$st");
      throw APIException(
        type: APIErrorType.toast,
        message: "Error updating profile: $e",
      );
    }
  }

  /// 🔹 Delete User Account
  Future<APIResp> deleteUserAccount() async {
    final url = UrlPath.loginUrl.deleteAccount; // 👈 endpoint constant
    debugPrint("🚀 Deleting user account at: $url");

    try {
      // 🔸 API call (POST without body)
      final resp = await APIService.post(
        url,
        data: {}, // No payload
        auth: true,
        shownoInternet: true,
        forceLogout: false,
        console: true,
        timeout: const Duration(seconds: 30),
      );

      debugPrint("✅ deleteUserAccount Response: ${resp.fullBody}");

      if (resp.status) {
        // ✅ Clear all user data from storage
      await SecureStorageService.clearAllAppData();


        // ✅ Optionally, trigger logout UI state
        notifyListeners();

        AppDialogue.toast(resp.message ?? "Account deleted successfully");
        return resp;
      } else {
        throw APIException(
          type: APIErrorType.toast,
          message: resp.message ?? "Failed to delete account",
        );
      }
    } catch (e, st) {
      debugPrint("❌ Error deleting account: $e\n$st");
      throw APIException(
        type: APIErrorType.toast,
        message: "Error deleting account: $e",
      );
    }
  }
}
