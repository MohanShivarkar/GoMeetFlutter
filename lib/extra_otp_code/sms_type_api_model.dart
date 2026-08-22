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
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    smsType: json["SMS_TYPE"],
    admobEnabled: json["Admob_Enabled"],
    maintainanceEnabled: json["maintainance_Enabled"],
    socialLoginEnabled: json["Social_login_enabled"],
    bannerId: json["banner_id"],
    inId: json["in_id"],
    otpAuth: json["otp_auth"],
    giftFun: json["gift_fun"],
    iosInId: json["ios_in_id"],
    iosBannerId: json["ios_banner_id"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "SMS_TYPE": smsType,
    "Admob_Enabled": admobEnabled,
    "maintainance_Enabled": maintainanceEnabled,
    "Social_login_enabled": socialLoginEnabled,
    "banner_id": bannerId,
    "in_id": inId,
    "otp_auth": otpAuth,
    "gift_fun": giftFun,
    "ios_in_id": iosInId,
    "ios_banner_id": iosBannerId,
  };
}
