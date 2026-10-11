// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/presentation/firebase/chatting_provider.dart';
import 'package:dating/presentation/firebase/pickup_callpage.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/widgets/appbarr.dart';
import 'package:dating/presentation/widgets/other_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'package:dating/stubs/local_notifications_stub.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/config.dart';
import '../../../core/ui.dart';
import '../../../language/localization/app_localization.dart';
import '../../../main.dart';
import '../../firebase/chat_page.dart';
import '../../firebase/chat_service.dart';

class ChatScreen extends StatefulWidget {
  static const chatScreenRoute = "/chatScreen";

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AutomaticKeepAliveClientMixin<ChatScreen> {
  late ChattingProvider chattingProvider;

  @override
  void initState() {
    super.initState();
    chattingProvider = Provider.of<ChattingProvider>(context, listen: false);
    chattingProvider.demo1(context).then((value) {
      chattingProvider.isLoadingchat = false;
    });
    chattingProvider.getblockklisttApi(context);
    chattingProvider.searchController.clear();
    chattingProvider.isSearch = false;
  }

  bool get wantKeepAlive => true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    chattingProvider = Provider.of<ChattingProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appbarr(
        context,
        AppLocalizations.of(context)?.translate("Chats") ?? "Chats",
        traling: InkWell(
          onTap: () {
            chattingProvider.updateIsSearch();
          },
          child: SvgPicture.asset(
            "assets/icons/Search.svg",
            height: 22,
            width: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: chattingProvider.isLoadingchat
            ? Center(child: CircularProgressIndicator(color: AppColors.appColor))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    chattingProvider.isSearch
                        ? TextField(
                            style: Theme.of(context).textTheme.bodySmall!,
                            controller: chattingProvider.searchController,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(15),
                                isDense: true,
                                hintStyle:
                                    Theme.of(context).textTheme.bodySmall!,
                                hintText: AppLocalizations.of(context)
                                        ?.translate("Search..") ??
                                    "Search..",
                                suffixIcon: InkWell(
                                  onTap: () {
                                    chattingProvider.updateIsSearch();
                                  },
                                  child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: Center(
                                          child: SvgPicture.asset(
                                              "assets/icons/times.svg",
                                              height: 22,
                                              width: 22,
                                              colorFilter: ColorFilter.mode(
                                                  Theme.of(context)
                                                      .indicatorColor,
                                                  BlendMode.srcIn)))),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .dividerTheme
                                          .color!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .dividerTheme
                                          .color!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColors.appColor),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .dividerTheme
                                          .color!),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .dividerTheme
                                          .color!),
                                )),
                            onChanged: (s) {
                              chattingProvider.searchIteam(s);
                            })
                        : const SizedBox(),
                    chattingProvider.searchController.text.isEmpty
                        ? Expanded(child: _buildUserList())
                            : chattingProvider.searchIndexList.isEmpty
                                ? Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            AppLocalizations.of(context)
                                                    ?.translate(
                                                        "User Not Found") ??
                                                "User Not Found",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                      ],
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      itemCount: chattingProvider.searchIndexList.length,
                                      itemBuilder: (context, index) {
                                        var result = chattingProvider.searchIndexList[index];
                                        if (result >= chattingProvider.searchiteams.length) return const SizedBox();
                                        var itemData = Map<String,dynamic>.from(chattingProvider.searchiteams[result]);
                                        return ListTile(
                                            dense: true,
                                            onTap: () {
                                              print("result result:- ${result}");
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChattingPage(userData: itemData, proPic: chattingProvider.searchiteams[result]["image"], resiverUserId: chattingProvider.searchiteams[result]["uid"], resiverUseremail: chattingProvider.searchiteams[result]["name"],),
                                                  )
                                              );
                                            },
                                            contentPadding: const EdgeInsets.symmetric(vertical: 5),
                                            leading: chattingProvider.searchiteams[result]["image"] == "null"
                                                ? const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    radius: 25,
                                                    backgroundImage: AssetImage(
                                                      "assets/Image/05.png",
                                                    ))
                                                : CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    radius: 25,
                                                    backgroundImage: NetworkImage(
                                                        "${Config.baseUrl}${chattingProvider.searchiteams[result]["image"]}"),
                                                  ),
                                            title: Text(
                                              chattingProvider.searchiteams[result]["name"],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!,
                                            ),
                                            subtitle: Text(
                                                chattingProvider
                                                        .searchiteams[result]
                                                    ["message"],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            trailing: Text(
                                              DateFormat('hh:mm a')
                                                  .format(DateTime
                                                      .fromMicrosecondsSinceEpoch(
                                                          chattingProvider
                                                              .searchiteams[
                                                                  result]
                                                                  ["timestamp"]
                                                              .microsecondsSinceEpoch))
                                                  .toString(),
                                              style:
                                                  const TextStyle(fontSize: 10),
                                            ));
                                      },
                                    ),
                                  ),
                  ],
                ),
              ),
      ),
    );
  }

  // final ScrollController _scrollController = ScrollController();

  Widget _buildUserList() {
    final homeProv = Provider.of<HomeProvider>(context, listen: false);
    String uid = (homeProv.uid ?? "").toString();
    if (uid.isEmpty && homeProv.userlocalData.userLogin?.id != null) {
      uid = homeProv.userlocalData.userLogin!.id.toString();
    }
    if (uid.isEmpty) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chat_rooms")
          .where("participants", arrayContains: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading chats"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            leading: commonSimmer(height: 50, width: 50, radius: 50),
            title: Row(
              children: [
                commonSimmer(height: 10, width: 50, radius: 10),
              ],
            ),
            subtitle: Row(
              children: [
                commonSimmer(height: 10, width: 30, radius: 10),
              ],
            ),
            trailing: commonSimmer(height: 10, width: 30, radius: 10),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/Chat.svg",
                  height: 60,
                  width: 60,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).indicatorColor.withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)?.translate("No conversations yet") ?? "No conversations yet",
                  style: TextStyle(
                    color: Theme.of(context).indicatorColor.withOpacity(0.5),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort by timestamp descending
        final sortedDocs = List<QueryDocumentSnapshot>.from(docs);
        sortedDocs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>? ?? {};
          final dataB = b.data() as Map<String, dynamic>? ?? {};
          final tsA = dataA["timestamp"] is Timestamp ? (dataA["timestamp"] as Timestamp) : Timestamp(0, 0);
          final tsB = dataB["timestamp"] is Timestamp ? (dataB["timestamp"] as Timestamp) : Timestamp(0, 0);
          return tsB.compareTo(tsA);
        });

        return ListView.builder(
          shrinkWrap: true,
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            return _buildChatRoomItem(sortedDocs[index], uid);
          },
        );
      },
    );
  }

  Widget _buildChatRoomItem(DocumentSnapshot document, String myUid) {
    if (document.data() == null) return const SizedBox();
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    List participants = (data["participants"] as List? ?? []);
    String otherUid = participants.firstWhere((id) => id.toString() != myUid, orElse: () => "").toString();
    if (otherUid.isEmpty) return const SizedBox();

    // Check block list
    List apilist = [];
    apilist.addAll(chattingProvider.getblockListApi.blockByMe as Iterable);
    apilist.addAll(chattingProvider.getblockListApi.blockByOther as Iterable);
    if (apilist.contains(otherUid)) return const SizedBox();

    // Extract user info from room metadata or fallback to directoryUsers
    String otherName = "User";
    String otherPic = "";

    if (data["users"] is Map && data["users"][otherUid] is Map) {
      otherName = (data["users"][otherUid]["name"] ?? "").toString();
      otherPic = (data["users"][otherUid]["pic"] ?? "").toString();
    }

    if (otherName.isEmpty || otherName == "User") {
      final dirMatch = chattingProvider.directoryUsers.firstWhere(
        (u) => (u["uid"] ?? "").toString() == otherUid,
        orElse: () => <String, dynamic>{},
      );
      if (dirMatch.isNotEmpty) {
        otherName = (dirMatch["name"] ?? otherName).toString();
        if (otherPic.isEmpty) {
          otherPic = (dirMatch["image"] ?? "").toString();
        }
      }
    }

    String lastMsg = (data["lastMessage"] ?? "").toString();
    Timestamp? ts = data["timestamp"] is Timestamp ? data["timestamp"] as Timestamp : null;

    // Cache in searchiteams for search functionality
    final existingIndex = chattingProvider.searchiteams.indexWhere((m) => m["uid"] == otherUid);
    final itemMap = {
      "name": otherName,
      "image": otherPic,
      "uid": otherUid,
      "message": lastMsg,
      "timestamp": ts ?? Timestamp.now(),
    };
    if (existingIndex >= 0) {
      chattingProvider.searchiteams[existingIndex] = itemMap;
    } else {
      chattingProvider.searchiteams.add(itemMap);
    }

    final timeString = ts != null
        ? DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(ts.microsecondsSinceEpoch))
        : "";

    return ListTile(
      dense: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChattingPage(
              proPic: otherPic,
              resiverUserId: otherUid,
              resiverUseremail: otherName,
              userData: {
                "uid": otherUid,
                "name": otherName,
                "pro_pic": otherPic,
              },
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: (otherPic.isEmpty || otherPic == "null")
          ? const CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 25,
              backgroundImage: AssetImage("assets/Image/05.png"),
            )
          : CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 25,
              backgroundImage: NetworkImage(
                otherPic.startsWith("http") ? otherPic : "${Config.baseUrl}$otherPic",
              ),
            ),
      title: Text(
        otherName,
        style: Theme.of(context).textTheme.bodyMedium!,
      ),
      subtitle: Text(
        lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        timeString,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  ChatServices chatservices = ChatServices();

}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void listenFCM() async {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              presentBadge: true,
            ),
          ),
          payload: jsonEncode({
            "name": message.data["name"],
            "id": message.data["id"],
            "propic": message.data["propic"].toString(),
            "vcId": message.data["vcId"].toString(),
            "Audio": message.data["Audio"].toString(),
          }));
    }
  });
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  } else {}
}

