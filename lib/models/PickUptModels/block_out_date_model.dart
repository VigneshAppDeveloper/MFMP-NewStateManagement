class BlockoutDateModel {
  final int id;
  final String date;
  final String reason;

  BlockoutDateModel({
    required this.id,
    required this.date,
    required this.reason,
  });

 factory BlockoutDateModel.fromJson(Map<String, dynamic> json) {
  return BlockoutDateModel(
    id: int.tryParse(json['franchise_id']?.toString() ?? '0') ?? 0,
    date: (json['blackout_date'] ?? json['date'] ?? '').toString(),
    reason: json['reason']?.toString() ?? '',
  );
}

}
