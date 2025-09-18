class ProfileModel {
  final String userId;
  final String name;
  final String email;
  final String mobile;
  final String referralCode;
  final String wallet;
  final String image;
  final String imageUrl;

  ProfileModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.referralCode,
    required this.wallet,
    required this.image,
    required this.imageUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      referralCode: json['referral_code']?.toString() ?? '',
      wallet: json['wallet']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'referral_code': referralCode,
      'wallet': wallet,
      'image': image,
      'image_url': imageUrl,
    };
  }
}
