import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/OrderModels/order_model.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/order_history_card.dart';


class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
 // Fixed Orders (Static)
final fixedOrders = [
  OrderModel(
    transId: "T2412261619060510588088",
    orderId: "OD20241226161852",
    restaurantName: "Biryani Palayam, Erode",
    pickupPoint: "Biyanipalayam",
    pickupDate: "28-12-2024",
    pickupTime: "10:00 AM",
    bookingDate: "26-12-2024",
    bookingTime: "04:18 PM",
    itemDetails: "Chicken biryani 2kg bucket × 1",
    total: 1.05,
    status: "success",
    rating: 4.0,
    ownerName: "Shamson",
    ownerPhone: "9943770996",
  ),
  OrderModel(
    transId: "T241230101234567890123",
    orderId: "OD20241230120001",
    restaurantName: "SS Hyderabad Biryani, Nagapattinam",
    pickupPoint: "Nagapattinam Main Road",
    pickupDate: "30-12-2024",
    pickupTime: "01:00 PM",
    bookingDate: "29-12-2024",
    bookingTime: "11:30 AM",
    itemDetails: "Mutton Biryani Family Pack × 2",
    total: 2.50,
    status: "success",
    rating: 4.5,
    ownerName: "Rahul",
    ownerPhone: "9876543210",
  ),
];

// Bidding Orders (Static)
final biddingOrders = [
  OrderModel(
    transId: "T2501011415000000001",
    orderId: "BD20250101141500",
    restaurantName: "Palmshore, Chennai",
    pickupPoint: "Porur Pickup Point",
    pickupDate: "01-01-2025",
    pickupTime: "02:00 PM",
    bookingDate: "31-12-2024",
    bookingTime: "09:00 PM",
    itemDetails: "BBQ Chicken Full × 1",
    total: 1.75,
    status: "success",
    rating: 4.2,
    ownerName: "Karthik",
    ownerPhone: "9123456780",
  ),
  OrderModel(
    transId: "T2501020915000000002",
    orderId: "BD20250102091500",
    restaurantName: "Arabian Grill, Trichy",
    pickupPoint: "Trichy Bus Stand",
    pickupDate: "02-01-2025",
    pickupTime: "12:00 PM",
    bookingDate: "01-01-2025",
    bookingTime: "06:00 PM",
    itemDetails: "Shawarma Roll × 3",
    total: 0.90,
    status: "success",
    rating: 3.8,
    ownerName: "Imran",
    ownerPhone: "9765432109",
  ),
];



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "My Orders", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Fixed Price"),
                Tab(text: "Bidding"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
  padding: EdgeInsets.all(size.width * 0.04),
  itemCount: fixedOrders.length,
  itemBuilder: (context, index) =>
      OrderCard(order: fixedOrders[index]),
),

                  // Fixed Orders
                  // Consumer<FixedOrdersProvider>(
                  //   builder: (context, provider, _) {
                  //     if (provider.isLoading) {
                  //       return const FullScreenShimmer();
                  //     }
                  //     if (provider.orders.isEmpty) {
                  //       return Center(
                  //         child: Text("No Fixed Orders",
                  //             style: Styles.textStyleMedium(context)),
                  //       );
                  //     }
                  //     return ListView.builder(
                  //       padding: EdgeInsets.all(size.width * 0.04),
                  //       itemCount: provider.orders.length,
                  //       itemBuilder: (context, index) =>
                  //           OrderCard(order: provider.orders[index]),
                  //     );
                  //   },
                  // ),
                  // Bidding Orders
                  // Consumer<BiddingOrdersProvider>(
                  //   builder: (context, provider, _) {
                  //     if (provider.isLoading) {
                  //       return const FullScreenShimmer();
                  //     }
                  //     if (provider.orders.isEmpty) {
                  //       return Center(
                  //         child: Text("No Bidding Orders",
                  //             style: Styles.textStyleMedium(context)),
                  //       );
                  //     }
                  //     return ListView.builder(
                  //       padding: EdgeInsets.all(size.width * 0.04),
                  //       itemCount: provider.orders.length,
                  //       itemBuilder: (context, index) =>
                  //           OrderCard(order: provider.orders[index]),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
