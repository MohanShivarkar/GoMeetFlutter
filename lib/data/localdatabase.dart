import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String _userLoginKey = "UserLogin";
  static const String _legacyUserLoginKey = "UserLogn";

  static Future<void> saveUserDetails(var userData) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.setString(_userLoginKey, jsonEncode(userData));
    await instance.remove(_legacyUserLoginKey);
    log("Details saved!");
  }

  static Future fetchUserDetails() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    var userdata =
        instance.getString(_userLoginKey) ??
        instance.getString(_legacyUserLoginKey) ??
        "";
    return userdata;
  }

  static Future getDataFromLocal({required var key}) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    var localdata = instance.getString(key);
    return localdata;
  }

  static Future setDatawithKeyFromLocal(
      {required var key, required var data}) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.setString(key, jsonEncode(data));
  }

  static Future<void> clear() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.clear();
  }
}
