// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/language/localization/app_localization.dart';
import 'package:dating/presentation/firebase/chat_service.dart';
import 'package:dating/presentation/firebase/chatting_provider.dart';
import 'package:dating/presentation/firebase/videocall_screen.dart';
import 'package:dating/presentation/screens/AudioCall/audio_callingscreen.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/screens/other/premium/premium.dart';
import 'package:dating/presentation/widgets/other_widget.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../EMOJICODE.dart';
import '../../Logic/cubits/Home_cubit/home_cubit.dart';
import '../../Logic/cubits/Home_cubit/homestate.dart';
import '../../core/config.dart';
import '../../core/ui.dart';
import '../../data/localdatabase.dart';
import '../../data/models/usermodel.dart';
import '../screens/BottomNavBar/bottombar.dart';
import '../screens/BottomNavBar/home_screen.dart';
import '../screens/other/premium/premium_provider.dart';
import '../screens/other/profileAbout/detailprovider.dart';
import '../screens/other/profileAbout/detailscreen.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../../core/app_download_helper.dart';

import '../widgets/main_button.dart';

class ChattingPage extends StatefulWidget {
  final String resiverUserId;
  final String resiverUseremail;
  final String proPic;
  Map<String, dynamic>? userData;
   ChattingPage({super.key, required this.resiverUserId, required this.resiverUseremail, required this.proPic, this.userData,});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  late ChattingProvider chattingProvider;
  late PremiumProvider premiumProvider;
  late DetailProvider detailProvider;
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    print("+++++++++++++RRRRRRR++++++++++++++++++++++${widget.resiverUserId}");
    print("-------------SSSSSSS-----------------------------${Provider.of<HomeProvider>(context, listen: false).uid}");
    chattingProvider = Provider.of<ChattingProvider>(context, listen: false);
    detailProvider = Provider.of<DetailProvider>(context, listen: false);

    final homeProv = Provider.of<HomeProvider>(context, listen: false);
    String myUid = (homeProv.uid ?? "").toString();
    if (myUid.isEmpty && homeProv.userlocalData.userLogin?.id != null) {
      myUid = homeProv.userlocalData.userLogin!.id.toString();
    }

    if (myUid.isNotEmpty) {
      Provider.of<ChatServices>(context, listen: false).getMessageNew(
        userId: myUid,
        otherUserId: widget.resiverUserId.toString(),
      );
      chattingProvider.updateUid(myUid);
    } else {
      Preferences.fetchUserDetails().then((raw) {
        if (raw.isNotEmpty) {
          try {
            final userModel = userModelFromJson(raw);
            final fetchedId = (userModel.userLogin?.id ?? "").toString();
            if (fetchedId.isNotEmpty) {
              homeProv.uid = fetchedId;
              Provider.of<ChatServices>(context, listen: false).getMessageNew(
                userId: fetchedId,
                otherUserId: widget.resiverUserId.toString(),
              );
              chattingProvider.updateUid(fetchedId);
            }
          } catch (_) {}
        }
      });
    }

    chattingProvider.isMeassageAvalable(widget.resiverUserId.toString());
    Provider.of<PremiumProvider>(context, listen: false).planDataApi(context, widget.resiverUserId.toString());



    _focusNode = FocusNode();
    final fontSize = 24 * (isApple ? 1.2 : 1.0);
    _textStyle = emoji.DefaultEmojiTextStyle.copyWith(
      fontSize: fontSize,
    );

