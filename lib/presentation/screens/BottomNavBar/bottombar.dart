import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/core/ui.dart';
import 'package:dating/data/localdatabase.dart';
import 'package:dating/data/models/usermodel.dart';
import 'package:dating/main.dart';
import 'package:dating/presentation/firebase/pickup_callpage.dart';
import 'package:dating/presentation/screens/BottomNavBar/match/browes.dart';
import 'package:dating/presentation/screens/BottomNavBar/chats.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/screens/BottomNavBar/home_screen.dart';
import 'package:dating/presentation/screens/BottomNavBar/mapscreen.dart';
import 'package:dating/presentation/screens/other/premium/premium.dart';
import 'package:dating/presentation/screens/other/profileScreen/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';
import '../../../Logic/cubits/Home_cubit/home_cubit.dart';
import '../../../Logic/cubits/Home_cubit/homestate.dart';
import '../../../core/config.dart';
import '../../firebase/chat_page.dart';
import 'package:dating/core/web_call_helper.dart';

class BottomBar extends StatefulWidget {
  static const String bottomBarRoute = "/bottomBar";
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {

  List pages = [
    // HomePage(),
    const HomeScreen(),
    const MapScreen(),
    const BrowesPage(),
    // const LikesScreen(),
    const ChatScreen(),
    const ProfilePage(),
  ];
  List bottomItems = [
    "Home",
    "Maps",
    "Match",
    "Chats",
    "Profile",
  ];

  List bottomItemsIcons = [
    "assets/icons/Home.svg",
    "assets/icons/Discovery.svg",
    "assets/icons/Heart.svg",
    "assets/icons/Chat.svg",
    "assets/icons/Profile.svg",
  ];

  List bottomItemsIconsfill = [
    "assets/icons/Home-fill.svg",
    "assets/icons/Discovery-fill.svg",
    "assets/icons/Heart-fill.svg",
    "assets/icons/Chat-fill.svg",
    "assets/icons/Profile-fill.svg",
  ];

  late HomeProvider homeProvider;
  StreamSubscription? _callSubscription;
  StreamSubscription? _incomingMessageSubscription;
  Timer? _heartbeatTimer;
  OverlayEntry? _notificationOverlayEntry;
  Timer? _notificationDismissTimer;
  bool _isIncomingCallActive = false;
  String? _currentUserUid;

  void _updateUserPresence(String uid, bool isOnline) {
    if (uid.isEmpty) return;
    try {
      FirebaseFirestore.instance.collection("datingUser").doc(uid).set({
        "uid": uid,
        "isOnline": isOnline,
        "lastActive": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).catchError((_) {});
    } catch (_) {}
  }

  void _showWhatsAppNotificationBanner({
    required String senderId,
    required String senderName,
    required String senderPic,
    required String message,
  }) {
    if (!mounted) return;
    _notificationOverlayEntry?.remove();
    _notificationOverlayEntry = null;
    _notificationDismissTimer?.cancel();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 10,
        left: 14,
        right: 14,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              _notificationOverlayEntry?.remove();
              _notificationOverlayEntry = null;
              _notificationDismissTimer?.cancel();
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (c) => ChattingPage(
                    resiverUserId: senderId,
                    resiverUseremail: senderName,
                    proPic: senderPic,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00A884).withOpacity(0.5), width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF128C7E),
                    backgroundImage: senderPic.isNotEmpty
                        ? NetworkImage(senderPic.startsWith("http") ? senderPic : "${Config.baseUrl}$senderPic")
                        : null,
                    child: senderPic.isEmpty
                        ? const Icon(Icons.person, color: Colors.white, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                senderName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text(
                              "Just now",
                              style: TextStyle(
                                color: Color(0xFF25D366),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A884),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    _notificationOverlayEntry = overlayEntry;
    overlay.insert(overlayEntry);

    _notificationDismissTimer = Timer(const Duration(seconds: 5), () {
      if (_notificationOverlayEntry == overlayEntry) {
        _notificationOverlayEntry?.remove();
        _notificationOverlayEntry = null;
      }
    });
  }

  void _listenForIncomingMessages(String uid) {
    if (uid.isEmpty) return;
    _incomingMessageSubscription?.cancel();

    _incomingMessageSubscription = FirebaseFirestore.instance
        .collection("chat_rooms")
        .where("participants", arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added || change.type == DocumentChangeType.modified) {
          final data = change.doc.data();
          if (data == null) continue;
          final lastSender = (data["lastSender"] ?? "").toString();
          final lastMessage = (data["lastMessage"] ?? "").toString();
          final timestamp = data["timestamp"];
          final isDelivered = data["isDelivered"] == true;
          final isRead = data["isRead"] == true;

          if (lastSender.isNotEmpty && lastSender != uid) {
            // 1. Recipient is active/logged in: Mark room and un-delivered messages as delivered
            if (!isDelivered) {
              change.doc.reference.update({"isDelivered": true}).catchError((_) {});
              change.doc.reference
                  .collection("message")
                  .orderBy("timestamp", descending: true)
                  .limit(10)
                  .get()
                  .then((msgs) {
                for (var m in msgs.docs) {
                  final mData = m.data();
                  if ((mData["reciverId"] ?? mData["receiverId"] ?? "").toString() == uid && mData["isDelivered"] != true) {
                    m.reference.update({"isDelivered": true}).catchError((_) {});
                  }
                }
              }).catchError((_) {});
            }

            // 2. If message is fresh (< 25s) and user not currently inside that sender's chat
            DateTime? msgTime;
            if (timestamp is Timestamp) {
              msgTime = timestamp.toDate();
            }
            final isRecent = msgTime != null && DateTime.now().difference(msgTime).inSeconds < 25;

            if (isRecent && !isRead && ChattingPage.activeChatUserId != lastSender) {
              String senderName = data["lastSenderName"] ?? "New Message";
              String senderPic = "";
              if (data["users"] is Map && data["users"][lastSender] is Map) {
                senderName = (data["users"][lastSender]["name"] ?? senderName).toString();
                senderPic = (data["users"][lastSender]["pic"] ?? "").toString();
              }

              _showWhatsAppNotificationBanner(
                senderId: lastSender,
                senderName: senderName,
                senderPic: senderPic,
                message: lastMessage,
              );
              final fullPic = senderPic.isNotEmpty ? (senderPic.startsWith("http") ? senderPic : "${Config.baseUrl}$senderPic") : "";
              WebCallHelper.showWebNotification(
                senderName,
                lastMessage,
                fullPic,
              );
            }
          }
        }
      }
    }, onError: (err) {
      print("Chat room incoming listener error: $err");
    });
  }

