import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_food_my_price/models/LocationModels/location_model.dart';
import 'package:my_food_my_price/services/secure_storage.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'dart:async';



class LocationService {
  /// Fetch and save current location
  static Future<void> fetchAndSaveLocation() async {
    try {
      final hasPermission = await _handlePermission();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      final apiKey = await SecureStorageService.readGoogleApiKey();
      if (apiKey == null) return;

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return;

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final components = data['results'][0]['address_components'] as List;

      String? pincode, state, district, areaName;
      for (var comp in components) {
        final types = List<String>.from(comp['types']);
        if (types.contains('postal_code')) pincode = comp['long_name'];
        if (types.contains('administrative_area_level_1'))
          state = comp['long_name'];
        if (types.contains('administrative_area_level_2'))
          district = comp['long_name'];
        if (types.contains('sublocality_level_3'))
          areaName = comp['short_name'];
      }

      if (district == null) {
        for (var comp in components) {
          final types = List<String>.from(comp['types']);
          if (types.contains('administrative_area_level_3')) {
            district = comp['long_name'];
            break;
          }
        }
      }

      final location = LocationModel(
        address: data['results'][0]['formatted_address'],
        state: state ?? '',
        district: district ?? '',
        pincode: pincode ?? '',
        latitude: position.latitude,
        longitude: position.longitude,
        areaName: areaName ?? '',
      );

      await SecureStorageService.write(
        AppConstants.location,
        json.encode(location.toJson()),
      );
      await SecureStorageService.write(AppConstants.state, state ?? '');
      await SecureStorageService.write(AppConstants.district, district ?? '');
      await SecureStorageService.write(AppConstants.pincode, pincode ?? '');
      await SecureStorageService.write(
          AppConstants.latitude, position.latitude.toString());
      await SecureStorageService.write(
          AppConstants.longitude, position.longitude.toString());
    } on TimeoutException {
      if (kDebugMode) print("⏳ Google API timeout.");
    } catch (e) {
      if (kDebugMode) print("❌ fetchAndSaveLocation error: $e");
    }
  }

  static Future<bool> _handlePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<LocationModel?> getSavedLocation() async {
    final jsonStr = await SecureStorageService.read(AppConstants.location);
    if (jsonStr == null) return null;
    try {
      return LocationModel.fromJson(json.decode(jsonStr));
    } catch (e) {
      if (kDebugMode) print("❌ Failed to decode saved location: $e");
      return null;
    }
  }

  static Future<LatLng?> getCurrentLatLng() async {
    final permission = await _handlePermission();
    if (!permission) return null;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    return LatLng(pos.latitude, pos.longitude);
  }

  static Future<Map<String, String>?> getAddressFromLatLng(
    LatLng latLng,
  ) async {
    try {
      final apiKey = await SecureStorageService.readGoogleApiKey();
      if (apiKey == null) return null;

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return null;

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final components = data['results'][0]['address_components'] as List;

      String? areaName;
      for (var comp in components) {
        final types = List<String>.from(comp['types']);
        if (types.contains('sublocality_level_3')) {
          areaName = comp['long_name'];
          break;
        }
      }
      areaName ??= _findFallbackArea(components);

      return {
        'areaName': areaName ?? '',
        'fullAddress': data['results'][0]['formatted_address'],
      };
    } on TimeoutException {
      if (kDebugMode) print("⏳ Timeout in getAddressFromLatLng.");
      return null;
    } catch (e) {
      if (kDebugMode) print("❌ getAddressFromLatLng error: $e");
      return null;
    }
  }

