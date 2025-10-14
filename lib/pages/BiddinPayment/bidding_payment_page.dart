import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Gateway/payment_selection.dart';
import '../../Gateway/phonepay.dart';
import '../../Providers/bidding_order_provider.dart';
import '../../models/BidderModels/winner_model.dart';
import '../../models/Resturant Model/resturant.dart';
import '../../util/app_contant.dart';
import '../../util/styles.dart';
import '../../widgets/app_bar.dart';
import 'Widgets/menu_card.dart';
import 'Widgets/pickup_deatils.dart';
import 'Widgets/price_summary.dart';

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

  @override
  void initState() {
    super.initState();
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
                ),

                SizedBox(height: size.height * 0.02),

                // 📍 Pickup Details Section
                PickupDetailsSection(
                  pickupDate: widget.pickupDate,
                  pickupPoint: widget.pickupPoint,
                  franchiseId: widget.winners.first.franchiseId,
                  restaurant: widget.restaurant,
                ),
                  SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          // ✅ Manual total calculation (same logic as PriceSummarySection)
          double subtotal = 0;
          for (int i = 0; i < widget.winners.length; i++) {
            final price = double.tryParse(widget.winners[i].finalPrice) ?? 0.0;
            subtotal += price * quantities[i];
          }
          final gst = subtotal * 0.05;
          final grand = subtotal + gst;

          final walletBalance =
              double.tryParse(profile.wallet?.toString() ?? '0') ?? 0.0;
          final walletUse =
              walletBalance > 0 ? min(walletBalance, grand * 0.3) : 0.0;
          final payable = grand - walletUse;

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
                // full validation + payment flow
                final pickupProvider = context.read<BiddingOrderProvider>();
                final pickupTime = pickupProvider.selectedPickupTime?.time;
                if (pickupTime == null) {
                  // Dialogs.snackbar("Please select pickup time", context, isError: true);
                  return;
                }

                // final method = await PaymentSelector.show(context);
                // if (method == null) return;

                final transactionId =
                    "MT${DateTime.now().millisecondsSinceEpoch.toString()}";

                // Place order first
                final success = await orderProvider.placeBiddingOrder(
                  franchiseId: widget.winners.first.franchiseId,
                  userId: profile.id.toString(),
                  menuIds: widget.winners.map((w) => w.menuId).toList(),
                  menuNames: widget.winners.map((w) => w.menuName).toList(),
                  menuQuantities: quantities.map((q) => q.toString()).toList(),
                  totalMenuPrices:
                      widget.winners
                          .asMap()
                          .entries
                          .map(
                            (e) =>
                                (double.tryParse(e.value.finalPrice)! *
                                        quantities[e.key])
                                    .toString(),
                          )
                          .toList(),
                  name: profile.name,
                  pickupPoint: widget.pickupPoint,
                  pickupTime: pickupTime,
                  mobile: profile.mobile,
                  transactionAmount: payable.toStringAsFixed(2),
                  merchantTransactionId: transactionId,
                  wallet: walletUse.toStringAsFixed(2),
                  gst: gst.toStringAsFixed(2),
                  pickupDate: widget.pickupDate,
                  contactCustomer: "1",
                  timerId: widget.winners.first.timerId ?? "",
                );

                if (!success) {
                  //  Dialogs.snackbar("Order placement failed.", context, isError: true);
                  return;
                }

                if (payable > 0) {
                  final paymentResponse = await PhonePeGateway.startPayment(
                    amount: payable,
                    transactionId: transactionId,
                    userId: profile.id.toString(),
                  );

                  if (paymentResponse == null ||
                      paymentResponse["status"] != "SUCCESS") {
                    //  Dialogs.snackbar("Payment failed. Try again.", context, isError: true);
                    return;
                  }

                  final verified = await orderProvider.verifyAndUpdateWallet(
                    merchantTransactionId: transactionId,
                    walletUsed: walletUse.toStringAsFixed(2),
                  );

                  if (verified) {
                    //   Navigator.pushReplacementNamed(context, AppRouteName.bidSuccess);
                  } else {
                    // Navigator.pushReplacementNamed(context, AppRouteName.bidFailure);
                  }
                } else {
                  await orderProvider.updateWallet(
                    wallet: walletUse.toStringAsFixed(2),
                  );
                  // Navigator.pushReplacementNamed(context, AppRouteName.bidSuccess);
                }
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
