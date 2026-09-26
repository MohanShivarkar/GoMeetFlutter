// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/core/api.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/ui.dart';
import '../../data/models/getblocklistapimodel.dart';
import '../../language/localization/app_localization.dart';
import 'chat_bubble.dart';
import 'chat_service.dart';

class ChattingProvider extends ChangeNotifier{
TextEditingController searchController = TextEditingController();


bool isSearch = false;

bool isLoading = false;

updateIsLoading(bool value){
  isLoading = value;
  notifyListeners();
}

updateIsSearch(){
  isSearch =! isSearch;
  notifyListeners();
}
  String? uid;
  updateUid(String value){
    uid = value;
  }

  TextEditingController controller = TextEditingController();

  ChatServices chatservices = ChatServices();
  String fmctoken = "";

  Future<dynamic> isMeassageAvalable(String uid) async {
    try {
      CollectionReference collectionReference =  FirebaseFirestore.instance.collection('datingUser');
      DocumentSnapshot value = await collectionReference.doc(uid).get();
      if (value.exists && value.data() != null) {
        var fields = value.data() as Map<String, dynamic>;
        fmctoken = fields["token"]?.toString() ?? "";
        notifyListeners();
      }
    } catch (e) {
      print("isMeassageAvalable error: $e");
    }
  }

List searchIndexList = [];
List<Map> searchiteams = [];

searchIteam(s){

  searchIndexList = [];

  for (int i = 0; i < searchiteams.length; i++) {
    if (searchiteams[i]["name"].toLowerCase().contains(s.toLowerCase())) {
      final ids = searchiteams.map<String>((e) => e['uid']!).toSet();

      searchiteams.retainWhere((Map x) {
        return ids.remove(x['uid']);
      });

  notifyListeners();
      searchIndexList.add(i);
    } else {
      notifyListeners();
    }
  }

}


List userData = [];
bool isLoadingchat = true;



Future demo1(context) async{
  try {
    userData.clear();
    Stream<QuerySnapshot<Map<String, dynamic>>> snep = FirebaseFirestore.instance.collection("datingUser").snapshots();
    snep.listen((element) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> data = element.docs;
      for(int a = 0; a < data.length; a++){
        Map<String, dynamic> dataa = data[a].data();
        var currentUid = Provider.of<HomeProvider>(context, listen: false).uid;
        if (currentUid == null) continue;
        Stream<QuerySnapshot<Object?>> snapshot = chatservices.getMessage(userId: dataa["uid"], otherUserId: currentUid);
        snapshot.listen((snapElement) {
          List snapDocs = snapElement.docs;
          for(int i = 0; i < snapDocs.length; i++){
            Map dataa1 = snapDocs[i].data() as Map;
            var currentName = Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin?.name;
            if (currentName != null && currentName != dataa["name"]){
              userData.add({
                "name": dataa["name"],
                "image": dataa["pro_pic"],
                "uid": dataa["uid"],
                "message": dataa1["message"],
                "timestamp": dataa1["timestamp"]
              });
              notifyListeners();
            }
          }
          isLoadingchat = false;
          notifyListeners();
        }, onError: (err) {
          print("Chat messages stream error: $err");
          isLoadingchat = false;
          notifyListeners();
        });
      }
      isLoadingchat = false;
      notifyListeners();
    }, onError: (err) {
      print("DatingUser stream error: $err");
      isLoadingchat = false;
      notifyListeners();
    });
  } catch (e) {
    print("Error in demo1: $e");
    isLoadingchat = false;
    notifyListeners();
  }
}

  final bool _emojiShowing = false;

  late final FocusNode _focusNode;
  // _focusNode = FocusNode();

ScrollController scrollController = ScrollController();