  static Future<bool> fetchAndSaveLocationFromLatLng(LatLng latLng) async {
    try {
      final apiKey = await SecureStorageService.readGoogleApiKey();
      if (apiKey == null) return false;

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) return false;

      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;

      final data = json.decode(response.body);
      final components = data['results'][0]['address_components'] as List;

      String? pincode, state, district, areaName;
      for (var comp in components) {
        final types = List<String>.from(comp['types']);
        if (types.contains('postal_code')) pincode = comp['long_name'];
        if (types.contains('administrative_area_level_1'))
          state = comp['long_name'];
        if (types.contains('administrative_area_level_2'))
          district = comp['long_name'];
      }

      areaName = _findFallbackArea(components);

      if (district == null) {
        for (var comp in components) {
          final types = List<String>.from(comp['types']);
          if (types.contains('administrative_area_level_3')) {
            district = comp['long_name'];
            break;
          }
        }
      }

      final location = LocationModel(
        address: data['results'][0]['formatted_address'],
        state: state ?? '',
        district: district ?? '',
        pincode: pincode ?? '',
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        areaName: areaName ?? '',
      );

      await SecureStorageService.write(
          AppConstants.location, json.encode(location.toJson()));
      await SecureStorageService.write(AppConstants.state, state ?? '');
      await SecureStorageService.write(AppConstants.district, district ?? '');
      await SecureStorageService.write(AppConstants.pincode, pincode ?? '');

      return true;
    } on TimeoutException {
      if (kDebugMode) print("⏳ Timeout in fetchAndSaveLocationFromLatLng.");
      return false;
    } catch (e) {
      if (kDebugMode) print("❌ Error saving latlng location: $e");
      return false;
    }
  }

  static String? _findFallbackArea(List components) {
    for (var comp in components) {
      final types = List<String>.from(comp['types']);
      if (types.contains('sublocality_level_2')) return comp['long_name'];
    }
    for (var comp in components) {
      final types = List<String>.from(comp['types']);
      if (types.contains('sublocality_level_1')) return comp['long_name'];
    }
    for (var comp in components) {
      final types = List<String>.from(comp['types']);
      if (types.contains('locality')) return comp['long_name'];
    }
    return null;
  }
}

// class LocationService {
//   static const String _googleApiKey =
//       'AIzaSyC1q5b6YQz6m_uBeE8r8R3jsK0gAdlePz0'; // 🔒 Move this to encrypted config in production

//   static Future<void> fetchAndSaveLocation() async {
//     if (kDebugMode) {
//       print("🔄 Checking location permission...");
//     }

//     final hasPermission = await _handlePermission();
//     if (!hasPermission) {
//       if (kDebugMode) print("❌ Location permission denied.");
//       return;
//     }

//     if (kDebugMode) print("📍 Fetching current location...");
//     final position = await Geolocator.getCurrentPosition(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     );

//     final apiKey = await SecureStorageService.readGoogleApiKey();
//     if (apiKey == null) return;

//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult == ConnectivityResult.none) return;

//     if (kDebugMode) {
//       print(
//         "✅ Location fetched: Lat: ${position.latitude}, Lng: ${position.longitude}",
//       );
//     }

//     final url =
//           'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

//     final response =
//           await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));


//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);

//       if (kDebugMode) {
//         print("🌐 Full Google API response:");
//         print(json.encode(data)); // print full JSON response
//       }

//       final components = data['results'][0]['address_components'] as List;

//       String? pincode, state, district, areaName;

//       for (var comp in components) {
//         final types = comp['types'];

//         if (types.contains('postal_code')) {
//           pincode = comp['long_name'];
//         }
//         if (types.contains('administrative_area_level_1')) {
//           state = comp['long_name'];
//         }
//         if (types.contains('administrative_area_level_2')) {
//           district = comp['long_name'];
//         }
//         if (types.contains('sublocality_level_3')) {
//           areaName = comp['short_name'];
//         }
//       }

//       // Fallback to administrative_area_level_3 if level_2 not available
//       if (district == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('administrative_area_level_3')) {
//             district = comp['long_name'];
//             break;
//           }
//         }
//       }

//       final location = LocationModel(
//         address: data['results'][0]['formatted_address'],
//         state: state ?? '',
//         district: district ?? '',
//         pincode: pincode ?? '',
//         latitude: position.latitude,
//         longitude: position.longitude,
//         areaName: areaName ?? '',
//       );

//       if (kDebugMode) {
//         print("📦 Location details:");
//         print("   Address: ${location.address}");
//         print("   State: ${location.state}");
//         print("   District: ${location.district}");
//         print("   Pincode: ${location.pincode}");
//       }

//       // Save full location model and individual values
//       await SecureStorageService.write(
//         AppConstants.location,
//         json.encode(location.toJson()),
//       );
//       await SecureStorageService.write(AppConstants.state, state ?? '');
//       await SecureStorageService.write(AppConstants.district, district ?? '');
//       await SecureStorageService.write(AppConstants.pincode, pincode ?? '');
//       await SecureStorageService.write(
//         AppConstants.latitude,
//         position.latitude.toString(),
//       );
//       await SecureStorageService.write(
//         AppConstants.longitude,
//         position.longitude.toString(),
//       );

//       if (kDebugMode) {
//         print(
//           "✅ Location saved to SecureStorage under key: ${AppConstants.location}",
//         );
//         print("   🔐 ${AppConstants.state} = ${state ?? ''}");
//         print("   🔐 ${AppConstants.district} = ${district ?? ''}");
//         print("   🔐 ${AppConstants.pincode} = ${pincode ?? ''}");
//       }
//     } else {
//       if (kDebugMode) print("❌ Failed to fetch location data from Google API.");
//     }
//   }

