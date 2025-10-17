import '../config/app_config.dart';

class RatingModel {
  final String name;
  final String userImage;
  final double userRating;
  final String userFeedback;

  RatingModel({
    required this.name,
    required this.userImage,
    required this.userRating,
    required this.userFeedback,
  });

 factory RatingModel.fromJson(Map<String, dynamic> json) {
  String rawImage = json['user_image']?.toString() ?? '';
  String fullImage = rawImage.isNotEmpty && !rawImage.startsWith('http')
      ? AppConfig.instance.storageBaseUrl + rawImage
      : rawImage;

  return RatingModel(
    name: json['name'] ?? '',
    userImage: fullImage,
    userRating:
        double.tryParse(json['user_rating']?.toString() ?? '0') ?? 0.0,
    userFeedback: json['user_feedback'] ?? '',
  );
}

}
