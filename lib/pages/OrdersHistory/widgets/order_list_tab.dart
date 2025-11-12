import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/order_history_provider.dart';
import '../../../models/OrderModels/order_model.dart';
import '../../../util/styles.dart';
import '../../../widgets/app_shimmer.dart';
import '../../../widgets/shimmer_type.dart';
import 'order_card.dart';

class OrderListTab extends StatelessWidget {
  final String tabType;
  const OrderListTab({super.key, required this.tabType});

  List<List<OrderDetailModel>> _groupOrdersByOrderId(
    List<OrderDetailModel> orders,
  ) {
    final Map<String, List<OrderDetailModel>> grouped = {};

    for (final order in orders) {
      final key = order.orderId ?? order.merchantTransactionId ?? '';
      if (key.isEmpty) continue;
      grouped.putIfAbsent(key, () => []).add(order);
    }

    return grouped.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<OrderHistoryProvider>(
      builder: (context, provider, _) {
        // ✅ Determine which list + loader to use
        final bool isLoading;
        final List<OrderDetailModel> orders;

        switch (tabType) {
          case "fixed":
            isLoading = provider.isFixedLoading;
            orders = provider.fixedOrders;
            break;
          case "bidding":
            isLoading = provider.isBiddingLoading;
            orders = provider.biddingOrders;
            break;
          case "flash":
            isLoading = provider.isFlashLoading;
            orders = provider.flashOrders;
            break;
          default:
            isLoading = false;
            orders = [];
        }

        // ✅ Common scroll + empty/loading handling
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  // ✅ 1. Group orders by order_id
                  final groupedOrders = _groupOrdersByOrderId(orders);
                  final group = groupedOrders[index];

                  // ✅ 2. Use first record as base order
                  final firstOrder = group.first;

                  // ✅ 3. Attach all menus inside this order (so OrderCard can show them)
                  return OrderCard(
                    order: firstOrder.copyWith(
                      groupedMenus:
                          group
                              .where((e) => e.menu != null)
                              .map((e) => e.menu!)
                              .toList(),
                    ),
                    orderType: tabType,
                  );
                }, childCount: _groupOrdersByOrderId(orders).length),
              ),
          ],
        );
      },
    );
  }
}


