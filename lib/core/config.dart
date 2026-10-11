class Config {

  static String? firebaseKey;

  static String? projectID = "lovecloud-bc2f8";

  // API Base URLs — environment-driven with fallback for development
  // Production: Set API_BASE_URL and API_BASE_URL_API via build flags
  //   flutter build web --dart-define=API_BASE_URL=https://lovecloud24.com/api/
  //   flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lovecloud24.com/api/',
  );

  static const String baseUrlApi = String.fromEnvironment(
    'API_BASE_URL_API',
    defaultValue: 'https://lovecloud24.com/api',
  );

  // OneSignal Key — environment-driven with fallback for development
  static const String oneSignelKey = String.fromEnvironment(
    'ONESIGNAL_KEY',
    defaultValue: '94b2b6c5-fabb-4454-a2b7-75cf75b84789',
  );

  static const Map<String, dynamic> header = {
    "Content-Type": "application/json"
  };

  static const String relationGoalList = "/goal.php";
  static const String getInterestList = "/interest.php";
  static const String languagelist = "/languagelist.php";
  static const String religionlist = "/religionlist.php";
  static const String regiseruser = "/reg_user.php";
  static const String socialLogin = "/social_login.php";
  static const String mobileCheck = "/mobile_check.php";
  static const String homeData = "/home_data.php";
  static const String profileInfo = "/profile_info.php";
  static const String userLogin = "/user_login.php";
  static const String mapInfo = "/map_info.php";
  static const String likeDislike = "/like_dislike.php";
  static const String editProfile = "/edit_profile.php";
  static const String likeMe = "/like_me.php";
  static const String favourite = "/favourite.php";
  static const String passed = "/passed.php";
  static const String newMatch = "/new_match.php";
  static const String delUnlike = "/del_unlike.php";
  static const String profileView = "/profile_view.php";
  static const String filter = "/filter.php";
  static const String plan = "/plan.php";
  static const String paymentGateway = "/paymentgateway.php";
  static const String planPurchase = "/plan_purchase.php";
  static const String faq = "/faq.php";
  static const String accDelete = "/acc_delete.php";
  static const String pageList = "/pagelist.php";
  static const String notificationList = "/u_notification_list.php";
  static const String userInfo = "/user_info.php";
  static const String forgetPassword = "/forget_password.php";
  static const String pro_pic = "/pro_image.php";
  static const String profileblock = "/profile_block.php";
  static const String reportapi = "/report.php";
  static const String blocklist = "/blocklist.php";
  static const String unblockapikey = "/unblock.php";
  static const String getblockapi = "/getblocklist.php";
  static const String identifyapi = "/identity_doc.php";
  static const String smstypeapi = "/sms_type.php";
  static const String msgotpapi = "/msg_otp.php";
  static const String twilyootpapi = "/twilio_otp.php";
  static const String walletupapi = "/wallet_up.php";
  static const String walletreportapi = "/wallet_report.php";
  static const String giftlistapi = "/gift_list.php";
  static const String packagelistapi = "/list_package.php";
  static const String packagepurcheaseapi = "/package_purchase.php";
  static const String coinreportapi = "/coin_report.php";
  static const String requestwithdrewapi = "/request_withdraw.php";
  static const String payoutlistapi = "/payout_list.php";
  static const String giftbuyapi = "/giftbuy.php";
  static const String mygiftapi = "/my_gift.php";
  static const String referansearnapi = "/getdata.php";
  static const String paystackapi = "paystack/index.php";

  // Legacy alias for backwards compatibility
  static String get oneSignel => oneSignelKey;
}