//   static Future<bool> _handlePermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     return permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse;
//   }

//   static Future<LocationModel?> getSavedLocation() async {
//     final jsonStr = await SecureStorageService.read(AppConstants.location);
//     if (jsonStr == null) {
//       if (kDebugMode) print("⚠️ No saved location found.");
//       return null;
//     }

//     if (kDebugMode) print("📂 Fetched saved location from SecureStorage.");
//     return LocationModel.fromJson(json.decode(jsonStr));
//   }

//   static Future<LatLng?> getCurrentLatLng() async {
//     final permission = await _handlePermission();
//     if (!permission) return null;

//     final pos = await Geolocator.getCurrentPosition(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10,
//       ),
//     );

//     return LatLng(pos.latitude, pos.longitude);
//   }

//   static Future<Map<String, String>?> getAddressFromLatLng(
//     LatLng latLng,
//   ) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$_googleApiKey';

//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final components = data['results'][0]['address_components'] as List;

//       String? areaName;

//       // Try sublocality_level_3
//       for (var comp in components) {
//         final types = comp['types'];
//         if (types.contains('sublocality_level_3')) {
//           areaName = comp['long_name'];
//           break;
//         }
//       }

//       // If still null, try sublocality_level_2
//       if (areaName == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('sublocality_level_2')) {
//             areaName = comp['long_name'];
//             break;
//           }
//         }
//       }

//       // If still null, try sublocality_level_1
//       if (areaName == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('sublocality_level_1')) {
//             areaName = comp['long_name'];
//             break;
//           }
//         }
//       }

//       // Last fallback: use locality
//       if (areaName == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('locality')) {
//             areaName = comp['long_name'];
//             break;
//           }
//         }
//       }

//       return {
//         'areaName': areaName ?? '',
//         'fullAddress': data['results'][0]['formatted_address'],
//       };
//     }
//     return null;
//   }

//   static Future<bool> fetchAndSaveLocationFromLatLng(LatLng latLng) async {
//     try {
//       final url =
//           'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$_googleApiKey';

//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode != 200) return false;

//       final data = json.decode(response.body);
//       final components = data['results'][0]['address_components'] as List;

//       String? pincode, state, district, areaName;

//       for (var comp in components) {
//         final types = comp['types'];

//         if (types.contains('postal_code')) pincode = comp['long_name'];
//         if (types.contains('administrative_area_level_1'))
//           state = comp['long_name'];
//         if (types.contains('administrative_area_level_2'))
//           district = comp['long_name'];
//       }

//       // Area fallback logic (same as in getAddressFromLatLng)
//       for (var comp in components) {
//         final types = comp['types'];
//         if (types.contains('sublocality_level_3')) {
//           areaName = comp['long_name'];
//           break;
//         }
//       }

//       if (areaName == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('sublocality_level_2')) {
//             areaName = comp['long_name'];
//             break;
//           }
//         }
//       }

//       if (areaName == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('sublocality_level_1')) {
//             areaName = comp['long_name'];
//             break;
//           }
//         }
//       }

//       if (areaName == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('locality')) {
//             areaName = comp['long_name'];
//             break;
//           }
//         }
//       }

//       // fallback district
//       if (district == null) {
//         for (var comp in components) {
//           final types = comp['types'];
//           if (types.contains('administrative_area_level_3')) {
//             district = comp['long_name'];
//             break;
//           }
//         }
//       }

//       final location = LocationModel(
//         address: data['results'][0]['formatted_address'],
//         state: state ?? '',
//         district: district ?? '',
//         pincode: pincode ?? '',
//         latitude: latLng.latitude,
//         longitude: latLng.longitude,
//         areaName: areaName ?? '',
//       );

//       await SecureStorageService.write(
//         AppConstants.location,
//         json.encode(location.toJson()),
//       );
//       await SecureStorageService.write(AppConstants.state, state ?? '');
//       await SecureStorageService.write(AppConstants.district, district ?? '');
//       await SecureStorageService.write(AppConstants.pincode, pincode ?? '');

//       if (kDebugMode) {
//         print("✅ Location saved from latlng:");
//         print("Area Name: ${areaName ?? ''}");
//         print("Full Address: ${location.address}");
//       }

//       return true;
//     } catch (e) {
//       if (kDebugMode) print("❌ Error saving latlng location: $e");
//       return false;
//     }
//   }
// }
