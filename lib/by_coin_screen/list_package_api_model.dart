// To parse this JSON data, do
//
//     final listPackageApiModel = listPackageApiModelFromJson(jsonString);

import 'dart:convert';

ListPackageApiModel listPackageApiModelFromJson(String str) => ListPackageApiModel.fromJson(json.decode(str));

String listPackageApiModelToJson(ListPackageApiModel data) => json.encode(data.toJson());

class ListPackageApiModel {
  List<Packlist> packlist;
  String responseCode;
  String result;
  String responseMsg;

  ListPackageApiModel({
    required this.packlist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory ListPackageApiModel.fromJson(Map<String, dynamic> json) => ListPackageApiModel(
    packlist: List<Packlist>.from(json["packlist"].map((x) => Packlist.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "packlist": List<dynamic>.from(packlist.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Packlist {
  String id;
  String coin;
  String amt;

  Packlist({
    required this.id,
    required this.coin,
    required this.amt,
  });

  factory Packlist.fromJson(Map<String, dynamic> json) => Packlist(
    id: json["id"],
    coin: json["coin"],
    amt: json["amt"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "coin": coin,
    "amt": amt,
  };
}