void _scrollToLastMessage() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  });
}





  Widget buildMessageInpurt({required resiverUserId,required context,required void Function() ontap,required FocusNode? focusnodee,required Icon icon, required String images,required void Function() ontap1}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: Theme.of(context).textTheme.bodyMedium!,
              focusNode: focusnodee,
              controller: controller,
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: ontap,
                        child: icon,
                      ),
                      const SizedBox(width: 5,),
                      InkWell(
                        onTap: ontap1,
                        child: SvgPicture.asset(images,height: 29, width: 29,),
                      ),
                      const SizedBox(width: 5,),
                      InkWell(
                        onTap: () {
                          sendMessage(resiverUserId: resiverUserId, fmctoken: fmctoken, context: context);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          height: 40,width: 40,decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.appColor,
                        ),
                          child: Center(child: SvgPicture.asset("assets/icons/Send.svg")),
                        ),
                      ),
                    ],
                  ),
                  hintStyle: Theme.of(context).textTheme.bodySmall!,
                  // hintText: "Say Something..".tr,
                  hintText: AppLocalizations.of(context)?.translate("Say Something..") ?? "Say Something..",
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).dividerTheme.color!),
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).dividerTheme.color!),
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.appColor),
                      borderRadius: BorderRadius.circular(12)),
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).dividerTheme.color!),
                      borderRadius: BorderRadius.circular(12))
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget buildMessageList({required String resiverUserId,required context}) =>
      Consumer<ChatServices>(
        builder: (context, value, child) =>
        value.loading
            ? Center(child: CircularProgressIndicator(color: AppColors.appColor))
            : value.messages.isEmpty
            ? const Expanded(
          child: Text('Say Hello!',
          ),
        )
            : ListView.builder(
              controller: Provider.of<ChatServices>(context, listen: false).scrollController,
              itemCount: value.messages.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                // final isTextMessage = value.messages[index].messageType == MessageType.text;
                final isMe = resiverUserId != value.messages[index].senderId;
                return Column(
                  children: [
                    MessageBubble(
                      isMe: isMe,
                      message: value.messages[index],
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
      );

  // final ScrollController scrollController = ScrollController(initialScrollOffset: 50.0);

  late ScrollController controllerscrollere;

  List chatofdate = [];

  Widget buildMessageiteam(DocumentSnapshot document,context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // scrollDown();
    // });

    var alingmentt = (data["senderid"] == Provider.of<HomeProvider>(context,listen: false).uid) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alingmentt,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
          (data["senderid"] == Provider.of<HomeProvider>(context,listen: false).uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              chatColor: (data["senderid"] == Provider.of<HomeProvider>(context,listen: false).uid)
                  ? AppColors.appColor
                  : Colors.grey.shade100,
              textColor: (data["senderid"] == Provider.of<HomeProvider>(context,listen: false).uid)
                  ? Colors.white
                  : Colors.black,
              message: data["message"],
              alingment: (data["senderid"] == Provider.of<HomeProvider>(context,listen: false).uid)
                  ? false
                  : true,
            ),

            const SizedBox(
              height: 5,
            ),

            Text(DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(data["timestamp"].microsecondsSinceEpoch)).toString(), style: const TextStyle(fontSize: 10,)),


          ],
        ),
      ),
    );
  }

  void sendMessage({required String resiverUserId,required String fmctoken,required context}) async {
    try{
      CollectionReference collectionReference = FirebaseFirestore.instance.collection('datingUser');
      if (controller.text.isNotEmpty) {
        collectionReference.doc(resiverUserId).get().then((value) async {
          try{
            print("try condition");
            var fields;
            fields = value.data();
            if (fields["isOnline"] == false) {
               sendPushMessage(controller.text, Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.name ?? "", fmctoken,context);
            } else {
              print("user online");
            }
            final message = controller.text;
            controller.clear();
            FocusScope.of(context).unfocus();
            await chatservices.sendMessage(receiverId: resiverUserId, messeage: message, context: context);
          }catch(e){
            print("catch condition");
            Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("User could be offline or might have uninstalled the app.") ?? "User could be offline or might have uninstalled the app.");
          }

        });
      }
    } catch(e){
       Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("User could be offline or might have uninstalled the app.") ?? "User could be offline or might have uninstalled the app.");
    }

  }

  void scrollDown() {
    scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  final Api _api = Api();


  void sendPushMessage(String body, String title, String token, BuildContext context) async {
    final dio = Dio();

    print("++++send meshj++++:--  ${Config.firebaseKey}");
    try {
      final response = await dio.post(
        'https://fcm.googleapis.com/v1/projects/${Config.projectID}/messages:send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Config.firebaseKey}',
          },
        ),
        data: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': Provider.of<HomeProvider>(context, listen: false).uid,
              'name': Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name,
              'propic': Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.otherPic.toString().split("\$;").first,
              'status': 'done'
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print('done');
      } else {
        print('Failed to send push notification: ${response.data}');
      }
    } catch (e) {
      print("Error push notificatioDDn: $e");
    }
  }


  Future<void> vcNotificationMessage(String body, String title, String token, BuildContext context, String vcId) async {
    final dio = Dio();
    print("++++send message++++:--  ${Config.firebaseKey}");

    try {
      final response = await dio.post(
        'https://fcm.googleapis.com/v1/projects/${Config.projectID}/messages:send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Config.firebaseKey}',
          },
        ),
        data: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': Provider.of<HomeProvider>(context, listen: false).uid,
              'name': Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name,
              'propic': Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.otherPic.toString().split("\$;").first,
              'vcId': vcId,
              'status': 'done'
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully');
      } else {
        print('Failed to send push notification: ${response.data}');
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio error: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("Unexpected error: $e");
      }
    }
  }

  Future<void> audioNotificationMessage(String body, String title, String token, BuildContext context, String vcId) async {
    final dio = Dio();
    print("++++send message++++:--  ${Config.firebaseKey}");

    try {
      final response = await dio.post(
        'https://fcm.googleapis.com/v1/projects/${Config.projectID}/messages:send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Config.firebaseKey}',
          },
        ),
        data: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': Provider.of<HomeProvider>(context, listen: false).uid,
              'name': Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name,
              'propic': Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.otherPic.toString().split("\$;").first,
              'Audio': vcId,
              'status': 'done'
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully');
      } else {
        print('Failed to send push notification: ${response.data}');
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio error: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("Unexpected error: $e");
      }
    }
  }


  Future<dynamic> isUserOnlie(String uid, bool isonline) async {
    CollectionReference collectionReference =
    FirebaseFirestore.instance.collection('datingUser');
    collectionReference.doc(uid).update({"isOnline": isonline});
  }


late GetblockListApi getblockListApi;

Future getblockklisttApi(context) async {

  Map data = {
    "uid" : Provider.of<HomeProvider>(context,listen: false).uid,
  };

  try{
    var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.getblockapi}",data: data);
    print("+ + + + + +:----- ${response.data}");
    if(response.statusCode == 200){
      getblockListApi = GetblockListApi.fromJson(response.data);
      notifyListeners();
    }else{
      notifyListeners();
    }

  }catch(e){
    Fluttertoast.showToast(msg: e.toString());
  }

}

}