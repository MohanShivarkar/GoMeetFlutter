// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService extends ChangeNotifier {
  FirebaseFirestore? get _fireStore {
    if (kIsWeb || Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseFirestore.instance;
  }

  singInAndStoreData(
      {
        required String name,required String email, required String number, required String uid, required proPicPath
      }) async {
    try {
      final fireStore = _fireStore;
      if (fireStore == null) {
        return;
      }
      await FirebaseMessaging.instance.getToken().then((token) {
        fireStore.collection("datingUser").doc(uid).set({
          "uid": uid,
          "name": name,
          "email": email,
          "number": number,
          "token": "$token",
          "isOnline": false,
          "pro_pic": proPicPath
        });
      });
    } catch (e) {
      print("+++++++ FirebaseAuthException +++++ $e");
    }
  }

  singUpAndStore({
    required String name,required String email, required String number, required String uid, required proPicPath
  }) async {
    try {
      final fireStore = _fireStore;
      if (fireStore == null) {
        return;
      }
      await FirebaseMessaging.instance.getToken().then((token) {
        fireStore.collection("datingUser").doc(uid).set({
          "uid": uid,
          "name": name,
          "email": email,
          "number": number,
          "token": "$token",
          "isOnline": false,
          "pro_pic": proPicPath
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print("+++++++ FirebaseAuthException +++++ $e");
    }
  }
}
