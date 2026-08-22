// To parse this JSON data, do
//
//     final myGiftListApiModel = myGiftListApiModelFromJson(jsonString);

import 'dart:convert';

MyGiftListApiModel myGiftListApiModelFromJson(String str) => MyGiftListApiModel.fromJson(json.decode(str));

String myGiftListApiModelToJson(MyGiftListApiModel data) => json.encode(data.toJson());

class MyGiftListApiModel {
  List<Giflist> giflist;
  String responseCode;
  String result;
  String responseMsg;

  MyGiftListApiModel({
    required this.giflist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory MyGiftListApiModel.fromJson(Map<String, dynamic> json) => MyGiftListApiModel(
    giflist: List<Giflist>.from(json["giflist"].map((x) => Giflist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "giflist": List<dynamic>.from(giflist.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Giflist {
  String giftImg;
  String name;
  String img;

  Giflist({
    required this.giftImg,
    required this.name,
    required this.img,
  });

  factory Giflist.fromJson(Map<String, dynamic> json) => Giflist(
    giftImg: json["gift_img"],
    name: json["name"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "gift_img": giftImg,
    "name": name,
    "img": img,
  };
}
