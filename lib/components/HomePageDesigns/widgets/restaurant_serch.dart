import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../../../Providers/location_provider.dart';
import '../../../Providers/restaurant_provider.dart';
import '../../../route_generator.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/app_shimmer.dart';
import '../../../widgets/shimmer_type.dart';
import '../home_search_bar.dart';
import '../restaurant_wiget.dart';

class RestaurantSearchPage extends StatefulWidget {
  final bool isFlash;
  const RestaurantSearchPage({super.key, this.isFlash = false});

  @override
  State<RestaurantSearchPage> createState() => _RestaurantSearchPageState();
}

class _RestaurantSearchPageState extends State<RestaurantSearchPage> {
  late final TextEditingController _searchController;
  Set<String> selectedFilters = {};
  late final ScrollController _scrollController;
  Timer? _debounce;
  late RestaurantProvider provider;
 String _currentQuery = '';
  //final provider = context.read<RestaurantProvider>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider =
        context.read<RestaurantProvider>(); // ✅ safe place to get provider
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    provider.clearSearchResults(); // ✅ safe now
    super.dispose();
  }
void _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final location = context.read<LocationProvider>().currentLocation;
      if (location != null && _currentQuery.isNotEmpty) {
        await provider.loadNextPageIfNeeded(
          lat: location.latitude,
          lng: location.longitude,
          isFlash: widget.isFlash,
          forSearchPage: true,
          search: _currentQuery,
        );
      }
    }
  }
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
       _currentQuery = query;
      _onSearchSubmit(query);
    });
  }

  void _onSearchSubmit(String query) async {
    final location = context.read<LocationProvider>().currentLocation;
    if (location == null) return;
    debugPrint("🔎 isFlash from widget: ${widget.isFlash}");
    await context.read<RestaurantProvider>().getRestaurants(
      lat: location.latitude,
      lng: location.longitude,
      isFlash: widget.isFlash,
      search: query,
      forSearchPage: true,
    );
  }

  void _onFilterApply() async {
    final location = context.read<LocationProvider>().currentLocation;
    if (location == null) return;

    final Map<String, dynamic> filterParams = {};

    if (selectedFilters.contains('veg')) filterParams['pure_veg'] = 1;
    if (selectedFilters.contains('nonveg')) filterParams['pure_veg'] = 0;
    if (selectedFilters.contains('halal')) filterParams['halal'] = 1;
    if (selectedFilters.contains('halal_living'))
      filterParams['halal_living'] = 1;

    await context.read<RestaurantProvider>().getRestaurants(
      lat: location.latitude,
      lng: location.longitude,
      isFlash: widget.isFlash,
      filters: filterParams,
      forSearchPage: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CommonAppBar(title: "Search Restaurants", showBack: true),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            children: [
              HomeSearchBar(
                controller: _searchController,
                enableNavigation: false, // 👈 disables re-navigation
                onFilterTap: () => _openFilterSheet(context),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 10),

              Expanded(
                child: provider.isLoading 
                    ? const AppShimmer(type: ShimmerType.restaurant)
                    : provider.searchResults.isEmpty
                        ? const Center(child: Text("No restaurants found"))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: provider.searchResults.length +
                                (provider.isPaginating ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (provider.isPaginating &&
                                  index == provider.searchResults.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child:
                                      Center(child: CircularProgressIndicator()),
                                );
                              }

                              final restaurant =
                                  provider.searchResults[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: GestureDetector(
                                  onTap: () => AppRouteName.menuPage.push(
                                    context,
                                    args: {
                                      'restaurant': restaurant,
                                      'showPriceTabs': true,
                                    },
                                  ),
                                  child: RestaurantCard(data: restaurant),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        Set<String> temp = Set.from(selectedFilters);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
                top: size.height * 0.02,
                bottom: MediaQuery.of(context).viewInsets.bottom + 90,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filter Restaurants",
                    style: Styles.textStyleMediumBold(context),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _filterChip("Veg", "veg", temp, setModalState),
                      _filterChip("Non-Veg", "nonveg", temp, setModalState),
                      _filterChip("Halal", "halal", temp, setModalState),
                      _filterChip(
                        "Halal Living",
                        "halal_living",
                        temp,
                        setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilters.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Clear",
                          style: Styles.textStyleMediumBold(context),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => selectedFilters = temp);
                          Navigator.pop(context);
                          _onFilterApply();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.maincolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Apply"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip(
    String label,
    String value,
    Set<String> temp,
    void Function(void Function()) setModalState,
  ) {
    final isSelected = temp.contains(value);
    return FilterChip(
      label: Text(
        label,
        style: Styles.textSmall(
          context,
          color: isSelected ? AppColor.maincolor : Colors.black,
        ),
        textScaler: TextScaler.linear(1.0),
      ),
      selected: isSelected,
      selectedColor: AppColor.maincolor.withOpacity(0.15),
      backgroundColor: Colors.grey.shade100,
      onSelected: (_) {
        setModalState(() {
          if (temp.contains(value)) {
            temp.remove(value);
          } else {
            temp.add(value);
          }
        });
      },
      labelStyle: Styles.textSmall(
        context,
        color: isSelected ? AppColor.maincolor : Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColor.maincolor : Colors.grey.shade300,
        ),
      ),
    );
  }
}
