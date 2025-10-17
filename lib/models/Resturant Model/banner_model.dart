import 'dart:convert';

import '../../config/app_config.dart';


class BannerModel {
  final int id;
  final String bannerImage;
  final String redirectUrl;

  BannerModel({
    required this.id,
    required this.bannerImage,
    required this.redirectUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final raw = json['banner_image']?.toString() ?? '';
    final fullImage = raw.isNotEmpty && !raw.startsWith('http')
        ? AppConfig.instance.storageBaseUrl + raw
        : raw;

    return BannerModel(
      id: json['id'] ?? 0,
      bannerImage: fullImage,
      redirectUrl: json['redirect_url']?.toString() ?? '',
    );
  }
}