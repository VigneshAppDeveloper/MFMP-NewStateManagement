import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_food_my_price/Providers/bidding_provider.dart';
import 'package:my_food_my_price/Providers/menu_provider.dart';
import 'package:my_food_my_price/util/styles.dart';
import 'package:my_food_my_price/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../components/BiddingPageDesigns/bidding_item_card.dart';
import '../components/BiddingPageDesigns/bidding_timer_bar.dart';
import '../components/BiddingPageDesigns/winner_dilogue.dart';
import '../models/BidderModels/add_bidding_model.dart';
import '../models/BidderModels/get_bidding_model.dart';
import '../models/BidderModels/winner_model.dart';
import '../models/Resturant Model/resturant.dart';
import '../util/app_contant.dart';
import '../widgets/app_shimmer.dart';
import '../widgets/dilogue/dilogue.dart';
import '../widgets/shimmer_type.dart';

class BiddingPage extends StatefulWidget {
  final Restaurant restaurant;
  final String timerId;
  final DateTime slotStart;
  final DateTime slotEnd;

  const BiddingPage({
    super.key,
    required this.restaurant,
    required this.timerId,
    required this.slotStart,
    required this.slotEnd,
  });

  @override
  State<BiddingPage> createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> with WidgetsBindingObserver {
  Timer? _freezeTimer;
  final Map<String, bool> _frozenMenus = {};
  late BiddingProvider provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    provider = context.read<BiddingProvider>();

    Future.microtask(() async {
      // 1️⃣ Load all "Bidding" type menus
      final menus = await _fetchBiddingMenus();

      // 2️⃣ Start provider with slot details
      await provider.initBidding(
        franchiseId: widget.restaurant.franchiseId,
        timerId: widget.timerId,
        menus: menus,
        slotStart: widget.slotStart,
        slotEnd: widget.slotEnd,
      );

      // 3️⃣ Attach callback (triggered when bidding ends)
      provider.onBiddingEnd = () async {
        provider.stopAll();

        final profile = AppConstants.profile!;
        final userId = profile.id.toString();

        // fetch winners
  List<WinnerModel> allWinners = [];
        for (final bid in provider.biddings) {
          final menuWinners = await provider.getWinner(
            widget.timerId,
            bid.menuId,
          );
           allWinners.addAll(menuWinners);
        }

        if (!mounted) return;
        final userWins = allWinners.where((w) => w.userId == userId).toList();

        if (userWins.isNotEmpty) {
        WinnerLooserDialog.showWinnerDialog(context, userWins, widget.restaurant);

        } else {
          WinnerLooserDialog.showLoserDialog(context);
        }
      };
    });
  }

  Future<List<BiddingModel>> _fetchBiddingMenus() async {
    final menuProvider = context.read<MenuProvider>();
    final allMenus = menuProvider.menus;

    // 🧩 Filter menus where type == "Bidding"
    return allMenus
        .where((m) => m.menuType.toLowerCase() == "bidding")
        .map(
          (m) => BiddingModel(
            menuId: m.id.toString(), // ✅ id instead of menuId
            timerId: widget.timerId,
            highestPrice: m.currentPrice.toStringAsFixed(2),
            name: "No Bidders Yet", // ✅ menuName instead of name
            basePrice: m.basePrice.toStringAsFixed(2),
          ),
        )
        .toList();
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 🔹 When user minimizes app or switches away
      // Stop timers and polling safely to save resources
      provider.stopAll();
    } else if (state == AppLifecycleState.resumed) {
      // 🔹 When user comes back to app
      final now = DateTime.now();

      // If the bidding already ended while user was away
      if (provider.remaining.inSeconds <= 0) {
        debugPrint(
          "⏰ Slot ended while app was in background — showing results",
        );
        provider.onBiddingEnd?.call(); // directly trigger winner/loser dialog
      } else {
        // 🔹 Otherwise, resume polling and countdown normally
        debugPrint("▶️ Resuming active bidding slot");
        provider.initBidding(
          franchiseId: widget.restaurant.franchiseId,
          timerId: widget.timerId,
          menus: provider.biddings,
          slotStart: widget.slotStart,
          slotEnd: widget.slotEnd,
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    provider.stopAll();
    _freezeTimer?.cancel();
    super.dispose();
  }

  void _onBid(BiddingModel item, double bidAmount) async {
    if (_frozenMenus[item.menuId] == true) return;

    final profile = AppConstants.profile!;
    final menuProvider = context.read<MenuProvider>();
    final menu = menuProvider.menus.firstWhere(
      (m) => m.id.toString() == item.menuId,
      orElse: () => throw Exception("Menu not found for ID ${item.menuId}"),
    );
    final request = BiddingRequestModel(
      userId: profile.id.toString(),
      franchiseId: widget.restaurant.franchiseId,
      timerId: widget.timerId,
      menuCategoryId: item.menuId,
      name: profile.name,
      menuCategoryName: menu.menuName,
      description: widget.restaurant.description,
      currentPrice: bidAmount,
    );

    final success = await provider.addBidding(request);
    if (success) {
      AppDialogue.toast("Bid placed successfully!");
      _startFreeze(item.menuId);
    } else {
      AppDialogue.toast("Failed to place bid");
    }
  }

  void _startFreeze(String menuId) {
    _frozenMenus[menuId] = true;
    setState(() {}); // trigger rebuild

    Timer(const Duration(seconds: 10), () {
      _frozenMenus[menuId] = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Bidding Room", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.015)),
              SliverToBoxAdapter(
                child: BiddingTimerBar(), // pinned countdown
              ),
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.015)),
              Consumer2<MenuProvider, BiddingProvider>(
                builder: (context, menuProvider, bidProvider, _) {
                  if (bidProvider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(child: AppShimmer(type: ShimmerType.menu)),
                    );
                  }

                  final menus =
                      menuProvider.menus
                          .where((m) => m.menuType.toLowerCase() == "bidding")
                          .toList();

                  if (menus.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: size.height * 0.3),
                        child: Center(
                          child: Text(
                            "No active bidding menus",
                            style: Styles.textStyleMedium(context),
                            textScaler: const TextScaler.linear(1.0),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final menu = menus[index];
                      final bid = bidProvider.biddings.firstWhere(
                        (b) => b.menuId == menu.id.toString(),
                        orElse:
                            () => BiddingModel(
                              menuId: menu.id.toString(),
                              timerId: widget.timerId,
                              highestPrice: menu.currentPrice.toStringAsFixed(
                                2,
                              ),
                              name: "No Bidders Yet",
                            ),
                      );
                      final isLoadingMenu =
                          bidProvider.menuLoading[menu.id.toString()] ?? false;
                      final currentBid =
                          double.tryParse(bid.highestPrice) ??
                          menu.currentPrice;
                      final isFrozen =
                          _frozenMenus[menu.id.toString()] ?? false;

                      final priceExceeded =
                          currentBid >= (menu.basePrice * 0.98);

                      return RestaurantBiddingCard(
                        menu: menu,
                        currentBid: currentBid,
                        highestBidder: bid.name,
                        priceExceeded: priceExceeded,
                        isFrozen: isFrozen,
                        onBid: (price) => _onBid(bid, price),
                        isLiveUpdating: isLoadingMenu,
                      );
                    }, childCount: menus.length),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
