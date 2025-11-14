import 'package:my_food_my_price/config/app_config.dart';

class PolicyModel {
  final int id;
  final String file;
  final String fileType;

  PolicyModel({
    required this.id,
    required this.file,
    required this.fileType,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] ?? 0,
      file: withStorageUrl(json['file']),
      fileType: json['file_type'] ?? '',
    );
  }

  static String withStorageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http')
        ? path
        : AppConfig.instance.storageBaseUrl + path;
  }
}