class PriceSummaryData {
  final double subtotal;
  final double gst;
  final double walletUsed;
  final double payable;
  final double parcelCharges;

PriceSummaryData({
  required this.subtotal,
  required this.gst,
  required this.walletUsed,
  required this.payable,
  required this.parcelCharges, // ✅ new
});
}
