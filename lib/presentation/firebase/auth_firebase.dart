// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  singInAndStoreData(
      {
        required String name,required String email, required String number, required String uid, required proPicPath
      }) async {
    String token = "";
    try {
      token = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 3)) ?? "";
    } catch (e) {
      print("Token fetch skipped/failed: $e");
    }
    try {
      await _fireStore.collection("datingUser").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "number": number,
        "token": token,
        "isOnline": true,
        "pro_pic": proPicPath
      }, SetOptions(merge: true));
    } catch (e) {
      print("+++++++ FirebaseAuthException +++++ $e");
    }
  }

  singUpAndStore({
    required String name,required String email, required String number, required String uid, required proPicPath
  }) async {
    String token = "";
    try {
      token = await FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 3)) ?? "";
    } catch (e) {
      print("Token fetch skipped/failed: $e");
    }
    try {
      await _fireStore.collection("datingUser").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "number": number,
        "token": token,
        "isOnline": true,
        "pro_pic": proPicPath
      }, SetOptions(merge: true));
    } catch (e) {
      print("+++++++ FirebaseAuthException +++++ $e");
    }
  }
}