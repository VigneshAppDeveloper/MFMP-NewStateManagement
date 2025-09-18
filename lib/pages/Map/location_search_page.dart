import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_food_my_price/pages/Map/confirm_location_map_page.dart';
import 'package:my_food_my_price/services/location_service.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key});

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> predictions = [];
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final text = _searchController.text.trim();
    if (text.isNotEmpty) {
      _autocompleteSearch(text);
    } else {
      setState(() => predictions.clear());
    }
  }

  Future<void> _autocompleteSearch(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${AppConstants.googleApiKey}&components=country:in';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() => predictions = data['predictions']);
    }
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList('recent_searches') ?? [];
    setState(() => recentSearches = items);
  }

  Future<void> _saveRecentSearch(String place) async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches.remove(place);
    recentSearches.insert(0, place);
    if (recentSearches.length > 5) {
      recentSearches = recentSearches.sublist(0, 5);
    }
    await prefs.setStringList('recent_searches', recentSearches);
  }

  Future<void> _selectPlace(String description, [String? placeId]) async {
    _saveRecentSearch(description);

    // Get location details from placeId
    if (placeId == null) return;
    final detailUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${AppConstants.googleApiKey}';

    final response = await http.get(Uri.parse(detailUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final location = jsonData['result']['geometry']['location'];
      final lat = location['lat'];
      final lng = location['lng'];

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmLocationMapPage(latLng: LatLng(lat, lng)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              "Enter your area or apartment name",
              style: Styles.textStyleMedium(
                context,
                color: Colors.black,
              ).copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              textScaler: TextScaler.linear(1.0),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: TextField(
                controller: _searchController,
                cursorColor: Colors.black,
                style: Styles.textSmall(context),
                decoration: InputDecoration(
                  hintText: "Search",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: .5),

                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: .5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: .5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: .5),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => predictions.clear());
                    },
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_location, color: Colors.orange),
            title: Text(
              "Use my current location",
              style: Styles.textSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
              textScaler: TextScaler.linear(1),
            ),
            onTap: () async {
              final userLatLng = await LocationService.getCurrentLatLng();
              if (userLatLng != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmLocationMapPage(latLng: userLatLng),
                  ),
                );
              }
            },
          ),
          const Divider(height: 1),
          if (_searchController.text.isEmpty && recentSearches.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "RECENT SEARCHES",
                style: Styles.textExtraSmall(context),
                textScaler: TextScaler.linear(1),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  predictions.isNotEmpty
                      ? predictions.length
                      : recentSearches.length,
              itemBuilder: (context, index) {
                if (predictions.isNotEmpty) {
                  final prediction = predictions[index];
                  final description = prediction['description'];
                  final placeId = prediction['place_id'];
                  return ListTile(
                    leading: const Icon(Icons.location_pin),
                    title: Text(
                      description,
                      style: Styles.textSmall(context),
                      textScaler: TextScaler.linear(1),
                    ),
                    onTap: () => _selectPlace(description, placeId),
                  );
                } else {
                  final text = recentSearches[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                      text,
                      style: Styles.textSmall(context),
                      textScaler: TextScaler.linear(1),
                    ),
                    onTap: () => _searchController.text = text,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
