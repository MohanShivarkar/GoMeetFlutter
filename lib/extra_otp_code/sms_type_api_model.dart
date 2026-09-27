import 'dart:convert';

SmaTypeApiModel smaTypeApiModelFromJson(String str) => SmaTypeApiModel.fromJson(json.decode(str));

String smaTypeApiModelToJson(SmaTypeApiModel data) => json.encode(data.toJson());

class SmaTypeApiModel {
  String responseCode;
  String result;
  String responseMsg;
  String smsType;
  String admobEnabled;
  String maintainanceEnabled;
  String socialLoginEnabled;
  String bannerId;
  String inId;
  String otpAuth;
  String giftFun;
  String iosInId;
  String iosBannerId;

  SmaTypeApiModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.smsType,
    required this.admobEnabled,
    required this.maintainanceEnabled,
    required this.socialLoginEnabled,
    required this.bannerId,
    required this.inId,
    required this.otpAuth,
    required this.giftFun,
    required this.iosInId,
    required this.iosBannerId,
  });

  factory SmaTypeApiModel.fromJson(Map<String, dynamic> json) => SmaTypeApiModel(
    responseCode: (json["ResponseCode"] ?? json["responseCode"] ?? "").toString(),
    result: (json["Result"] ?? json["result"] ?? "false").toString(),
    responseMsg: (json["ResponseMsg"] ?? json["responseMsg"] ?? "").toString(),
    smsType: (json["SMS_TYPE"] ?? json["sms_type"] ?? "Firebase").toString(),
    admobEnabled: (json["Admob_Enabled"] ?? json["admob_enabled"] ?? "No").toString(),
    maintainanceEnabled: (json["maintainance_Enabled"] ?? json["maintainance_enabled"] ?? "No").toString(),
    socialLoginEnabled: (json["Social_login_enabled"] ?? json["social_login_enabled"] ?? "No").toString(),
    bannerId: (json["banner_id"] ?? json["bannerId"] ?? "").toString(),
    inId: (json["in_id"] ?? json["inId"] ?? "").toString(),
    otpAuth: (json["otp_auth"] ?? json["otpAuth"] ?? "No").toString(),
    giftFun: (json["gift_fun"] ?? json["giftFun"] ?? "").toString(),
    iosInId: (json["ios_in_id"] ?? json["iosInId"] ?? "").toString(),
    iosBannerId: (json["ios_banner_id"] ?? json["iosBannerId"] ?? "").toString(),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "SMS_TYPE": smsType,
    "Admob_Enabled": admobEnabled,
    "maintainance_Enabled": maintainanceEnabled,
    "social_login_enabled": socialLoginEnabled,
    "banner_id": bannerId,
    "in_id": inId,
    "otp_auth": otpAuth,
    "gift_fun": giftFun,
    "ios_in_id": iosInId,
    "ios_banner_id": iosBannerId,
  };
}
