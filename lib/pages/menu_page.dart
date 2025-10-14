import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/app_contant.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:provider/provider.dart';

import '../Providers/add_bidder_provider.dart';
import '../Providers/menu_provider.dart';
import '../components/HomePageDesigns/home_search_bar.dart';
import '../components/ResturantMenuDesigns/pickup_date_pickup_point.dart';
import '../components/ResturantMenuDesigns/resturant_menu_card.dart';
import '../components/ResturantMenuDesigns/resturant_menu_header.dart';
import '../components/ResturantMenuDesigns/time_slot_card_ui.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    searchController = TextEditingController();

    provider = context.read<MenuProvider>(); // 👈 capture once here

    Future.microtask(() async {
      provider.getRestaurantMenu(
        widget.restaurant.franchiseId,
        forceRefresh: false,
      );
      provider.resumeAutoUpdaters(widget.restaurant.franchiseId);
      if (provider.timeSlots.isNotEmpty) {
      await provider.refreshTimeSlot(widget.restaurant.franchiseId);
    }
    });
  }

  /// 🧩 Lifecycle handler (pause/resume app)
@override
Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {

  if (state == AppLifecycleState.paused) {
    provider.stopAutoUpdaters();
  } else if (state == AppLifecycleState.resumed) {
    provider.resumeAutoUpdaters(widget.restaurant.franchiseId);
    await provider.refreshTimeSlot(widget.restaurant.franchiseId);
    // ✅ new line
  }
}


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    provider.stopAutoUpdaters();
    provider.clearPickupSelections(); // 👈 safe — no context used
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColor.maincolor,
          onRefresh: () async {
            final provider = context.read<MenuProvider>();
            if (selectedTab == "Fixed Discount Price") {
              await provider.getRestaurantMenu(
                widget.restaurant.franchiseId,
                forceRefresh: true,
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
                  child: PickupDatePickupPoint(restaurant: widget.restaurant),
                ),

                /// 💰 Two clickable tabs
                if (widget.showPriceTabs)
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
                                  borderRadius: BorderRadius.circular(8),
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (selectedTab != "Price Discovery") {
                                  setState(
                                    () => selectedTab = "Price Discovery",
                                  );
                                  // fetch only if not already loaded
                                  final provider = context.read<MenuProvider>();
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
                                  borderRadius: BorderRadius.circular(8),
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

                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

                /// 🔍 Search bar
                if (selectedTab == "Fixed Discount Price")
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    floating: true,
                    snap: true,
                    elevation: 0,
                    toolbarHeight: size.height * 0.075,
                    automaticallyImplyLeading: false,
                    flexibleSpace: HomeSearchBar(
                      controller: searchController,
                      onFilterTap: () {},
                    ),
                  ),

                SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

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
                      final filteredMenus =
                          provider.menus.where((menu) {
                            return menu.menuType.toLowerCase() == "fixed price";
                          }).toList();

                      if (filteredMenus.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: size.height * 0.2),
                            child: Center(
                              child: Text(
                                "No fixed price menu available",
                                style: Styles.textStyleMedium(context),
                                textScaler: const TextScaler.linear(1.0),
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final menu = filteredMenus[index];
                          return RestaurantMenuCard(menu: menu);
                        }, childCount: filteredMenus.length),
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

                              final selectedDate =
                                  menuProvider.selectedPickupDate;
                              final selectedPoint =
                                  menuProvider.selectedPickupPoint;

                              if (selectedDate == null) {
                                AppDialogue.toast(
                                  "Please select a pickup date first.",
                                );
                                return;
                              }
                              if (selectedPoint == null) {
                                AppDialogue.toast(
                                  "Please select a pickup point first.",
                                );
                                return;
                              }
                              if (!slot.isActive) {
                                AppDialogue.toast(
                                  "Bidding not started yet for this slot.",
                                );
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
              ],
            ),
          ),
        ),
      ),
    );
  }

 
}