    chattingProvider.controller = emoji.EmojiTextEditingController(emojiTextStyle: _textStyle);
    chattingProvider.controllerscrollere = ScrollController();

  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showDownloadAppDialog(BuildContext context, String callType) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF161224),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFF4458)]),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Icon(callType == "Video" ? Icons.videocam_rounded : Icons.phone_in_talk_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                "$callType Calling",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              "Crystal-clear $callType calls with background notifications are powered by the native LoveCloud mobile app.",
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85), height: 1.4),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFF5252)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  AppDownloadHelper.downloadApk(url: '/app/lovecloud.apk', filename: 'lovecloud.apk');
                  Navigator.pop(dialogCtx);
                  Fluttertoast.showToast(msg: "Downloading LoveCloud Android APK...");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: const Icon(Icons.android_rounded, color: Colors.white, size: 20),
                label: const Text(
                  "Download Android App (APK)",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.apple_rounded, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "iOS / iPhone: Safari > Share > Add to Home Screen (or TestFlight Beta)",
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text("Close", style: TextStyle(color: Colors.white.withOpacity(0.7))),
          ),
        ],
      ),
    );
  }

  var selectedRadioTile;
  String rejectmsg = "";

  List cancelList = [
    {"id": 1, "title": "Harassment"},
    {"id": 2, "title": "Inappropriate Content"},
    {"id": 3, "title": "Violation of Terms"},
    {"id": 4, "title": "Offensive Language"},
    {"id": 5, "title": "Disrespectful Behavior"},
    {"id": 6, "title": "Threats"},
    {"id": 7, "title": "Catfishing"},
    {"id": 7, "title": "Unwanted Advances"},
    {"id": 7, "title": "Unsolicited Explicit Content"},
    {"id": 7, "title": "Privacy Concerns"},
    {"id": 7, "title": "Scam or Spam"},
    {"id": 7, "title": "Something else"},
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  final _utils = emoji.EmojiPickerUtils();
  late final emoji.EmojiTextEditingController _controller;
  late final FocusNode _focusNode;
  late final TextStyle _textStyle;
  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS].contains(foundation.defaultTargetPlatform);
  bool _emojiShowing = false;

 int sum1 = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    chattingProvider = Provider.of<ChattingProvider>(context);
    premiumProvider = Provider.of<PremiumProvider>(context);
    detailProvider = Provider.of<DetailProvider>(context);
   homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appbar(
          proPic: widget.proPic,
          resiverUseremail: widget.resiverUseremail,
          resiverUserId: widget.resiverUserId,
          context: context
      ),
      body: BlocBuilder<HomePageCubit, HomePageStates>(
          builder: (context, state){
            if(state is HomeCompleteState){
              return Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: chattingProvider.buildMessageList(context: context, resiverUserId: Provider.of<HomeProvider>(context, listen: false).uid),
                      ),
                      chattingProvider.buildMessageInpurt(
                        resiverUserId: widget.resiverUserId,
                        context: context,
                        ontap: () {
                        setState(() {
                          _emojiShowing = !_emojiShowing;
                          if (!_emojiShowing) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _focusNode.requestFocus();
                            });
                          } else {
                            _focusNode.unfocus();
                          }
                        });

                      },
                        focusnodee: _focusNode,
                        icon: Icon(
                        _emojiShowing
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: secondaryColor,
                        size: 30,
                      ),
                        images: "assets/icons/gifticon.svg",
                        ontap1: () {


                          selectedItems.clear();
                          coinlist.clear();
                          imagelist.clear();
                          sum1 = 0;

                          showModalBottomSheet(
                            context: context,
                            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 350),
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(builder: (context, setState) {
                                return ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                  child: Scaffold(
                                    floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
                                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                                    floatingActionButton: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(child:
                                          MainButton(
                                            bgColor: AppColors.appColor,
                                            title: AppLocalizations.of(context)
                                                ?.translate("Send") ??
                                                "Send", onTap: () {
                                            print("hello");

                                            if(selectedItems.isEmpty){
                                              Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Please select gift") ?? "Please select gift");
                                            }else{

                                              homeProvider.giftbuyApi(context: context,coin: sum1.toString(), receiver_id: "${widget.resiverUserId}", gift_img: imagelist.join(",")).then((value) {
                                                Navigator.pop(context);
                                                if (value != null && value['Result'] == 'true') {
                                                  sum1 == 0 ?
                                                  state.homeData.coin = state.homeData.coin
                                                      : state.homeData.coin = value['coin'];

                                                  // Send gift message to chat room
                                                  try {
                                                    Provider.of<ChatServices>(context, listen: false).sendMessage(
                                                      receiverId: widget.resiverUserId.toString(),
                                                      messeage: "🎁 Sent a gift",
                                                      context: context,
                                                    );
                                                  } catch (_) {}

                                                  selectedItems.clear();
                                                  imagelist.clear();
                                                  coinlist.clear();
                                                  sum1 = 0;

                                                  showModalBottomSheet(
                                                    context: context,
                                                    constraints: const BoxConstraints(maxHeight: 280),
                                                    isScrollControlled: true,
                                                    builder: (bottomSheetContext) {
                                                      Timer(const Duration(milliseconds: 2200), () {
                                                        if (bottomSheetContext.mounted) {
                                                          Navigator.pop(bottomSheetContext);
                                                        }
                                                      });

                                                      return ClipRRect(
                                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                                        child: Scaffold(
                                                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                                          body: Padding(
                                                            padding: const EdgeInsets.all(15),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Spacer(),
                                                                    Container(
                                                                      height: 3,
                                                                      width: 60,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.grey,
                                                                          borderRadius: BorderRadius.circular(10)
                                                                      ),
                                                                    ),
                                                                    const Spacer(),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: 25,),
                                                                Row(
                                                                  children: [
                                                                    const Spacer(),
                                                                    Lottie.asset("assets/lottie/giftsend.json",height: 90, repeat: false),
                                                                    const Spacer(),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: 15,),
                                                                Text("You've sent a gift to ${widget.resiverUseremail}",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),),
                                                                const SizedBox(height: 15,),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.pop(bottomSheetContext);
                                                                  },
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                                                                    decoration: BoxDecoration(
                                                                      color: AppColors.appColor,
                                                                      borderRadius: BorderRadius.circular(20),
                                                                    ),
                                                                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              });
                                            }

                                          },
                                          )),
                                        ],
                                      ),
                                    ),
                                    body: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(AppLocalizations.of(context)?.translate("Send Gifts") ?? "Send Gifts",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18,fontWeight: FontWeight.bold),),
                                              const Spacer(),
                                              SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 25,),
                                              const SizedBox(width: 5,),
                                              Text("${state.homeData.coin}",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16),),
                                            ],
                                          ),
                                          const SizedBox(height: 10,),
                                          Expanded(
                                            child: GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4,mainAxisSpacing: 10,mainAxisExtent: 100,crossAxisSpacing: 10),
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              itemCount: homeProvider.giftListApiModel.giftlist.length,
                                              itemBuilder: (context, a) {
                                                return InkWell(
                                                  onTap: () {
                                                    setState((){


                                                      if(state.homeData.coin == "0"){

                                                        if(homeProvider.giftListApiModel.giftlist[a].price == "0"){

                                                          if (selectedItems.contains(a)){
                                                            coinlist.remove(homeProvider.giftListApiModel.giftlist[a].price);
                                                            imagelist.remove(homeProvider.giftListApiModel.giftlist[a].img);
                                                            sum1 -= int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                            selectedItems.remove(a);
                                                          } else {
                                                            coinlist.add(homeProvider.giftListApiModel.giftlist[a].price);
                                                            imagelist.add(homeProvider.giftListApiModel.giftlist[a].img);
                                                            sum1 += int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                            selectedItems.add(a);
                                                          }

                                                        }else{
                                                          Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Insufficient coins in wallet") ?? "Insufficient coins in wallet");
                                                        }

                                                      }
                                                      else{
                                                        if (selectedItems.contains(a)){
                                                          coinlist.remove(homeProvider.giftListApiModel.giftlist[a].price);
                                                          imagelist.remove(homeProvider.giftListApiModel.giftlist[a].img);
                                                          sum1 -= int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                          selectedItems.remove(a);
                                                          print("+++++:-- ${sum1}");
                                                        } else {
                                                          coinlist.add(homeProvider.giftListApiModel.giftlist[a].price);
                                                          imagelist.add(homeProvider.giftListApiModel.giftlist[a].img);
                                                          int temp = 0;
                                                          temp= sum1 + int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                          if(temp > int.parse(state.homeData.coin.toString())){
                                                            // Fluttertoast.showToast(msg: "Insufficient coins in wallet");
                                                            Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Insufficient coins in wallet") ?? "Insufficient coins in wallet");
                                                          }else{
                                                            sum1 += int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                            selectedItems.add(a);
                                                            print("+++++:-- ${sum1}");
                                                          }
                                                        }
                                                      }


                                                    });

                                                  },
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Container(
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            border: Border.all(color: selectedItems.contains(a) ?  AppColors.appColor : Colors.grey.withOpacity(0.4))),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Image(image: NetworkImage("${Config.baseUrl}${homeProvider.giftListApiModel.giftlist[a].img}"),height: 40),
                                                            const SizedBox(height: 10,),
                                                            homeProvider.giftListApiModel.giftlist[a].price == "0" ?
                                                            Text(AppLocalizations.of(context)?.translate("Free") ?? "Free",style: Theme.of(context).textTheme.bodySmall!.copyWith())
                                                                :  Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 12,),
                                                                SizedBox(width: 2,),
                                                                Text(homeProvider.giftListApiModel.giftlist[a].price,style: Theme.of(context).textTheme.bodySmall!.copyWith()),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      selectedItems.contains(a) ? Positioned(
                                                        top: -5,
                                                        right: -5,
                                                        child: Container(
                                                          height: 20,
                                                          width: 20,
                                                          decoration: BoxDecoration(
                                                              color: AppColors.appColor,
                                                              shape: BoxShape.circle
                                                          ),
                                                          child: const Icon(Icons.check,color: Colors.white,size: 13,),
                                                        ),
                                                      ):const SizedBox()
                                                    ],
                                                  ),
                                                );
                                              },),
                                          ),
                                          SizedBox(height: 50,),

                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },);
                            },
                          );


                        },
                      ),
                      emjiui(),
                    ],
                  ),
                  chattingProvider.isLoading
                      ? CircularProgressIndicator(color: AppColors.appColor)
                      : const SizedBox(),
                ],
              );
            }else{
              return const SizedBox();
            }
          }
      ),
    );
  }

  PreferredSizeWidget appbar({required String resiverUserId,required String resiverUseremail,required String proPic,required context}) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: const BackButtons(),
      title: BlocBuilder<HomePageCubit, HomePageStates>(
          builder: (context1, state) {
            if (state is HomeCompleteState) {
              return Row(
                children: [
                  proPic == "null"
                      ? const CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 20,
                      backgroundImage: AssetImage(
                        "assets/Image/05.png",
                      ))
                      : CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      backgroundImage: NetworkImage("${Config.baseUrl}$proPic")
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          resiverUseremail,
                          style: Theme.of(context).textTheme.bodyLarge!,
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        // data["isOnline"] == true
                        //     ? Text(
                        //   "Online",
                        //   style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.green),
                        // )
                        //     :  const SizedBox()

                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  InkWell(
                      onTap: () {
                        if (state.homeData.audioVideo == "0") {
                          Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute);
                        }
                        else {
                          chattingProvider.updateIsLoading(true);
                          List<String> ids = [
                            Provider.of<HomeProvider>(context, listen: false).uid,
                            resiverUserId
                          ];
                          ids.sort();
                          String vcRoomId = ids.join("_");

                          isAudio(vcRoomId, null).then((value) {
                            _firebaseStorage.collection("chat_rooms").doc(vcRoomId).collection("isVcAvailable").doc(vcRoomId).get().then((value) {

                              chattingProvider.audioNotificationMessage(
                                  "In Coming Audio Call From ${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin?.name ?? 'User'}",
                                  Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin?.name?.toString() ?? "User",
                                  chattingProvider.fmctoken, context, vcRoomId)
                                  .then((value) {
                                chattingProvider.updateIsLoading(false);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AudioCallingScreen(userData: widget.userData ?? {}, channel: vcRoomId),
                                    ));
                              });

                              // }
                            });
                          });
                        }


                      },
                      child: SvgPicture.asset(
                        "assets/icons/Call.svg",
                        height: 25,
                        width: 25,
                        colorFilter: ColorFilter.mode(state.homeData.audioVideo == "0" ? Theme.of(context).indicatorColor.withOpacity(0.2)  : Theme.of(context).indicatorColor, BlendMode.srcIn),
                      )),
                  const Spacer(),
                  InkWell(
                      onTap: () {
                        if (state.homeData.audioVideo == "0") {
                          Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute);
                        }
                        else {
                          chattingProvider.updateIsLoading(true);
                          List<String> ids = [
                            Provider.of<HomeProvider>(context, listen: false).uid,
                            resiverUserId
                          ];
                          ids.sort();
                          String vcRoomId = ids.join("_");
                          isvc(vcRoomId, true).then((value) {
                            _firebaseStorage.collection("chat_rooms").doc(vcRoomId).collection("isVcAvailable").doc(vcRoomId).get().then((value) {
                              if (value.data()!["isVc"] == true) {
                                chattingProvider.vcNotificationMessage(
                                    "In Coming Video Call From ${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin?.name ?? 'User'}",
                                    Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin?.name?.toString() ?? "User",
                                    chattingProvider.fmctoken,
                                    context,
                                    vcRoomId)
                                    .then((value) {
                                  chattingProvider.updateIsLoading(false);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCall(channel: vcRoomId),));
                                });
                              }
                            });
                          });
                        }
                      },
                      child: SvgPicture.asset(
                        "assets/icons/Video.svg",
                        height: 25,
                        width: 25,
                        colorFilter: ColorFilter.mode(state.homeData.audioVideo == "0" ? Theme.of(context).indicatorColor.withOpacity(0.2) : Theme.of(context).indicatorColor, BlendMode.srcIn),
                      )),
                  const Spacer(),
                  PopupMenuButton(
                    tooltip: '',
                    padding: const EdgeInsets.all(0),
                    offset: const Offset(110, 30),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    constraints: const BoxConstraints(
                      maxWidth: 310,
                      maxHeight: 540,
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: SvgPicture.asset(
                      "assets/icons/More Circle.svg",
                      height: 25,
                      width: 25,
                      colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),
                    ),
                    itemBuilder: (context) =>
                    <PopupMenuEntry<SampleItem2>>[
                      PopupMenuItem(
                          enabled: true,
                          onTap: () {},
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Column(children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog<String>(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) => AlertDialog(
                                        elevation: 0,
                                        insetPadding: const EdgeInsets.only(left: 10,right: 10),
                                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Column(
                                          children: [
                                            SizedBox(
                                              height: 200,
                                              width: 200,
                                              child: Lottie.asset('assets/lottie/block.json',fit: BoxFit.cover),
                                            ),
                                            Row(
                                              children: [
                                                Text(AppLocalizations.of(context)?.translate("Blocking") ?? "Blocking",style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 22),),
                                                Text(' ${widget.resiverUseremail}',style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 22),),
                                              ],
                                            ),
                                            const SizedBox(height: 12,),
                                            Text('Please tell us why you are blocking ${widget.resiverUseremail}. Don`t worry we won`t tell them.',style: Theme.of(context).textTheme.bodySmall!,textAlign: TextAlign.center,),
                                            const SizedBox(height: 10,),
                                            Divider(color: Colors.grey.withOpacity(0.2)),
                                            const SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.add_box_sharp,color: AppColors.appColor),
                                                const SizedBox(width: 10,),
                                                Flexible(child: Text(AppLocalizations.of(context)?.translate("They will not be able to find your profile and send you messages.") ?? "They will not be able to find your profile and send you messages.",style: Theme.of(context).textTheme.bodySmall!,)),
                                              ],
                                            ),
                                            const SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.notifications_off_outlined,color: AppColors.appColor),
                                                const SizedBox(width: 10,),
                                                Flexible(child: Text(AppLocalizations.of(context)?.translate("They will not be notified if you block them.") ?? "They will not be notified if you block them.",style: Theme.of(context).textTheme.bodySmall!,)),
                                              ],
                                            ),
                                            const SizedBox(height: 10,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.settings,color: AppColors.appColor),
                                                const SizedBox(width: 10,),
                                                Flexible(child: Text(AppLocalizations.of(context)?.translate("You can unblock them anytime in Settings.") ?? "You can unblock them anytime in Settings.",style: Theme.of(context).textTheme.bodySmall!,)),
                                              ],
                                            ),
                                            const SizedBox(height: 30,),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    style: ButtonStyle(side: MaterialStatePropertyAll(BorderSide(color: AppColors.appColor)),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),backgroundColor: const MaterialStatePropertyAll(Colors.white)),
                                                    child:  Text(AppLocalizations.of(context)?.translate("Cancel") ?? "Cancel",style: TextStyle(color: AppColors.appColor)),
                                                  ),
                                                ),
                                                const SizedBox(width: 5,),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      // Navigator.pop(context);
                                                      detailProvider.profileblockApi(context: context, profileblock: widget.resiverUserId).then((value) {
                                                        print("donedonedonedonedone");
                                                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const BottomBar()), (route) => false);
                                                      },);
                                                    },
                                                    style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),backgroundColor: MaterialStatePropertyAll(AppColors.appColor)),
                                                    child:  Text(AppLocalizations.of(context)?.translate("Yes, Block") ?? "Yes, Block",style: TextStyle(color: Colors.white)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Image(image: AssetImage("assets/icons/block.png"),height: 20,width: 20),
                                      const SizedBox(width: 10,),
                                      Flexible(
                                        child: Column(
                                          children: [
                                            Text(AppLocalizations.of(context)?.translate("Block") ?? "Block", style: Theme.of(context).textTheme.bodySmall!, maxLines: 2, softWrap: true),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 50,)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                    color: Colors.grey.withOpacity(0.2)),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    showDialog<String>(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) => StatefulBuilder(builder: (context, setState) {
                                        return SingleChildScrollView(
                                          child: AlertDialog(
                                            elevation: 0,
                                            insetPadding: const EdgeInsets.only(left: 10,right: 10),
                                            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            title: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Center(child: Text(AppLocalizations.of(context)?.translate("Reporting") ?? "Reporting",style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 22))),
                                                    Center(child: Text(' ${widget.resiverUseremail}',style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 22))),
                                                  ],
                                                ),
                                                const SizedBox(height: 12,),
                                                Text('Please tell us why you are reporting ${widget.resiverUseremail}. Don`t worry we won`t tell them.',style: Theme.of(context).textTheme.bodySmall!,textAlign: TextAlign.center,),
                                                const SizedBox(height: 10,),
                                                Text(AppLocalizations.of(context)?.translate("Why did you report this user?") ?? "Why did you report this user?",style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18)),
                                                const SizedBox(height: 10,),
                                                SizedBox(
                                                  height: 570,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: ListView.builder(
                                                    itemCount: cancelList.length,
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemBuilder: (ctx, i) {
                                                      return Transform.translate(
                                                        offset: const Offset(-10, 0),
                                                        child: RadioListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          dense: true,
                                                          value: i,
                                                          fillColor:  MaterialStatePropertyAll(AppColors.appColor),
                                                          activeColor: AppColors.appColor,
                                                          tileColor: AppColors.appColor,
                                                          selected: true,
                                                          groupValue: selectedRadioTile,
                                                          title: Text(AppLocalizations.of(context)?.translate("${cancelList[i]["title"]}") ?? "${cancelList[i]["title"]}", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),),
                                                          onChanged: (val) {
                                                            setState(() {});
                                                            selectedRadioTile = val;
                                                            rejectmsg = cancelList[i]["title"];
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(height: 30,),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          detailProvider.profilereportApi(context: context, reportid: widget.resiverUserId, comment: rejectmsg);
                                                          print(" + + + + + + + + + :----  $rejectmsg");
                                                        },
                                                        style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),backgroundColor: MaterialStatePropertyAll(AppColors.appColor)),
                                                        child: Text(AppLocalizations.of(context)?.translate("Continue") ?? "Continue",style: TextStyle(color: Colors.white)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Image(image: AssetImage("assets/icons/report.png"),height: 20,width: 20),
                                      const SizedBox(width: 10,),
                                      Flexible(
                                        child: Column(
                                          children: [

                                            Text(
                                                AppLocalizations.of(context)?.translate("Report") ?? "Report",
                                                style: Theme.of(context).textTheme.bodySmall!,
                                                maxLines: 2,
                                                softWrap: true
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ]),
                            ],
                          ))
                    ],
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          }),
    );
  }

  Widget emjiui(){
    return Offstage(
      offstage: !_emojiShowing,
      child: emoji.EmojiPicker(
        textEditingController: chattingProvider.controller,
        scrollController: chattingProvider.scrollController,
        config: emoji.Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiTextStyle: _textStyle,
          emojiViewConfig: const emoji.EmojiViewConfig(
            backgroundColor: Colors.white,
          ),
          swapCategoryAndBottomBar: true,
          skinToneConfig: const emoji.SkinToneConfig(),
          categoryViewConfig: emoji.CategoryViewConfig(
            backgroundColor: Colors.white,
            dividerColor: Colors.white,
            indicatorColor: Colors.red,
            iconColorSelected: Colors.black,
            iconColor: Colors.black,
            customCategoryView: (
                config,
                state,
                tabController,
                pageController,
                ) {
              return WhatsAppCategoryView(
                config,
                state,
                tabController,
                pageController,
              );
            },
            categoryIcons: const emoji.CategoryIcons(
              recentIcon: Icons.access_time_outlined,
              smileyIcon: Icons.emoji_emotions_outlined,
              animalIcon: Icons.cruelty_free_outlined,
              foodIcon: Icons.coffee_outlined,
              activityIcon: Icons.sports_soccer_outlined,
              travelIcon: Icons.directions_car_filled_outlined,
              objectIcon: Icons.lightbulb_outline,
              symbolIcon: Icons.emoji_symbols_outlined,
              flagIcon: Icons.flag_outlined,
            ),
          ),
          bottomActionBarConfig: const emoji.BottomActionBarConfig(
            backgroundColor: Colors.white,
            buttonColor: Colors.white,
            buttonIconColor: secondaryColor,
          ),
          searchViewConfig: emoji.SearchViewConfig(
            backgroundColor: Colors.white,
            customSearchView: (
                config,
                state,
                showEmojiView,
                ) {
              return WhatsAppSearchView(
                config,
                state,
                showEmojiView,
              );
            },
          ),
        ),
      ),
    );
  }


}

final FirebaseFirestore _firebaseStorage = FirebaseFirestore.instance;

Future isvc(channel, bool isvc) async {
  await _firebaseStorage.collection("chat_rooms").doc(channel).collection("isVcAvailable").doc(channel).set({"isVc": isvc});
}

Future isAudio(channel, isvc) async {
  await _firebaseStorage.collection("chat_rooms").doc(channel).collection("isVcAvailable").doc(channel).set({"Audio": isvc});
}

Future<dynamic> isUserLogOut(String uid) async {
  CollectionReference collectionReference =
  FirebaseFirestore.instance.collection('datingUser');
  collectionReference.doc(uid).update({"token": ""});
}
