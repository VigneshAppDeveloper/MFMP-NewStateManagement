import '../../config/app_config.dart';

import '../../config/app_config.dart';

class TimeSlotWinnerResponse {
  final List<TimeSlotWinnerListModel> winners;
  final int winnerCount;
  final int totalBidderCount;

  TimeSlotWinnerResponse({
    required this.winners,
    required this.winnerCount,
    required this.totalBidderCount,
  });

  factory TimeSlotWinnerResponse.fromJson(Map<String, dynamic> json) {
  final List<dynamic> winnerList = json['winners'] ?? [];

  return TimeSlotWinnerResponse(
    winners: winnerList
        .map((e) => TimeSlotWinnerListModel.fromJson(e))
        .toList(),
    winnerCount: int.tryParse(json['winner_count']?.toString() ?? '0') ?? 0,
    totalBidderCount:
        int.tryParse(json['total_bidder_count']?.toString() ?? '0') ?? 0,
  );
}

}

class TimeSlotWinnerListModel {
  final String timerId;
  final String franchiseId;
  final String userId;
  final String menuId;
  final String finalPrice;
  final String date;
  final MenuData menu;
  final TimeSlotData timeslot;
  final UserData user;

  TimeSlotWinnerListModel({
    required this.timerId,
    required this.franchiseId,
    required this.userId,
    required this.menuId,
    required this.finalPrice,
    required this.date,
    required this.menu,
    required this.timeslot,
    required this.user,
  });

  factory TimeSlotWinnerListModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotWinnerListModel(
      timerId: json['timer_id']?.toString() ?? '',
      franchiseId: json['franchise_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      finalPrice: json['final_price']?.toString() ?? '0.0',
      date: json['date']?.toString() ?? '',
      menu: MenuData.fromJson(json['menus'] ?? {}),
      timeslot: TimeSlotData.fromJson(json['timeslot'] ?? {}),
      user: UserData.fromJson(json['users'] ?? {}),
    );
  }
}

class MenuData {
  final int id;
  final String menuName;
  final String description;
  final String menuImage;

  MenuData({
    required this.id,
    required this.menuName,
    required this.description,
    required this.menuImage,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) {
    final raw = json['menu_image']?.toString() ?? '';
    final fullImage = raw.isNotEmpty && !raw.startsWith('http')
        ? AppConfig.instance.storageBaseUrl + raw
        : raw;

    return MenuData(
      id: json['id'] ?? 0,
      menuName: json['menu_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      menuImage: fullImage,
    );
  }
}

class TimeSlotData {
  final int id;
  final String startingTime;
  final String endTime;

  TimeSlotData({
    required this.id,
    required this.startingTime,
    required this.endTime,
  });

  factory TimeSlotData.fromJson(Map<String, dynamic> json) {
    return TimeSlotData(
      id: json['id'] ?? 0,
      startingTime: json['starting_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class UserData {
  final int id;
  final String name;

  UserData({
    required this.id,
    required this.name,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
