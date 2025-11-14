import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_food_my_price/models/LoginModels/profile_mode.dart';
import 'package:my_food_my_price/models/app_state_model.dart';
import 'package:my_food_my_price/util/app_contant.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();

 static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, s) {
      debugPrint("❌ SecureStorage write error: $e");
      FirebaseCrashlytics.instance.recordError(e, s, reason: "SecureStorage write failed");
    }
  }

   static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, s) {
      debugPrint("❌ SecureStorage read error: $e");
      FirebaseCrashlytics.instance.recordError(e, s, reason: "SecureStorage read failed ($key)");
      // If decryption fails, clear data for stability
      await _storage.delete(key: key);
      return null;
    }
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: "SecureStorage delete failed");
    }
  }

  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: "SecureStorage clearAll failed");
    }
  }

  static Future<AppStateModel> getUserAppState() async {
    try {
      final values = await Future.wait([
        read(AppConstants.token),
        read('is_first_register'),
        read('state_id'),
        read('district_id'),
      ]);

      return AppStateModel(
        token: values[0],
        isFirstRegister: values[1],
        stateId: values[2],
        districtId: values[3],
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: "getUserAppState failed");
      // Fallback: reset data if corrupted
      await clearAll();
      return AppStateModel();
    }
  }

   static Future<void> saveProfile(ProfileModel profile) async {
    try {
      await write('user_profile', jsonEncode(profile.toJson()));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: "saveProfile failed");
    }
  }

   static Future<ProfileModel?> readProfile() async {
    try {
      final json = await read('user_profile');
      if (json == null) return null;
      return ProfileModel.fromJson(jsonDecode(json));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: "readProfile failed");
      await delete('user_profile'); // Remove corrupted entry
      return null;
    }
  }

  static Future<void> clearAllAppData() async {
    await SecureStorageService.clearAll();
    AppConstants.profile = null;
    // if needed
    // Clear any other AppConstants here
  }


   static const _googleApiKeyKey = 'AIzaSyC1q5b6YQz6m_uBeE8r8R3jsK0gAdlePz0';

  static Future<void> saveGoogleApiKey(String apiKey) async {
    await write(_googleApiKeyKey, apiKey);
  }

  static Future<String?> readGoogleApiKey() async {
    return await read(_googleApiKeyKey);
  }

  static Future<void> deleteGoogleApiKey() async {
    await delete(_googleApiKeyKey);
  }
}
