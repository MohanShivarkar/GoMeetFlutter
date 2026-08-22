import 'dart:convert';

ReferAndEarnApiModel referAndEarnApiModelFromJson(String str) => ReferAndEarnApiModel.fromJson(json.decode(str));

String referAndEarnApiModelToJson(ReferAndEarnApiModel data) => json.encode(data.toJson());

class ReferAndEarnApiModel {
  String responseCode;
  String result;
  String responseMsg;
  String code;
  String signupcredit;
  String refercredit;

  ReferAndEarnApiModel({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.code,
    required this.signupcredit,
    required this.refercredit,
  });

  factory ReferAndEarnApiModel.fromJson(Map<String, dynamic> json) => ReferAndEarnApiModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    code: json["code"],
    signupcredit: json["signupcredit"],
    refercredit: json["refercredit"],
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "code": code,
    "signupcredit": signupcredit,
    "refercredit": refercredit,
  };
}
