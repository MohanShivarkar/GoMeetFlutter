// To parse this JSON data, do
//
//     final walletApiModel = walletApiModelFromJson(jsonString);

import 'dart:convert';

WalletApiModel walletApiModelFromJson(String str) => WalletApiModel.fromJson(json.decode(str));

String walletApiModelToJson(WalletApiModel data) => json.encode(data.toJson());

class WalletApiModel {
  String wallet;
  String responseCode;
  String result;
  String responseMsg;

  WalletApiModel({
    required this.wallet,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory WalletApiModel.fromJson(Map<String, dynamic> json) => WalletApiModel(
    wallet: json["wallet"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "wallet": wallet,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}
