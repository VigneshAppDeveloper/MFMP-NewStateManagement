import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/order_history_provider.dart';
import '../../../util/styles.dart';
import '../../../widgets/app_shimmer.dart';
import '../../../widgets/shimmer_type.dart';
import 'order_card.dart';


class OrderListTab extends StatelessWidget {
  final String tabType;
  const OrderListTab({super.key, required this.tabType});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<OrderHistoryProvider>(
      builder: (context, provider, _) {
        final isLoading = tabType == "fixed"
            ? provider.isFixedLoading
            : provider.isBiddingLoading;

        final orders = tabType == "fixed"
            ? provider.fixedOrders
            : provider.biddingOrders;

        return CustomScrollView(
          slivers: [
            if (isLoading)
              const SliverToBoxAdapter(
                child: AppShimmer(type: ShimmerType.menu),
              )
            else if (orders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: size.height * 0.2),
                  child: Center(
                    child: Text(
                      "No orders found",
                      style: Styles.textStyleMedium(context),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = orders[index];
                    return OrderCard(order: order);
                  },
                  childCount: orders.length,
                ),
              ),
          ],
        );
      },
    );
  }
}
