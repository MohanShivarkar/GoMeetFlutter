// To parse this JSON data, do
//
//     final giftListApiModel = giftListApiModelFromJson(jsonString);

import 'dart:convert';

GiftListApiModel giftListApiModelFromJson(String str) => GiftListApiModel.fromJson(json.decode(str));

String giftListApiModelToJson(GiftListApiModel data) => json.encode(data.toJson());

class GiftListApiModel {
  List<Giftlist> giftlist;
  String responseCode;
  String result;
  String responseMsg;

  GiftListApiModel({
    required this.giftlist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory GiftListApiModel.fromJson(Map<String, dynamic> json) => GiftListApiModel(
    giftlist: List<Giftlist>.from(json["giftlist"].map((x) => Giftlist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "giftlist": List<dynamic>.from(giftlist.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Giftlist {
  String id;
  String img;
  String price;

  Giftlist({
    required this.id,
    required this.img,
    required this.price,
  });

  factory Giftlist.fromJson(Map<String, dynamic> json) => Giftlist(
    id: json["id"],
    img: json["img"],
    price: json["price"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "img": img,
    "price": price,
  };
}
