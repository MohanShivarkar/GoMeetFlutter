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
  bool _isIncomingCallActive = false;

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
    _callSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        _listenForCalls(uid);
      } else {
        Preferences.fetchUserDetails().then((raw) {
          if (raw.isNotEmpty) {
            try {
              final userModel = userModelFromJson(raw);
              final fetchedId = (userModel.userLogin?.id ?? "").toString();
              if (fetchedId.isNotEmpty) {
                _listenForCalls(fetchedId);
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
