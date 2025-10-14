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
      id: int.tryParse(json['id'].toString()) ?? 0,
      date: json['date']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
    );
  }
}