  void _listenForCalls(String uid) {
    if (uid.isEmpty) return;
    _callSubscription?.cancel();
    _callSubscription = FirebaseFirestore.instance
        .collection("user_calls")
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || snapshot.data() == null) return;
      final data = snapshot.data()!;
      final status = data["status"]?.toString() ?? "";
      if (status == "ringing" && !_isIncomingCallActive) {
        _isIncomingCallActive = true;
        WebCallHelper.playRingtone();
        final cName = data["callerName"]?.toString() ?? "User";
        final cPic = data["callerPic"]?.toString() ?? "";
        final fullPic = cPic.isNotEmpty ? (cPic.startsWith("http") ? cPic : "${Config.baseUrl}$cPic") : "";
        WebCallHelper.showWebNotification(
          "Incoming ${data["callType"] == "audio" ? "Audio" : "Video"} Call",
          "Call from $cName. Tap to answer.",
          fullPic,
        );
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (ctx) => PickUpCall(
              userData: {
                "id": data["callerId"]?.toString() ?? "",
                "name": data["callerName"]?.toString() ?? "User",
                "senderName": data["callerName"]?.toString() ?? "User",
                "propic": data["callerPic"]?.toString() ?? "",
                "Audio": data["channel"]?.toString() ?? "",
                "vcId": data["channel"]?.toString() ?? "",
              },
              isAudio: data["callType"] == "audio",
            ),
          ),
        ).then((_) {
          WebCallHelper.stopRingtone();
          _isIncomingCallActive = false;
          FirebaseFirestore.instance
              .collection("user_calls")
              .doc(uid)
              .set({"status": "idle"}, SetOptions(merge: true));
        });
      }
    });
  }

  @override
  void dispose() {
    if (_currentUserUid != null && _currentUserUid!.isNotEmpty) {
      _updateUserPresence(_currentUserUid!, false);
    }
    _callSubscription?.cancel();
    _incomingMessageSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _notificationOverlayEntry?.remove();
    _notificationDismissTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WebCallHelper.requestNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final homeProv = Provider.of<HomeProvider>(context, listen: false);
      homeProv.setSelectPage(0);
      String uid = (homeProv.uid ?? "").toString();
      if (uid.isEmpty && homeProv.userlocalData.userLogin?.id != null) {
        uid = homeProv.userlocalData.userLogin!.id.toString();
      }
      if (uid.isNotEmpty) {
        _currentUserUid = uid;
        _updateUserPresence(uid, true);
        _listenForCalls(uid);
        _listenForIncomingMessages(uid);
        _heartbeatTimer?.cancel();
        _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
          _updateUserPresence(uid, true);
        });
      } else {
        Preferences.fetchUserDetails().then((raw) {
          if (raw.isNotEmpty) {
            try {
              final userModel = userModelFromJson(raw);
              final fetchedId = (userModel.userLogin?.id ?? "").toString();
              if (fetchedId.isNotEmpty) {
                _currentUserUid = fetchedId;
                _updateUserPresence(fetchedId, true);
                _listenForCalls(fetchedId);
                _listenForIncomingMessages(fetchedId);
                _heartbeatTimer?.cancel();
                _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
                  _updateUserPresence(fetchedId, true);
                });
              }
            } catch (_) {}
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          bottomNavigationBar: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 63,
                    margin: const EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xff27262B),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BlocBuilder<HomePageCubit, HomePageStates>(
                            builder: (context, state) {
                            if(state is HomeCompleteState){
                              return ListView.builder(
                                clipBehavior: Clip.none,
                                itemCount: bottomItemsIcons.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () {
                                        homeProvider.setSelectPage(index);
                                        if(homeProvider.selectPageIndex == 2 && state.homeData.likeMenu == "0") {
                                          homeProvider.setSelectPage(0);
                                          Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute);
                                        }else if(homeProvider.selectPageIndex == 3 && (state.homeData.chat == "0")) {
                                          homeProvider.setSelectPage(0);
                                          Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute);
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        width: constraints.maxWidth * 0.1833,
                                       margin: const EdgeInsets.symmetric(vertical: 5),
                                       decoration: BoxDecoration(
                                           color: homeProvider.selectPageIndex == index ? AppColors.white : Colors.transparent,
                                         shape: BoxShape.circle,
                                       ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [

                                            SvgPicture.asset(
                                              homeProvider.selectPageIndex == index ? bottomItemsIconsfill[index] : bottomItemsIcons[index],
                                              width: 22,
                                              height: 22,
                                              color: homeProvider.selectPageIndex == index
                                                  ? AppColors.appColor
                                                  : AppColors.white,
                                            ),

                                          ],
                                        ),
                                      ));
                                },
                              );
                            }else{
                              return ListView.builder(
                                clipBehavior: Clip.none,
                                itemCount: bottomItemsIcons.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {

                                  return Container(
                                    height: 50,
                                    width: constraints.maxWidth * 0.1833,
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                        color: homeProvider.selectPageIndex == index ? AppColors.white : Colors.transparent,
                                        shape: BoxShape.circle
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        SvgPicture.asset(
                                          homeProvider.selectPageIndex == index ? bottomItemsIconsfill[index] : bottomItemsIcons[index],
                                          width: 22,
                                          height: 22,
                                          color: homeProvider.selectPageIndex == index
                                              ? AppColors.appColor
                                              : AppColors.white,
                                        ),

                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        ),
                         ],
                       ),
                     ),
                ),
                 ],
               ),
          ),
          body: pages[homeProvider.selectPageIndex],
        );
      },
    );
  }
}
