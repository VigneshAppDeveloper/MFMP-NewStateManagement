class UrlPath {
  static const LoginUrl loginUrl = LoginUrl();
  static const RestaurantUrl restaurantUrl = RestaurantUrl();
  static const BiddingUrl biddingUrl = BiddingUrl();
  static const OrderHistoryUrl orderUrl = OrderHistoryUrl();
  static const RatingsUrl ratingUrl = RatingsUrl();
}

class LoginUrl {
  const LoginUrl();
  final String sendOTP = 'sentOTP';
  final String resendOTP = 'resendOTP';
  final String otpVerify = 'verifyOTP';
  final String createProfile = 'create_user';
  final String getProfile = 'getUserProfile';
  final String userWalletUpdate = "user_wallet_update";
  final String updateProfile = "userProfileUpdate";
  final String deleteAccount = "Tsit_BPM_Delete_Account";
}

class RestaurantUrl {
  const RestaurantUrl();
  final String getNearbyFranchise = 'getFranchise';
  final String getFoodCategory = 'getMenuTag';
  final String getFranchiseMenu = 'getMenu';
  final String getBanner = 'getBannerApp';
}

class BiddingUrl {
  const BiddingUrl();
  final String getTimeSlots = 'get_time';
  final String getBidderCount = 'get_bidder_count';
  final String createBidder = 'create_bidder';
  final String addBidding = 'add_bidding';
  final String getBidding = 'get_bidding';
  final String getWinner = 'winner';
   final String getTimeSlotWinnerList = 'get_winner';
  final String getPickupTime = 'get_pickup_time';

  final String addBiddingOrderDetails = 'add_order_and_payment_details';
  final String addFixedOrderDetails = 'add_fixed_order_details';
  final String getPhonePeResponse = 'get_phonepe_response';
}

class OrderHistoryUrl {
  const OrderHistoryUrl();
  final String getFixedOrderDetails = 'get_fixed_orderdetails';
  final String getBiddingOrderDetails = 'get_orderdetails';
}

class RatingsUrl {
  const RatingsUrl();
  final String getFranchiseRating = 'getFranchiseRatings';
  final String addFranchiseRating = 'addRatings';
}
