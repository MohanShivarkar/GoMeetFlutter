import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserLogin? userLogin;
  String? responseCode;
  String? result;
  String? responseMsg;

  UserModel({
    this.userLogin,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? loginMap;
    if (json["UserLogin"] is Map) {
      loginMap = Map<String, dynamic>.from(json["UserLogin"]);
    } else if (json["UserLogn"] is Map) {
      loginMap = Map<String, dynamic>.from(json["UserLogn"]);
    } else if (json["user_login"] is Map) {
      loginMap = Map<String, dynamic>.from(json["user_login"]);
    } else if (json["userLogin"] is Map) {
      loginMap = Map<String, dynamic>.from(json["userLogin"]);
    } else if (json.containsKey("id") || json.containsKey("mobile") || json.containsKey("email")) {
      loginMap = json;
    }

    return UserModel(
      userLogin: loginMap == null ? null : UserLogin.fromJson(loginMap),
      responseCode: json["ResponseCode"]?.toString(),
      result: json["Result"]?.toString(),
      responseMsg: json["ResponseMsg"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "UserLogin": userLogin?.toJson(),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class UserLogin {
  String? id;
  String? name;
  String? mobile;
  String? password;
  DateTime? rdate;
  String? status;
  String? ccode;
  String? code;
  dynamic refercode;
  String? wallet;
  String? email;
  String? gender;
  String? lats;
  String? longs;
  String? profileBio;
  dynamic profilePic;
  DateTime? birthDate;
  String? searchPreference;
  String? radiusSearch;
  String? relationGoal;
  String? interest;
  String? language;
  String? religion;
  String? otherPic;
  String? planId;
  DateTime? planStartDate;
  DateTime? planEndDate;
  String? isSubscribe;
  String? historyId;
  String? height;
  dynamic identityPicture;
  String? isVerify;

  UserLogin({
    this.id,
    this.name,
    this.mobile,
    this.password,
    this.rdate,
    this.status,
    this.ccode,
    this.code,
    this.refercode,
    this.wallet,
    this.email,
    this.gender,
    this.lats,
    this.longs,
    this.profileBio,
    this.profilePic,
    this.birthDate,
    this.searchPreference,
    this.radiusSearch,
    this.relationGoal,
    this.interest,
    this.language,
    this.religion,
    this.otherPic,
    this.planId,
    this.planStartDate,
    this.planEndDate,
    this.isSubscribe,
    this.historyId,
    this.height,
    this.identityPicture,
    this.isVerify,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
    id: json["id"]?.toString(),
    name: json["name"]?.toString(),
    mobile: json["mobile"]?.toString(),
    password: json["password"]?.toString(),
    rdate: json["rdate"] == null ? null : DateTime.tryParse(json["rdate"].toString()),
    status: json["status"]?.toString(),
    ccode: json["ccode"]?.toString(),
    code: json["code"]?.toString(),
    refercode: json["refercode"],
    wallet: json["wallet"]?.toString(),
    email: json["email"]?.toString(),
    gender: json["gender"]?.toString(),
    lats: json["lats"]?.toString(),
    longs: json["longs"]?.toString(),
    profileBio: json["profile_bio"]?.toString(),
    profilePic: json["profile_pic"],
    birthDate: json["birth_date"] == null ? null : DateTime.tryParse(json["birth_date"].toString()),
    searchPreference: json["search_preference"]?.toString(),
    radiusSearch: json["radius_search"]?.toString(),
    relationGoal: json["relation_goal"]?.toString(),
    interest: json["interest"]?.toString(),
    language: json["language"]?.toString(),
    religion: json["religion"]?.toString(),
    otherPic: json["other_pic"]?.toString(),
    planId: json["plan_id"]?.toString(),
    planStartDate: json["plan_start_date"] == null ? null : DateTime.tryParse(json["plan_start_date"].toString()),
    planEndDate: json["plan_end_date"] == null ? null : DateTime.tryParse(json["plan_end_date"].toString()),
    isSubscribe: json["is_subscribe"]?.toString(),
    historyId: json["history_id"]?.toString(),
    height: json["height"]?.toString(),
    identityPicture: json["identity_picture"],
    isVerify: json["is_verify"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile": mobile,
    "password": password,
    "rdate": rdate?.toIso8601String(),
    "status": status,
    "ccode": ccode,
    "code": code,
    "refercode": refercode,
    "wallet": wallet,
    "email": email,
    "gender": gender,
    "lats": lats,
    "longs": longs,
    "profile_bio": profileBio,
    "profile_pic": profilePic,
    "birth_date": "${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}",
    "search_preference": searchPreference,
    "radius_search": radiusSearch,
    "relation_goal": relationGoal,
    "interest": interest,
    "language": language,
    "religion": religion,
    "other_pic": otherPic,
    "plan_id": planId,
    "plan_start_date": planStartDate?.toIso8601String(),
    "plan_end_date": planEndDate?.toIso8601String(),
    "is_subscribe": isSubscribe,
    "history_id": historyId,
    "height": height,
    "identity_picture": identityPicture,
    "is_verify": isVerify,
  };
}
