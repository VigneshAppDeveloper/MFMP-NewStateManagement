import 'package:flutter/material.dart';
import 'package:my_food_my_price/util/color_constant.dart';

import '../../../models/BidderModels/winner_model.dart';
import '../../../util/styles.dart';

class PriceSummarySection extends StatefulWidget {
  final dynamic profile; // AppConstants.profile
  final List<WinnerModel> winners;
  final List<int> quantities; // from WinnerMenuList

  const PriceSummarySection({
    super.key,
    required this.profile,
    required this.winners,
    required this.quantities,
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

  // ✅ Calculate subtotal based on winners and current quantities
  double calculateSubtotal() {
    double total = 0.0;
    for (int i = 0; i < widget.winners.length; i++) {
      final price = double.tryParse(widget.winners[i].finalPrice) ?? 0.0;
      total += price * widget.quantities[i];
    }
    return total;
  }

  // ✅ GST 5%
  double calculateGST(double subtotal) => subtotal * 0.05;

  // ✅ Wallet Usage (max 30%)
  double calculateWalletUsage(double grandTotal) {
    if (!useWallet || initialWalletAmount <= 0) return 0.0;
    final maxWalletUse = grandTotal * 0.3;
    return initialWalletAmount >= maxWalletUse
        ? maxWalletUse
        : initialWalletAmount;
  }

  // ✅ Remaining Wallet
  double calculateRemainingWallet(double used) =>
      (initialWalletAmount - used).clamp(0, double.infinity);

  // ✅ Payable amount
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

            // ✅ Wallet Section
            Row(
              children: [
                Checkbox(
                  value: useWallet,
                  activeColor: AppColor.maincolor,
                  onChanged:
                      initialWalletAmount > 0
                          ? (val) {
                            setState(() => useWallet = val ?? false);
                          }
                          : null,
                ),
                Expanded(
                  child: Text(
                    useWallet
                        ? "Use up to 30% of bill from Wallet"
                        : "Use Wallet Balance",
                    style: Styles.textSmall(context).copyWith(
                      color:
                          initialWalletAmount > 0 ? Colors.black : Colors.grey,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
                Text(
                  useWallet
                      ? "₹${walletUsed.toStringAsFixed(2)}"
                      : "₹${initialWalletAmount.toStringAsFixed(2)}",
                  style: Styles.textStyleMediumBold(context),
                  textScaler: const TextScaler.linear(1.0),
                ),
              ],
            ),

            if (useWallet) ...[
              SizedBox(height: size.height * 0.004),
              Text(
                "Remaining Wallet: ₹${remainingWallet.toStringAsFixed(2)}",
                style: Styles.textSmall(context, color: Colors.grey.shade700),
                textScaler: const TextScaler.linear(1.0),
              ),
            ],

            const Divider(height: 24),

            // ✅ Payable amount
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
            style:
                bold
                    ? Styles.textStyleMediumBold(context)
                    : Styles.textStyleMedium(context),
            textScaler: const TextScaler.linear(1.0),
          ),
          Text(
            value,
            style: Styles.textStyleMediumBold(
              context,
              color: color ?? Colors.black,
            ),
            textScaler: const TextScaler.linear(1.0),
          ),
        ],
      ),
    );
  }
}
