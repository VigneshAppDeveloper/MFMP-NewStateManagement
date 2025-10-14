class UrlPath {
  static const LoginUrl loginUrl = LoginUrl();
  static const RestaurantUrl restaurantUrl = RestaurantUrl();
  static const BiddingUrl biddingUrl = BiddingUrl();
}

class LoginUrl {
  const LoginUrl();
  final String sendOTP = 'sentOTP';
  final String resendOTP = 'resendOTP';
  final String otpVerify = 'verifyOTP';
  final String createProfile = 'create_user';
  final String getProfile = 'getUserProfile';
  final String userWalletUpdate = "user_wallet_update";
}

class RestaurantUrl {
  const RestaurantUrl();
  final String getNearbyFranchise = 'getFranchise';
  final String getFoodCategory = 'getMenuTag';
  final String getFranchiseMenu = 'getMenu';
  
}
class BiddingUrl {
  const BiddingUrl();
  final String getTimeSlots = 'get_time';
  final String getBidderCount = 'get_bidder_count';
  final String createBidder = 'create_bidder';
  final String addBidding = 'add_bidding';
  final String getBidding = 'get_bidding';
  final String getWinner = 'winner';
    final String getPickupTime = 'get_pickup_time';

  final String addBiddingOrderDetails = 'add_order_and_payment_details';
  final String addFixedOrderDetails = 'add_fixed_order_details';
  final String getPhonePeResponse = 'get_phonepe_response';
}