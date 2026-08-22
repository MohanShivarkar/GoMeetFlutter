// To parse this JSON data, do
//
//     final coinReportApiModel = coinReportApiModelFromJson(jsonString);

import 'dart:convert';

CoinReportApiModel coinReportApiModelFromJson(String str) => CoinReportApiModel.fromJson(json.decode(str));

String coinReportApiModelToJson(CoinReportApiModel data) => json.encode(data.toJson());

class CoinReportApiModel {
  List<Coinitem> coinitem;
  String coin;
  String coin_amt;
  String responseCode;
  String result;
  String responseMsg;
  String coin_limit;

  CoinReportApiModel({
    required this.coinitem,
    required this.coin_amt,
    required this.coin,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.coin_limit,
  });

  factory CoinReportApiModel.fromJson(Map<String, dynamic> json) => CoinReportApiModel(
    coinitem: List<Coinitem>.from(json["Coinitem"].map((x) => Coinitem.fromJson(x))),
    coin: json["coin"],
    coin_amt: json["coin_amt"],
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    coin_limit: json["coin_limit"],
  );

  Map<String, dynamic> toJson() => {
    "Coinitem": List<dynamic>.from(coinitem.map((x) => x.toJson())),
    "coin": coin,
    "coin_amt": coin_amt,
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "coin_limit": coin_limit,
  };
}

class Coinitem {
  String message;
  String status;
  String amt;

  Coinitem({
    required this.message,
    required this.status,
    required this.amt,
  });

  factory Coinitem.fromJson(Map<String, dynamic> json) => Coinitem(
    message: json["message"],
    status: json["status"],
    amt: json["amt"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "amt": amt,
  };
}
