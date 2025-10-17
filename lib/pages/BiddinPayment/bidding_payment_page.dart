import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_food_my_price/pages/BiddinPayment/helper/payment_helper.dart';
import 'package:my_food_my_price/route_generator.dart';
import 'package:my_food_my_price/util/dilogs.dart';
import 'package:my_food_my_price/util/validator.dart';
import 'package:provider/provider.dart';

import '../../Gateway/phonepay.dart';
import '../../Providers/bidding_order_provider.dart';
import '../../Providers/menu_provider.dart';
import '../../models/BidderModels/winner_model.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../util/app_contant.dart';
import '../../util/styles.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/dilogue/dilogue.dart';
import 'Widgets/menu_card.dart';
import 'Widgets/pickup_deatils.dart';
import 'Widgets/price_summary.dart';
import 'Widgets/price_summary_data.dart';

class BiddingPaymentPage extends StatefulWidget {
  final List<WinnerModel> winners;
  final String pickupDate;
  final String pickupPoint;
  final Restaurant restaurant; // ✅ add this

  const BiddingPaymentPage({
    super.key,
    required this.winners,
    required this.pickupDate,
    required this.pickupPoint,
    required this.restaurant, // ✅ add this
  });

  @override
  State<BiddingPaymentPage> createState() => _BiddingPaymentPageState();
}

class _BiddingPaymentPageState extends State<BiddingPaymentPage> {
  late final BiddingOrderProvider orderProvider;
  late final profile;
  late List<int> quantities;
  PriceSummaryData? priceData;
  bool restaurantContact = false;
  late String selectedPickupDate;
  late String selectedPickupPoint;

  String _formatDateForApi(String date) {
    try {
      // handles both dd-MM-yyyy and yyyy-MM-dd
      if (date.contains('-')) {
        final parts = date.split('-');
        // if first part is 4 digits => already yyyy-MM-dd
        if (parts.first.length == 4) return date;
        // else convert dd-MM-yyyy → yyyy-MM-dd
        final d = DateFormat('dd-MM-yyyy').parse(date);
        return DateFormat('yyyy-MM-dd').format(d);
      }
      return date;
    } catch (_) {
      return date;
    }
  }

  @override
  void initState() {
    super.initState();
    selectedPickupDate = widget.pickupDate;
    selectedPickupPoint = widget.pickupPoint;
    orderProvider = context.read<BiddingOrderProvider>();
    profile = AppConstants.profile!;
    quantities = List.filled(widget.winners.length, 1);

    Future.microtask(() async {
      await orderProvider.getPickupTime(
        franchiseId: widget.winners.first.franchiseId,
        pickupDate: widget.pickupDate,
      );
    });
    // ✅ Prepare data (winners, user info, pickup)
    debugPrint("🧾 Winners: ${widget.winners.length}");
    debugPrint("👤 User: ${profile.name} (${profile.mobile})");
    debugPrint("📦 Pickup: ${widget.pickupPoint} on ${widget.pickupDate}");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CommonAppBar(title: "Order Details", showBack: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🧾 Menu Section
                WinnerMenuList(
                  winners: widget.winners,
                  quantities: quantities,
                  onQuantityChange: (updated) {
                    setState(() => quantities = List.from(updated));
                  },
                ),

                SizedBox(height: size.height * 0.02),

                // 💰 Dynamic Price Summary
                PriceSummarySection(
                  profile: profile,
                  winners: widget.winners,
                  quantities: quantities,
                  onPriceUpdate: (data) => setState(() => priceData = data),
                ),

                SizedBox(height: size.height * 0.02),

                // 📍 Pickup Details Section
                PickupDetailsSection(
                  pickupDate: widget.pickupDate,
                  pickupPoint: widget.pickupPoint,
                  franchiseId: widget.winners.first.franchiseId,
                  restaurant: widget.restaurant,
                  isFixedOrder: false,
                  onDateChange:
                      (newDate) => setState(() => selectedPickupDate = newDate),
                  onPickupPointChange:
                      (newPoint) =>
                          setState(() => selectedPickupPoint = newPoint),
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Checkbox(
                      value: restaurantContact,
                      onChanged: (value) {
                        setState(() {
                          restaurantContact = value ?? false;
                        });
                      },
                      activeColor: Colors.green, // Green color for tick
                    ),
                    Expanded(
                      child: Text(
                        "Restaurant should contact me for delivery options.",
                        style: Styles.textStyleMedium(context),
                        textScaler: TextScaler.linear(1.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final data = priceData;
          final payable = data?.payable ?? 0.0;
          final gst = data?.gst ?? 0.0;
          final walletUsed = data?.walletUsed ?? 0.0;

          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.07,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text(
                "Pay ₹${payable.toStringAsFixed(2)}",
                style: Styles.textStyleMediumBold(context, color: Colors.white),
                textScaler: const TextScaler.linear(1.0),
              ),
              onPressed: () async {
                await _handlePlaceOrder(context, data);
              },
            ),
          );
        },
      ),
    );
  }

