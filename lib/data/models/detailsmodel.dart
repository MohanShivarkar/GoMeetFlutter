import 'dart:convert';

DetailModel detailModelFromJson(String str) => DetailModel.fromJson(json.decode(str));

String detailModelToJson(DetailModel data) => json.encode(data.toJson());

class DetailModel {
  String? responseCode;
  String? result;
  String? responseMsg;
  Profileinfo? profileinfo;

  DetailModel({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.profileinfo,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json) => DetailModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    profileinfo: json["profileinfo"] == null ? null : Profileinfo.fromJson(json["profileinfo"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "profileinfo": profileinfo?.toJson(),
  };
}

class Profileinfo {
  String? profileId;
  String? profileName;
  String? profileBio;
  int? profileAge;
  String? profileDistance;
  List<String>? profileImages;
  double? matchRatio;
  String? isVerify;
  String? height;
  String? relationTitle;
  String? relationSubtitle;
  String? religionTitle;
  List<InterestListElement>? interestList;
  List<InterestListElement>? languageList;

  Profileinfo({
    this.profileId,
    this.profileName,
    this.profileBio,
    this.profileAge,
    this.profileDistance,
    this.profileImages,
    this.matchRatio,
    this.isVerify,
    this.height,
    this.relationTitle,
    this.relationSubtitle,
    this.religionTitle,
    this.interestList,
    this.languageList,
  });

  factory Profileinfo.fromJson(Map<String, dynamic> json) => Profileinfo(
    profileId: json["profile_id"],
    profileName: json["profile_name"],
    profileBio: json["profile_bio"],
    profileAge: json["profile_age"],
    profileDistance: json["profile_distance"],
    profileImages: json["profile_images"] == null ? [] : List<String>.from(json["profile_images"]!.map((x) => x)),
    matchRatio: json["match_ratio"]?.toDouble(),
    isVerify: json["is_verify"],
    height: json["height"],
    // height: json["height"] == null ? json["height"] : int.parse(json["height"]),
    relationTitle: json["relation_title"],
    relationSubtitle: json["relation_subtitle"],
    religionTitle: json["religion_title"],
    interestList: json["interest_list"] == null ? [] : List<InterestListElement>.from(json["interest_list"]!.map((x) => InterestListElement.fromJson(x))),
    languageList: json["language_list"] == null ? [] : List<InterestListElement>.from(json["language_list"]!.map((x) => InterestListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "profile_id": profileId,
    "profile_name": profileName,
    "profile_bio": profileBio,
    "profile_age": profileAge,
    "profile_distance": profileDistance,
    "profile_images": profileImages == null ? [] : List<dynamic>.from(profileImages!.map((x) => x)),
    "match_ratio": matchRatio,
    "is_verify": isVerify,
    "height": height,
    "relation_title": relationTitle,
    "relation_subtitle": relationSubtitle,
    "religion_title": religionTitle,
    "interest_list": interestList == null ? [] : List<dynamic>.from(interestList!.map((x) => x.toJson())),
    "language_list": languageList == null ? [] : List<dynamic>.from(languageList!.map((x) => x.toJson())),
  };
}

class InterestListElement {
  String? title;
  String? img;

  InterestListElement({
    this.title,
    this.img,
  });

  factory InterestListElement.fromJson(Map<String, dynamic> json) => InterestListElement(
    title: json["title"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "img": img,
  };
}
