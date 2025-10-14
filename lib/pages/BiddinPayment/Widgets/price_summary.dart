import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';

import '../../../models/BidderModels/winner_model.dart';
import '../../../models/FoodModels/resturant_menu_model.dart';
import '../../../util/styles.dart';
import 'price_summary_data.dart';

class PriceSummarySection extends StatefulWidget {
  final dynamic profile; // AppConstants.profile
  final List<WinnerModel>? winners; // ✅ make optional
  final List<RestaurantMenuModel>? menus; // ✅ new optional param
  final List<int> quantities;
  final ValueChanged<PriceSummaryData>? onPriceUpdate;

  const PriceSummarySection({
    super.key,
    required this.profile,
    this.winners,
    this.menus,
    required this.quantities,
    this.onPriceUpdate,
  });

  @override
  State<PriceSummarySection> createState() => _PriceSummarySectionState();
}

class _PriceSummarySectionState extends State<PriceSummarySection> {
  bool useWallet = false;
  double initialWalletAmount = 0.0;

  @override
  void initState() {
    super.initState();
    initialWalletAmount =
        double.tryParse(widget.profile.wallet?.toString() ?? '0.0') ?? 0.0;
  }

  /// ✅ Calculates subtotal for either bidding (winners) or fixed (menus)
  double calculateSubtotal() {
    double total = 0.0;

    // Bidding flow
    if (widget.winners != null && widget.winners!.isNotEmpty) {
      for (int i = 0; i < widget.winners!.length; i++) {
        final price = double.tryParse(widget.winners![i].finalPrice) ?? 0.0;
        total += price * widget.quantities[i];
      }
    }
    // Fixed-price flow
    else if (widget.menus != null && widget.menus!.isNotEmpty) {
      for (int i = 0; i < widget.menus!.length; i++) {
        final price = widget.menus![i].currentPrice;
        total += price * widget.quantities[i];
      }
    }

    return total;
  }

  double calculateGST(double subtotal) => subtotal * 0.05;

  double calculateWalletUsage(double grandTotal) {
    if (!useWallet || initialWalletAmount <= 0) return 0.0;
    final maxWalletUse = grandTotal * 0.3;
    return initialWalletAmount >= maxWalletUse
        ? maxWalletUse
        : initialWalletAmount;
  }

  double calculateRemainingWallet(double used) =>
      (initialWalletAmount - used).clamp(0, double.infinity);

  double calculatePayable() {
    final subtotal = calculateSubtotal();
    final gst = calculateGST(subtotal);
    final grand = subtotal + gst;
    final walletUsed = calculateWalletUsage(grand);
    return grand - walletUsed;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final subtotal = calculateSubtotal();
    final gst = calculateGST(subtotal);
    final walletUsed = calculateWalletUsage(subtotal + gst);
    final remainingWallet = calculateRemainingWallet(walletUsed);
    final payable = calculatePayable();

    final data = PriceSummaryData(
      subtotal: subtotal,
      gst: gst,
      walletUsed: walletUsed,
      payable: payable,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPriceUpdate?.call(data);
    });

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _priceRow(context, "Sub Total", "₹${subtotal.toStringAsFixed(2)}"),
            _priceRow(
              context,
              "GST & Restaurant Charges",
              "₹${gst.toStringAsFixed(2)}",
            ),
            const Divider(height: 20),

            Row(
              children: [
                Checkbox(
                  value: useWallet,
                  activeColor: AppColor.maincolor,
                  onChanged: initialWalletAmount > 0
                      ? (val) => setState(() => useWallet = val ?? false)
                      : null,
                ),
                Expanded(
                  child: Text(
                    useWallet
                        ? "Use up to 30% of bill from Wallet"
                        : "Use Wallet Balance",
                    style: Styles.textSmall(context).copyWith(
                      color: initialWalletAmount > 0
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
                Text(
                  useWallet
                      ? "₹${walletUsed.toStringAsFixed(2)}"
                      : "₹${initialWalletAmount.toStringAsFixed(2)}",
                  style: Styles.textStyleMediumBold(context),
                ),
              ],
            ),

            if (useWallet) ...[
              SizedBox(height: size.height * 0.004),
              Text(
                "Remaining Wallet: ₹${remainingWallet.toStringAsFixed(2)}",
                style: Styles.textSmall(context, color: Colors.grey.shade700),
              ),
            ],

            const Divider(height: 24),

            _priceRow(
              context,
              "Payable Amount",
              "₹${payable.toStringAsFixed(2)}",
              bold: true,
              color: AppColor.maincolor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    BuildContext context,
    String title,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: bold
                ? Styles.textStyleMediumBold(context)
                : Styles.textStyleMedium(context),
          ),
          Text(
            value,
            style: Styles.textStyleMediumBold(
              context,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
