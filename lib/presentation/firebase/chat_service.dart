import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../language/localization/app_localization.dart';

class ChatServices extends ChangeNotifier {
  FirebaseFirestore? get _firebaseStorage {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    return FirebaseFirestore.instance;
  }
  List<Message> messages = [];

  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  bool _loading = true;
  bool get loading => _loading;

  ChatServices() {
    focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      scrollDown();
    }
  }



  Future<void> sendMessage({required String receiverId, required String messeage,required context}) async {
    try{
      final firebaseStorage = _firebaseStorage;
      if (firebaseStorage == null) {
        return;
      }
      final String currentUserId = Provider.of<HomeProvider>(context,listen: false).uid;
      final String currentUserName = Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.name ?? "";

      Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(senderId: currentUserId, senderName: currentUserName, reciverId: receiverId, message: messeage, timestamp: timestamp);

      List<String> ids = [currentUserId, receiverId];
      ids.sort();

      String chatRoomId = ids.join("_");

      await firebaseStorage.collection("chat_rooms").doc(chatRoomId).collection("message").add(newMessage.toJson());
      scrollDown();
    }catch(e){
      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Something Want Wrong") ?? "Something Want Wrong");
    }

  }

  Stream<QuerySnapshot> getMessage({required String userId, required String otherUserId}) {
    final firebaseStorage = _firebaseStorage;
    if (firebaseStorage == null) {
      return const Stream.empty();
    }
    List ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return firebaseStorage.collection("chat_rooms").doc(chatRoomId).collection("message").orderBy("timestamp", descending: false).snapshots();
  }

  List<Message> getMessageNew({required String userId, required String otherUserId}) {
    final firebaseStorage = _firebaseStorage;
    if (firebaseStorage == null) {
      _loading = false;
      return messages;
    }
    List ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    firebaseStorage.collection("chat_rooms").doc(chatRoomId).collection("message").orderBy("timestamp", descending: false).snapshots(includeMetadataChanges: true).listen((messages){
      this.messages = messages.docs.map((doc) => Message.fromJson(doc.data())).toList();
      _loading = false;
      notifyListeners();
      scrollDown();
        });
    return messages;
  }

  void scrollDown() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.dispose();
  }






}







class Message {
  final String senderId;
  final String senderName;
  final String reciverId;
  final String message;
  final Timestamp timestamp;


  const Message({
    required this.senderId,
    required this.senderName,
    required this.reciverId,
    required this.timestamp,
    required this.message,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(
        reciverId: json['reciverId'],
        senderId: json['senderid'],
        timestamp: json['timestamp'],
        message: json['message'],
        senderName: json['senderName'],
      );

  Map<String, dynamic> toJson() => {
    'reciverId': reciverId,
    'senderid': senderId,
    'timestamp': timestamp,
    'message': message,
    'senderName': senderName,
  };
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String image;
  final DateTime lastActive;
  final bool isOnline;

  const UserModel({
    required this.name,
    required this.image,
    required this.lastActive,
    required this.uid,
    required this.email,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(
        uid: json['uid'],
        name: json['name'],
        image: json['image'],
        email: json['email'],
        isOnline: json['isOnline'] ?? false,
        lastActive: json['lastActive'].toDate(),
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'image': image,
    'email': email,
    'isOnline': isOnline,
    'lastActive': lastActive,
  };
}