// Future<void> initializeNotifications() async {
//   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//   const InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onSelectNotification: (String? payload) async {
//       print(" 0 0 0 11 0 0 0 11 0 0 0 11 0 0 0 11 0 0 0 $payload");
//
//       if (payload != null) {
//         Map data = jsonDecode(payload);
//
//         if (data["vcId"] == "null" && data["Audio"] == "null") {
//           navigatorKey.currentState?.push(MaterialPageRoute(
//             builder: (context) => ChattingPage(
//                 resiverUserId: data["id"],
//                 resiverUseremail: data["name"],
//                 proPic: data["propic"]),
//           ));
//         } else if (data["vcId"] != null && data["Audio"] == "null") {
//           navigatorKey.currentState?.push(MaterialPageRoute(
//             builder: (context) => PickUpCall(userData: data, isAudio: false),
//           ));
//         } else if (data["Audio"] != null) {
//           navigatorKey.currentState?.push(MaterialPageRoute(
//             builder: (context) => PickUpCall(userData: data, isAudio: true),
//           ));
//         }
//       }
//     },
//   );
// }

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  // Initialization
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification response
      final String? payload = response.payload;

      if (payload != null) {
        Map<String, dynamic> data = jsonDecode(payload);

        if (data["vcId"] == "null" && data["Audio"] == "null") {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => ChattingPage(
              resiverUserId: data["id"],
              resiverUseremail: data["name"],
              proPic: data["propic"],
              userData: data,
            ),
          ));
        } else if (data["vcId"] != null && data["Audio"] == "null") {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => PickUpCall(userData: data, isAudio: false),
          ));
        } else if (data["Audio"] != null) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => PickUpCall(userData: data, isAudio: true),
          ));
        }
      }
    },
  );
}

void loadFCM() async {
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      enableVibration: true,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
