
import 'package:flutter/material.dart';

import '../models/LocationModels/location_model.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationModel? _gpsLocation;
  LocationModel? _sessionLocation;

  LocationModel? get currentLocation => _sessionLocation ?? _gpsLocation;

  Future<void> loadGpsLocation({BuildContext? context}) async {
    await LocationService.fetchAndSaveLocation(context: context);
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