 Future<void> _handlePlaceOrder(
  BuildContext context,
  PriceSummaryData? data,
) async {
  if (data == null) {
    AppDialogue.toast("Calculating totals...");
    return;
  }

  // ✅ collect valid winners
  final validWinners = <WinnerModel>[];
  final validQuantities = <int>[];

  for (int i = 0; i < widget.winners.length; i++) {
    if (quantities[i] > 0) {
      validWinners.add(widget.winners[i]);
      validQuantities.add(quantities[i]);
    }
  }

  if (validWinners.isEmpty) {
    AppDialogue.toast("Please select at least one item before proceeding");
    return;
  }

  final pickupTime = orderProvider.selectedPickupTime?.time;
  if (pickupTime == null || pickupTime.isEmpty) {
    Dialogs.snackbar("Please select pickup time", context, isError: true);
    return;
  }

  final apiPickupDate = _formatDateForApi(selectedPickupDate);
  final transactionId = "MT${DateTime.now().millisecondsSinceEpoch}";
  final payable = data.payable;
  final gst = data.gst;
  final walletUsed = data.walletUsed;

  try {
    await AppDialogue.openLoadingDialogAfterClose(
      context,
      text: "Placing your order...",
      load: () async {
        return await orderProvider.placeBiddingOrder(
          franchiseId: widget.winners.first.franchiseId,
          userId: profile.id.toString(),
          menuIds: widget.winners.map((w) => w.menuId).toList(),
          menuNames: widget.winners.map((w) => w.menuName).toList(),
          menuQuantities: quantities.map((q) => q.toString()).toList(),
          totalMenuPrices: widget.winners
              .asMap()
              .entries
              .map((e) => (double.tryParse(e.value.finalPrice)! * quantities[e.key]).toString())
              .toList(),
          name: profile.name,
          pickupPoint: selectedPickupPoint,
          pickupTime: pickupTime,
          mobile: profile.mobile,
          transactionAmount: payable.toStringAsFixed(2),
          merchantTransactionId: transactionId,
          wallet: walletUsed.toStringAsFixed(2),
          gst: gst.toStringAsFixed(2),
          pickupDate: apiPickupDate,
          contactCustomer: restaurantContact ? 1 : 0,
          timerId: widget.winners.first.timerId ?? "",
        );
      },
      afterComplete: (result) async {
        if (!context.mounted) return;

        // ✅ handle partial stock error
        if (result is Map &&
            result['status'] == 'stock_error' &&
            result['data'] != null) {
          final data = result['data'];
          final msg = result['message'] ?? "Stock issue detected";
          final menuId = data['menu_id'];
          final available = data['avaliable_stock'];

          // 🔹 update local quantity
          final winnerIndex = widget.winners.indexWhere(
            (w) => w.menuId.toString() == menuId.toString(),
          );
          if (winnerIndex != -1) {
            setState(() {
              quantities[winnerIndex] = available;
            });
          }

          // 🔹 update stock globally in MenuProvider
          final menuProvider = context.read<MenuProvider>();
          final menuIndex = menuProvider.menus.indexWhere(
            (m) => m.id.toString() == menuId.toString(),
          );
          if (menuIndex != -1) {
            final oldMenu = menuProvider.menus[menuIndex];
            menuProvider.menus[menuIndex] =
                oldMenu.copyWith(avaliableStocks: available);
            menuProvider.notifyListeners();
          }

          Dialogs.snackbar(msg, context, isError: true);
          return;
        }

        // ✅ success path
        if (result['status'] == 'success') {
          if (payable > 0) {
            await AppDialogue.openLoadingDialogAfterClose(
              context,
              text: "Redirecting to PhonePe...",
              load: () async {
                return await PhonePeGateway.startPayment(
                  amount: payable,
                  transactionId: transactionId,
                  userId: profile.id.toString(),
                );
              },
              afterComplete: (payment) async {
                final status =
                    (payment?["status"] ?? "").toString().toLowerCase();

                if (status == "success" || status == "completed") {
                  await _verifyPaymentStatus(
                    context,
                    transactionId,
                    walletUsed,
                  );
                } else {
                  await AppRouteName.biddingPaymentFailedPage.push(context);
                }
              },
            );
          } else {
            // ✅ order placed fully with wallet (no online payment)
            await _verifyPaymentStatus(
              context,
              transactionId,
              walletUsed,
            );
          }
        } else {
          AppDialogue.toast(result['message'] ?? "Order failed");
        }
      },
    );
  } catch (e) {
    AppDialogue.toast("Something went wrong: $e");
  }
}


  Future<void> _verifyPaymentStatus(
    BuildContext context,
    String merchantTransactionId,
    double walletUsed,
  ) async {
    await AppDialogue.openLoadingDialogAfterClose(
      context,
      text: "Verifying payment...",
      load: () async {
        final status = await orderProvider.fetchPaymentStatus(
          merchantTransactionId: merchantTransactionId,
        );
        return status;
      },
      afterComplete: (status) async {
        final paymentStatus = status?.toString().toLowerCase() ?? "failed";

        if (paymentStatus == "success") {
          await PaymentHelpers.clearFailedPaymentDetails();
          if (walletUsed > 0) {
            await orderProvider.verifyAndUpdateWallet(
              merchantTransactionId: merchantTransactionId,
              walletUsed: walletUsed.toStringAsFixed(2),
            );
          }

          if (!context.mounted) return;
          await AppRouteName.biddingPaymentSuccessPage.pushAndRemoveUntil(
            context,
            (_) => false,
          );
        } else {
          await PaymentHelpers.saveFailedPaymentDetails(
            winners: widget.winners,
            franchiseId: widget.winners.first.franchiseId,
            timerId: widget.winners.first.timerId ?? "",
          );

          if (!context.mounted) return;
          await AppRouteName.biddingPaymentFailedPage.push(
            context,
            args: {
              "winners": widget.winners,
              "franchiseId": widget.winners.first.franchiseId,
              "timerId": widget.winners.first.timerId ?? "",
            },
          );
        }
      },
    );
  }
}
