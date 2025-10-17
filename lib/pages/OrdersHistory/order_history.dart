import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/order_history_provider.dart';
import '../../util/color_constant.dart';
import '../../widgets/app_bar.dart';
import 'widgets/order_list_tab.dart';
import 'widgets/sliver_tabbar_delegate.dart';

class OrderHistory extends StatefulWidget {
  final int initialTab;
  final bool forceRefresh;
  const OrderHistory({
    super.key,
    this.initialTab = 0,
    this.forceRefresh = false,
  }); // 👈 add param

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab, // 👈 set initial tab
    );
    _scrollController = ScrollController();
    Future.microtask(() async {
      final provider = context.read<OrderHistoryProvider>();
      // ✅ If opened after payment, always fetch fresh data
      await provider.getFixedOrders(forceRefresh: widget.forceRefresh);
      await provider.getBiddingOrders(forceRefresh: widget.forceRefresh);
    });
  }

  Future<void> _onRefresh() async {
    final provider = context.read<OrderHistoryProvider>();
    await Future.wait([
      provider.getFixedOrders(forceRefresh: true),
      provider.getBiddingOrders(forceRefresh: true),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "My Orders", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColor.maincolor,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Fixed Price"),
                      Tab(text: "Bidding"),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColor.maincolor,
                      child: const OrderListTab(tabType: "fixed"),
                    ),
                    RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColor.maincolor,
                      child: const OrderListTab(tabType: "bidding"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
