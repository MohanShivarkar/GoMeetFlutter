// To parse this JSON data, do
//
//     final msgApiModel = msgApiModelFromJson(jsonString);

import 'dart:convert';

MsgApiModel msgApiModelFromJson(String str) => MsgApiModel.fromJson(json.decode(str));

String msgApiModelToJson(MsgApiModel data) => json.encode(data.toJson());

class MsgApiModel {
  String responseCode;
  String result;
  String responseMsg;
  int otp;

  MsgApiModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.otp,
  });

  factory MsgApiModel.fromJson(Map<String, dynamic> json) => MsgApiModel(
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
