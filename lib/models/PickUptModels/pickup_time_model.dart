class PickupTimeModel {
  final int id;
  final String time;

  PickupTimeModel({
    required this.id,
    required this.time,
  });

  factory PickupTimeModel.fromJson(Map<String, dynamic> json) {
    return PickupTimeModel(
      id: json['pickup_time_id'] ?? 0,
      time: json['pickup_time'] ?? '',
    );
  }

  static List<PickupTimeModel> listFromJson(List data) {
    return data.map((e) => PickupTimeModel.fromJson(e)).toList();
  }
}
