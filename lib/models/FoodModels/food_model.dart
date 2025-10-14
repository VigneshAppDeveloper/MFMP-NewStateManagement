import '../../config/app_config.dart';

class FoodCategory {
  final int id;
  final String name;
  final String slug;
  final String kind;
  final String image;

  FoodCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.kind,
    required this.image,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    String rawImage = json['tag_image']?.toString() ?? '';
    String fullImage = rawImage.isNotEmpty && !rawImage.startsWith('http')
        ? AppConfig.instance.storageBaseUrl + rawImage
        : rawImage;

    return FoodCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      kind: json['kind'] ?? '',
      image: fullImage,
    );
  }
}
