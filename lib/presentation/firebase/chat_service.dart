// ignore_for_file: avoid_print

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/data/localdatabase.dart';
import 'package:dating/data/models/usermodel.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:firebase_core/firebase_core.dart';
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

  StreamSubscription? _messagesSubscription;
  Timer? _loadingTimeoutTimer;

  ChatServices() {
    focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      scrollDown();
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String messeage,
    required BuildContext context,
  }) async {
    try {
      final firebaseStorage = _firebaseStorage;
      if (firebaseStorage == null) {
        print("FirebaseStorage is null");
        return;
      }

      final homeProv = Provider.of<HomeProvider>(context, listen: false);
      String currentUserId = (homeProv.uid ?? "").toString();
      String currentUserName = homeProv.userlocalData.userLogin?.name ?? "User";

      if (currentUserId.isEmpty) {
        final rawUser = await Preferences.fetchUserDetails();
        if (rawUser.isNotEmpty) {
          try {
            final userModel = userModelFromJson(rawUser);
            currentUserId = (userModel.userLogin?.id ?? "").toString();
            currentUserName = userModel.userLogin?.name ?? currentUserName;
          } catch (_) {}
        }
      }

      if (currentUserId.isEmpty) {
        print("Error: currentUserId empty in sendMessage");
        return;
      }

      Timestamp timestamp = Timestamp.now();

      Message newMessage = Message(
        senderId: currentUserId,
        senderName: currentUserName,
        reciverId: receiverId.toString(),
        message: messeage,
        timestamp: timestamp,
      );

      // Optimistically insert into local list immediately for instant UI feedback
      messages.add(newMessage);
      _loading = false;
      notifyListeners();
      scrollDown();

      List<String> ids = [currentUserId, receiverId.toString()];
      ids.sort();
      String chatRoomId = ids.join("_");

      await firebaseStorage
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("message")
          .add(newMessage.toJson());

      scrollDown();
    } catch (e) {
      print("ChatServices.sendMessage error: $e");
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)?.translate("Something Want Wrong") ?? "Something Want Wrong",
      );
    }
  }

  Stream<QuerySnapshot> getMessage({required String userId, required String otherUserId}) {
    final firebaseStorage = _firebaseStorage;
    if (firebaseStorage == null) {
      return const Stream.empty();
    }
    List<String> ids = [userId.toString(), otherUserId.toString()];
    ids.sort();
    String chatRoomId = ids.join("_");

    return firebaseStorage
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  List<Message> getMessageNew({required String userId, required String otherUserId}) {
    _loading = true;
    messages.clear();
    notifyListeners();

    final firebaseStorage = _firebaseStorage;
    if (firebaseStorage == null || userId.isEmpty || otherUserId.isEmpty) {
      _loading = false;
      notifyListeners();
      return messages;
    }

    _messagesSubscription?.cancel();
    _loadingTimeoutTimer?.cancel();

    // Safety timeout: ensure spinner never hangs indefinitely
    _loadingTimeoutTimer = Timer(const Duration(seconds: 3), () {
      if (_loading) {
        _loading = false;
        notifyListeners();
      }
    });

    List<String> ids = [userId.toString(), otherUserId.toString()];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      _messagesSubscription = firebaseStorage
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("message")
          .orderBy("timestamp", descending: false)
          .snapshots(includeMetadataChanges: true)
          .listen(
        (snapshot) {
          _loadingTimeoutTimer?.cancel();
          try {
            messages = snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList();
          } catch (e) {
            print("Error parsing messages: $e");
          }
          _loading = false;
          notifyListeners();
          scrollDown();
        },
        onError: (err) {
          print("Firestore getMessageNew error: $err");
          _loadingTimeoutTimer?.cancel();
          _loading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print("Error setting up message stream: $e");
      _loading = false;
      notifyListeners();
    }

    return messages;
  }

  void scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _loadingTimeoutTimer?.cancel();
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

  factory Message.fromJson(Map<String, dynamic> json) {
    Timestamp ts;
    final rawTs = json['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs;
    } else if (rawTs is int) {
      ts = Timestamp.fromMillisecondsSinceEpoch(rawTs);
    } else {
      ts = Timestamp.now();
    }

    return Message(
      reciverId: (json['reciverId'] ?? json['receiverId'] ?? '').toString(),
      senderId: (json['senderid'] ?? json['senderId'] ?? '').toString(),
      timestamp: ts,
      message: (json['message'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
    );
  }

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
        uid: (json['uid'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        image: (json['image'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        isOnline: json['isOnline'] ?? false,
        lastActive: json['lastActive'] is Timestamp
            ? (json['lastActive'] as Timestamp).toDate()
            : DateTime.now(),
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
