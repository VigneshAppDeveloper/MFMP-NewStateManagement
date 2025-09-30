import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/LocationModels/location_model.dart';
import '../services/location_service.dart';
import '../services/secure_storage.dart';
import '../util/app_contant.dart';

class LocationProvider extends ChangeNotifier {
  LocationModel? _gpsLocation;
  LocationModel? _sessionLocation;

  LocationModel? get currentLocation => _sessionLocation ?? _gpsLocation;

  Future<void> loadGpsLocation() async {
    await LocationService.fetchAndSaveLocation();
    _gpsLocation = await LocationService.getSavedLocation();
    notifyListeners();
  }

  void updateSessionLocation(LocationModel location) {
    _sessionLocation = location;
    notifyListeners();
  }

  void clearSessionLocation() {
    _sessionLocation = null;
    notifyListeners();
  }
}

