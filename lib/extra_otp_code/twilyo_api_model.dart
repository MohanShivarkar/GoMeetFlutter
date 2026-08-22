// To parse this JSON data, do
//
//     final twilioApiModel = twilioApiModelFromJson(jsonString);

import 'dart:convert';

TwilioApiModel twilioApiModelFromJson(String str) => TwilioApiModel.fromJson(json.decode(str));

String twilioApiModelToJson(TwilioApiModel data) => json.encode(data.toJson());

class TwilioApiModel {
  String responseCode;
  String result;
  String responseMsg;
  int otp;

  TwilioApiModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.otp,
  });

  factory TwilioApiModel.fromJson(Map<String, dynamic> json) => TwilioApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "otp": otp,
  };
}
