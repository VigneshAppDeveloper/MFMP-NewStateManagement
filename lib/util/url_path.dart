class UrlPath {
  static const LoginUrl loginUrl = LoginUrl();
  static const RestaurantUrl restaurantUrl = RestaurantUrl();
}

class LoginUrl {
  const LoginUrl();
  final String sendOTP = 'sentOTP';
  final String resendOTP = 'resendOTP';
  final String otpVerify = 'verifyOTP';
  final String createProfile = 'create_user';
  final String getProfile = 'getUserProfile';
}

class RestaurantUrl {
  const RestaurantUrl();
  final String getNearbyFranchise = 'getFranchise';
}
