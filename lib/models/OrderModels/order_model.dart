import 'package:intl/intl.dart';
import 'package:my_food_my_price/config/app_config.dart';

class OrderDetailModel {
  final int id;
  final String orderId;
  final String? timerId; // only for bidding
  final String franchiseId;
  final String userId;
  final String menuId;
  final int menuQuantity;
  final String totalMenuPrice;
  final String wallet;
  final String gst;
  final String? timeSlot; // only for bidding
  final PickUpPointModel? pickupPoint;
  final String pickupDate;
  final String pickupTime;
  final String? transactionId;
  final String? merchantTransactionId;
  final String transactionAmount;
  final String transactionStatus;
  final String paymentStatus;
  final String orderStatus;
  final int contactCustomer;
  final String date;
  final String time;
  final int ratingsCount;
  final double? ratingsAvgStarRating;
  final FranchiseModel? franchise;
  final MenuModel? menu;
  final UserModel? user;
  final dynamic ratings; // can be list, null, or single map

  OrderDetailModel({
    required this.id,
    required this.orderId,
    this.timerId,
    required this.franchiseId,
    required this.userId,
    required this.menuId,
    required this.menuQuantity,
    required this.totalMenuPrice,
    required this.wallet,
    required this.gst,
    this.timeSlot,
    this.pickupPoint,
    required this.pickupDate,
    required this.pickupTime,
    this.transactionId,
    this.merchantTransactionId,
    required this.transactionAmount,
    required this.transactionStatus,
    required this.paymentStatus,
    required this.orderStatus,
    required this.contactCustomer,
    required this.date,
    required this.time,
    required this.ratingsCount,
    this.ratingsAvgStarRating,
    this.franchise,
    this.menu,
    this.user,
    this.ratings,
  });

  // ✅ Combine `date` + `time` into a single DateTime for sorting
  DateTime get createdDateTime {
    try {
      if (date.isEmpty) return DateTime(1970);
      // date format like "2025-10-15" and time like "14:32:00"
      final datePart = DateFormat("yyyy-MM-dd").parse(date);
      final timePart =
          time.isNotEmpty
              ? DateFormat("HH:mm:ss").parse(time)
              : DateTime(datePart.year, datePart.month, datePart.day);
      return DateTime(
        datePart.year,
        datePart.month,
        datePart.day,
        timePart.hour,
        timePart.minute,
        timePart.second,
      );
    } catch (_) {
      return DateTime(1970);
    }
  }

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? '',
      timerId: json['timer_id']?.toString(),
      franchiseId: json['franchise_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      menuId: json['menu_id']?.toString() ?? '',
      menuQuantity: json['menu_quantity'] ?? 0,
      totalMenuPrice: json['total_menu_price']?.toString() ?? '0',
      wallet: json['wallet']?.toString() ?? '0',
      gst: json['gst']?.toString() ?? '0',
      timeSlot: json['time_slot'],
      pickupPoint:
          json['pickup_point'] != null
              ? PickUpPointModel.fromJson(json['pickup_point'])
              : null,
      pickupDate: json['pickup_date'] ?? '',
      pickupTime: json['pickup_time'] ?? '',
      transactionId: json['transaction_id'],
      merchantTransactionId: json['merchant_transaction_id'],
      transactionAmount: json['transaction_amount']?.toString() ?? '0',
      transactionStatus: json['transaction_status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      orderStatus: json['order_status'] ?? '',
      contactCustomer: json['contact_customer'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      ratingsCount: json['ratings_count'] ?? 0,
      ratingsAvgStarRating:
          json['ratings_avg_star_rating'] != null
              ? double.tryParse(json['ratings_avg_star_rating'].toString())
              : null,
      franchise:
          json['franchise'] != null
              ? FranchiseModel.fromJson(json['franchise'])
              : null,
      menu: json['menu'] != null ? MenuModel.fromJson(json['menu']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      ratings: json['ratings'],
    );
  }
}

class FranchiseModel {
  final int id;
  final String franchise;
  final String address;
  final DistrictModel? district;

  FranchiseModel({
    required this.id,
    required this.franchise,
    required this.address,
    this.district,
  });

  factory FranchiseModel.fromJson(Map<String, dynamic> json) {
    return FranchiseModel(
      id: json['id'] ?? 0,
      franchise: json['franchise'] ?? '',
      address: json['address'] ?? '',
      district:
          json['district'] != null
              ? DistrictModel.fromJson(json['district'])
              : null,
    );
  }
}

class DistrictModel {
  final int id;
  final String district;
  final StateModel? state;

  DistrictModel({required this.id, required this.district, this.state});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] ?? 0,
      district: json['district'] ?? '',
      state: json['state'] != null ? StateModel.fromJson(json['state']) : null,
    );
  }
}

class StateModel {
  final int id;
  final String state;

  StateModel({required this.id, required this.state});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(id: json['id'] ?? 0, state: json['state'] ?? '');
  }
}

class MenuModel {
  final int id;
  final String menuName;
  final String menuImage;

  MenuModel({
    required this.id,
    required this.menuName,
    required this.menuImage,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? 0,
      menuName: json['menu_name'] ?? '',
      menuImage:
          json['menu_image'] != null
              ? AppConfig.instance.storageBaseUrl + json['menu_image']
              : '',
    );
  }
}

class PickUpPointModel {
  final int id;
  final String ownerName;
  final String ownerNumber;
  final String pickupLocation;
  final String googleMapLink;

  PickUpPointModel({
    required this.id,
    required this.ownerName,
    required this.ownerNumber,
    required this.pickupLocation,
    required this.googleMapLink,
  });

  factory PickUpPointModel.fromJson(Map<String, dynamic> json) {
    return PickUpPointModel(
      id: json['id'] ?? 0,
      ownerName: json['owner_name'] ?? '',
      ownerNumber: json['owner_number']?.toString() ?? '',
      pickupLocation: json['pickup_location'] ?? '',
      googleMapLink: json['googlemap_link'] ?? '',
    );
  }
}

class UserModel {
  final int id;
  final String userId;
  final String name;
  final String mobile;

  UserModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile']?.toString() ?? '',
    );
  }
}
