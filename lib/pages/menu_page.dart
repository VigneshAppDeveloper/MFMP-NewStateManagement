import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../Providers/add_bidder_provider.dart';
import '../Providers/cart_provider.dart';
import '../Providers/menu_provider.dart';
import '../components/HomePageDesigns/home_search_bar.dart';
import '../components/ResturantMenuDesigns/pickup_date_pickup_point.dart';
import '../components/ResturantMenuDesigns/resturant_menu_card.dart';
import '../components/ResturantMenuDesigns/resturant_menu_header.dart';
import '../components/ResturantMenuDesigns/time_slot_card_ui.dart';
import '../models/FoodModels/resturant_menu_model.dart';
import '../models/Resturant Model/resturant.dart';
import '../route_generator.dart';
import '../util/color_constant.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/dilogue/dilogue.dart';
import '../widgets/shimmer_type.dart';

class MenuPage extends StatefulWidget with WidgetsBindingObserver {
  final Restaurant restaurant;
  final bool showPriceTabs;

  const MenuPage({
    super.key,
    required this.restaurant,
    this.showPriceTabs = true,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with WidgetsBindingObserver {
  late final TextEditingController searchController;
  String selectedTab = "Fixed Discount Price"; // default tab
  late MenuProvider provider;
  late final CartProvider _cartProvider;

  List<RestaurantMenuModel> filteredMenus = [];
  Timer? _debounce;
  bool isSearching = false;

  bool isFiltering = false;
  Set<String> selectedFilters = {};

  bool hasBiddingMenu = false;

  final GlobalKey<PickupDatePickupPointState> _pickupKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    searchController = TextEditingController();
    _cartProvider = context.read<CartProvider>();

    provider = context.read<MenuProvider>();
    provider.setActive(true);

    Future.microtask(() async {
      // Fetch only if no cached menu or expired
      await provider.getRestaurantMenu(
        widget.restaurant.franchiseId,
        forceRefresh: false,
        isFlash: !widget.showPriceTabs,
      );
      // ✅ Check if any bidding-type menu exists
      final biddingExists = provider.menus.any(
        (m) => m.menuType.toLowerCase().trim() == 'bidding',
      );
      if (!mounted) return;
      setState(() => hasBiddingMenu = biddingExists);
      if (!mounted) return;
      if (widget.showPriceTabs && biddingExists) {
        provider.resumeAutoUpdaters(widget.restaurant.franchiseId);
        if (provider.timeSlots.isNotEmpty) {
          await provider.refreshTimeSlot(widget.restaurant.franchiseId);
        }
      } else {
        provider.stopAutoUpdaters();
      }
    });
  }

  /// 🧩 Lifecycle handler (pause/resume app)
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;

    // ✅ Only resume if MenuPage is the visible screen
    final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
    if (!isVisible) return;

    if (state == AppLifecycleState.paused) {
      provider.stopAutoUpdaters();
    } else if (state == AppLifecycleState.resumed && provider.isActivePage) {
      provider.resumeAutoUpdaters(widget.restaurant.franchiseId);
      await provider.refreshTimeSlot(widget.restaurant.franchiseId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    provider.setActive(false);
    provider.stopAutoUpdaters();
    provider.clearPickupSelections(); // 👈 safe — no context used
    _cartProvider.clearCart();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final provider = context.read<MenuProvider>();
      final all = provider.menus;
      final q = query.trim().toLowerCase();

      if (q.isEmpty) {
        setState(() {
          isSearching = false;
          filteredMenus.clear();
        });
        return;
      }

      final results =
          all.where((m) {
            final name = m.menuName.toLowerCase().trim();
            final desc = m.description?.toLowerCase().trim() ?? "";
            return name.contains(q) || desc.contains(q);
          }).toList();

      setState(() {
        isSearching = true;
        filteredMenus = results;
      });
    });
  }

  void _openFilterSheet() {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        Set<String> tempFilters = Set.from(selectedFilters);

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
                    "Filter Menu",
                    style: Styles.textStyleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  const SizedBox(height: 14),

                  // 🔹 Chips Row
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _buildFilterChipModal(
                        "Vegetarian",
                        "Vegetarian",
                        tempFilters,
                        setModalState,
                      ),
                      _buildFilterChipModal(
                        "Non-Vegetarian",
                        "Non-Vegetarian",
                        tempFilters,
                        setModalState,
                      ),
                      _buildFilterChipModal(
                        "Halal",
                        "halal",
                        tempFilters,
                        setModalState,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFilters.clear();
                            isFiltering = false;
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.maincolor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedFilters = Set.from(tempFilters);
                            isFiltering = selectedFilters.isNotEmpty;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply",
                          textScaler: TextScaler.linear(1.0),
                        ),
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

  Widget _buildFilterChipModal(
    String label,
    String value,
    Set<String> tempFilters,
    void Function(void Function()) setModalState,
  ) {
    final bool isSelected = tempFilters.contains(value);

    return FilterChip(
      label: Text(label, textScaler: const TextScaler.linear(1.0)),
      selected: isSelected,
      selectedColor: AppColor.maincolor.withOpacity(0.15),
      backgroundColor: Colors.grey.shade100,
      onSelected: (_) {
        setModalState(() {
          // 🟢 Veg = single select, others combine
          if (value == 'Vegetarian') {
            tempFilters
              ..clear()
              ..add('Vegetarian');
          } else {
            if (tempFilters.contains(value)) {
              tempFilters.remove(value);
            } else {
              tempFilters.remove('Vegetarian');
              tempFilters.add(value);
            }
          }
        });
      },
      labelStyle: TextStyle(
        color: isSelected ? AppColor.maincolor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppColor.maincolor : Colors.grey.shade300,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cart = context.watch<CartProvider>();
    final provider = context.watch<MenuProvider>();
    final selectedPickupDate = provider.selectedPickupDate;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.maincolor,
          onRefresh: () async {
            final provider = context.read<MenuProvider>();

            // ✅ If this is a flash sale page (no tabs)
            if (!widget.showPriceTabs) {
              await provider.getRestaurantMenu(
                widget.restaurant.franchiseId,
                forceRefresh: true,
                isFlash: true, // ✅ ensure stays in flash mode
              );
              return;
            }

            // ✅ Normal (non-flash) mode
            if (selectedTab == "Fixed Discount Price") {
              await provider.getRestaurantMenu(
                widget.restaurant.franchiseId,
                forceRefresh: true,
                isFlash: false,
              );
            } else {
              await provider.getTimeSlot(
                widget.restaurant.franchiseId,
                forceRefresh: true,
              );
            }
          },

          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

                /// 🏠 Restaurant header
                SliverToBoxAdapter(
                  child: ResturantMenuHeader(restaurant: widget.restaurant),
                ),

                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

                /// 📦 Pickup date + pickup point
                SliverToBoxAdapter(
                  child: PickupDatePickupPoint(
                    key: _pickupKey,
                    restaurant: widget.restaurant,
                    fromFlashPage: !widget.showPriceTabs,
                    onMenuReloaded: (bool hasBidding) {
                      // ✅ Safely update local flag and rebuild tabs dynamically
                      if (mounted) {
                        setState(() {
                          hasBiddingMenu = hasBidding;
                        });
                      }

                      // ✅ Control auto-updaters based on menu type
                      if (widget.showPriceTabs && hasBidding) {
                        provider.resumeAutoUpdaters(
                          widget.restaurant.franchiseId,
                        );
                      } else {
                        provider.stopAutoUpdaters();
                      }
                    },
                  ),
                ),

                /// 💰 Two clickable tabs
                if (widget.showPriceTabs && hasBiddingMenu)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.01,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (selectedTab != "Fixed Discount Price") {
                                  setState(
                                    () => selectedTab = "Fixed Discount Price",
                                  );
                                  // fetch only if menu empty
                                  final provider = context.read<MenuProvider>();
                                  if (provider.menus.isEmpty) {
                                    provider.getRestaurantMenu(
                                      widget.restaurant.franchiseId,
                                      forceRefresh: false,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.015,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      selectedTab == "Fixed Discount Price"
                                          ? Colors.black
                                          : Colors.grey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Fixed Discount Price",
                                  style: Styles.textSmall(
                                    context,
                                    color: Colors.white,
                                  ),
                                  textScaler: const TextScaler.linear(1.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (hasBiddingMenu)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (selectedTab != "Price Discovery") {
                                    setState(
                                      () => selectedTab = "Price Discovery",
                                    );
                                    // fetch only if not already loaded
                                    final provider =
                                        context.read<MenuProvider>();
                                    if (provider.timeSlots.isEmpty) {
                                      provider.getTimeSlot(
                                        widget.restaurant.franchiseId,
                                        forceRefresh: false,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: size.height * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedTab == "Price Discovery"
                                            ? Colors.black
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Price Discovery",
                                    style: Styles.textSmall(
                                      context,
                                      color: Colors.white,
                                    ),
                                    textScaler: const TextScaler.linear(1.0),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                if (selectedTab == "Fixed Discount Price" &&
                    (provider.isFlashMode ||
                        provider.selectedPickupDate != null))
                  SliverToBoxAdapter(
                    child: SizedBox(height: size.height * 0.02),
                  ),

                /// 🔍 Search bar
                if (selectedTab == "Fixed Discount Price" &&
                    (provider.isFlashMode ||
                        provider.selectedPickupDate != null))
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    floating: true,
                    snap: true,
                    elevation: 0,
                    toolbarHeight: size.height * 0.075,
                    automaticallyImplyLeading: false,
                    flexibleSpace: HomeSearchBar(
                      controller: searchController,
                      enableNavigation: false,
                      onFilterTap: _openFilterSheet,
                      onChanged: _onSearchChanged, // ✅ connect
                      hintText: "Search Dishes",
                    ),
                  ),
                if (isFiltering)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isFiltering = false;
                            selectedFilters.clear();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.symmetric(
                            horizontal: size.width * 0.25,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.maincolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            "Clear Filters ✕",
                            style: Styles.textSmall(
                              context,
                              color: AppColor.maincolor,
                            ).copyWith(fontWeight: FontWeight.w600),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.00)),

                /// 🍱 Menu List or TimeSlot List
                Consumer<MenuProvider>(
                  builder: (context, provider, _) {
                    // ===================== FIXED DISCOUNT TAB =====================
                    if (selectedTab == "Fixed Discount Price") {
                      if (provider.isLoading) {
                        return SliverToBoxAdapter(
                          child: const AppShimmer(type: ShimmerType.menu),
                        );
                      }

                      final allMenus =
                          provider.isFlashMode
                              ? provider.menus
                              : provider.menus.where((m) {
                                final type = m.menuType.toLowerCase().trim();
                                return type == "fixed price" ||
                                    type == "fixed discount" ||
                                    type == "fixed discount price";
                              }).toList();

                      List<RestaurantMenuModel> displayMenus =
                          isSearching ? filteredMenus : allMenus;

                      // ✅ Apply filters (Veg / Non-Veg / Halal)
                      if (selectedFilters.isNotEmpty) {
                        displayMenus =
                            displayMenus.where((m) {
                              final diet =
                                  (m.dietType ?? "").toLowerCase().trim();
                              final halal = (m.halal ?? "").trim();

                              final isVeg = diet == "vegetarian";
                              final isNonVeg = diet == "non-vegetarian";
                              final isHalal = halal == "1";

                              // User selected "Vegetarian"
                              if (selectedFilters.contains("Vegetarian")) {
                                return isVeg;
                              }

                              // User selected "Non-Vegetarian"
                              if (selectedFilters.contains("Non-Vegetarian") &&
                                  !selectedFilters.contains("halal")) {
                                return isNonVeg;
                              }

                              // User selected "Halal" only → should show only NON-VEG + HALAL
                              if (selectedFilters.contains("halal") &&
                                  !selectedFilters.contains("Non-Vegetarian")) {
                                return isHalal && isNonVeg;
                              }

                              // User selected both NON-VEG + HALAL
                              if (selectedFilters.contains("Non-Vegetarian") &&
                                  selectedFilters.contains("halal")) {
                                return isNonVeg && isHalal;
                              }

                              return true;
                            }).toList();
                      }

                      if (displayMenus.isEmpty) {
                        final msg =
                            selectedFilters.isNotEmpty
                                ? "No menu items match your selected filters"
                                : "No fixed price menu available";

                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: size.height * 0.2),
                            child: Center(
                              child: Text(
                                msg,
                                style: Styles.textStyleMedium(context),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final menu = displayMenus[index];
                          return RestaurantMenuCard(
                            menu: menu,
                            restaurant: widget.restaurant,
                            pickupKey: _pickupKey,
                          );
                        }, childCount: displayMenus.length),
                      );
                    }
                    // ===================== PRICE DISCOVERY TAB =====================
                    else {
                      if (provider.isTimeSlotLoading) {
                        return SliverToBoxAdapter(
                          child: const AppShimmer(type: ShimmerType.timeslot),
                        );
                      }

                      if (provider.timeSlots.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: size.height * 0.2),
                            child: Center(
                              child: Text(
                                "No active time slots available",
                                style: Styles.textStyleMedium(context),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final slot = provider.timeSlots[index];
                          return TimeSlotCard(
                            slot: slot,
                            onTap: () async {
                              final menuProvider = context.read<MenuProvider>();
                              menuProvider.stopAutoUpdaters();
                              final bidderProvider =
                                  context.read<BidderProvider>();
                              if (!slot.isActive && !slot.isUpcoming) {
                                // ⏹ Inactive → navigate to Winner Page
                                AppRouteName.timeSlotWinnerPage.push(
                                  context,
                                  args: {
                                    'franchiseId':
                                        widget.restaurant.franchiseId,
                                    'timerId': slot.timerId,
                                  },
                                );
                                return;
                              }

                              if (slot.isUpcoming) {
                                // 🕒 Upcoming → not started yet
                                AppDialogue.toast(
                                  "Bidding not started yet for this slot.",
                                );
                                return;
                              }

                              if (selectedPickupDate == null) {
                                final pickupWidgetState =
                                    _pickupKey.currentState;
                                if (pickupWidgetState != null) {
                                  pickupWidgetState.showCalendar(
                                    context,
                                  ); // ✅ call directly
                                } else {
                                  AppDialogue.toast(
                                    "Please select your pickup date.",
                                  );
                                }
                                return;
                              }

                              // ✅ Skip if already joined
                              if (bidderProvider.joinedTimerIds.contains(
                                slot.timerId,
                              )) {
                                AppDialogue.toast("Already joined this slot");
                                AppRouteName.biddingPage.push(
                                  context,
                                  args: {
                                    'restaurant': widget.restaurant,
                                    'timer_id': slot.timerId,
                                    'slot_start':
                                        slot.startTime, // ✅ already DateTime
                                    'slot_end':
                                        slot.endTime, // ✅ already DateTime
                                  },
                                );

                                return;
                              }

                              try {
                                await AppDialogue.openLoadingDialogAfterClose(
                                  context,
                                  text: "Joining bidding...",
                                  load:
                                      () async =>
                                          await bidderProvider.addBidder(
                                            userId:
                                                AppConstants.profile!.id
                                                    .toString(),
                                            name: AppConstants.profile!.name,
                                            timerId: slot.timerId,
                                          ),
                                  afterComplete: (resp) async {
                                    if (!context.mounted) return;

                                    if (resp.success) {
                                      AppDialogue.toast(resp.message);
                                      AppRouteName.biddingPage.push(
                                        context,
                                        args: {
                                          'restaurant': widget.restaurant,
                                          'timer_id': slot.timerId,
                                          'slot_start':
                                              slot.startTime, // ✅ already DateTime
                                          'slot_end':
                                              slot.endTime, // ✅ already DateTime
                                        },
                                      );
                                    } else {
                                      AppDialogue.toast(resp.message);
                                    }
                                  },
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  AppDialogue.toast("Something went wrong: $e");
                                }
                              }
                            },
                          );
                        }, childCount: provider.timeSlots.length),
                      );
                    }
                  },
                ),
                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.1)),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton:
          selectedTab == "Fixed Discount Price" && cart.hasItems
              ? SizedBox(
                width: size.width * 0.9,
                height: size.height * 0.07,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  label: Text(
                    "VIEW CART  >",
                    style: Styles.textStyleMediumBold(
                      context,
                      color: Colors.white,
                    ),
                    textScaler: TextScaler.linear(1.0),
                  ),
                  onPressed: () {
                    final menuProvider = context.read<MenuProvider>();
                    menuProvider.stopAutoUpdaters();
                    if (selectedPickupDate == null) {
                      AppDialogue.toast("Please select pickup date first");
                      return;
                    }

                    AppRouteName.fixedPricePayment.push(
                      context,
                      args: {
                        "menus":
                            cart.items.entries
                                .map((e) => {"menu": e.key, "qty": e.value})
                                .toList(),
                        "pickup_date": DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedPickupDate),

                        "restaurant": widget.restaurant,
                        "from_flash": !widget.showPriceTabs,
                      },
                    );
                  },
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
