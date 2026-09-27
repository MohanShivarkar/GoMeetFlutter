// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:dating/core/api.dart';
import 'package:dating/core/config.dart';
import 'package:dating/core/ui.dart';
import 'package:dating/data/localdatabase.dart';
import 'package:dating/data/models/mapmodel.dart';
import 'package:dating/data/models/usermodel.dart';
import 'package:dating/presentation/screens/other/editProfile/editprofile_provider.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart'
    if (dart.library.html) 'package:dating/stubs/geocoding_stub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Logic/cubits/Home_cubit/home_cubit.dart';
import '../../../../data/models/getinterest_model.dart';
import '../../../../data/models/languagemodel.dart';
import '../../../../data/models/notificationmodel.dart';
import '../../../../data/models/relationgoalmodel.dart';
import '../../../../data/models/religionmodel.dart';
import '../../../../language/localization/app_localization.dart';
import '../../../../wallete_code/gift_list_api_model.dart';
import '../../../firebase/chatting_provider.dart';
import '../../../widgets/main_button.dart';
import '../../../widgets/sizeboxx.dart';

class HomeProvider extends ChangeNotifier {

  late GiftListApiModel giftListApiModel;
  Future giftlistApi(context) async{
    try{
      var response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.giftlistapi}",);
      print("+++++:-- ${response.data}");
      if(response.statusCode == 200){
        giftListApiModel = GiftListApiModel.fromJson(response.data);
        isLoading = true;
        notifyListeners();
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  bool isLoad = false;

  Future giftbuyApi({context,required String coin,required String receiver_id,required String gift_img}) async{
    if(isLoad){
      return;
    }else{
      isLoad = true;
    }

    final currentUid = (Provider.of<HomeProvider>(context,listen: false).uid ?? "").toString();
    Map data = {
      "sender_id" : currentUid,
      "coin" : coin,
      "receiver_id" : receiver_id,
      "gift_img"  : gift_img
    };

    try{
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.giftbuyapi}",data: data);
      if(response.statusCode == 200){
        if(response.data["Result"] == "true"){
          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
          return response.data;
        }else{
          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
        }
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoad = false;
      notifyListeners();
    }
  }





  List flotingIcons = [
    "assets/icons/times.svg",
    "assets/icons/Heart-fill1.svg",
    "assets/icons/star.svg",
    "assets/icons/gifticon.svg",
  ];

  List flotingIconscondition = [
    "assets/icons/times.svg",
    "assets/icons/Heart-fill1.svg",
    "assets/icons/star.svg",
  ];


  var lat;
  var long;
  var uid;
  var currency;

  int selectPageIndex = 0;

  setSelectPage(int value) {
    selectPageIndex = value;
    notifyListeners();
  }

  bool isShowDialog = false;
  late UserModel userlocalData;
  late AnimationController controller;
  late Animation<Offset> animation;

  updateIsShow(bool value) {
    isShowDialog = value;
    notifyListeners();
  }

  updateMapController(value) {
    mapController = value;
    notifyListeners();
  }

  localData(context) {
    Preferences.fetchUserDetails().then((value) {
      userlocalData = userModelFromJson(value);
      lat = Provider
          .of<OnBordingProvider>(context, listen: false)
          .lat;
      long = Provider
          .of<OnBordingProvider>(context, listen: false)
          .long;
      uid = userlocalData.userLogin!.id;
      notifyListeners();
    });
  }

  final Api _api = Api();
  late MapModel mapModel;

  bool isedit = true;

  updateisEdit() {
    isedit = !isedit;
    notifyListeners();
  }

  double radius = 0;

  updateRadius(double value) {
    radius = value;

    notifyListeners();
  }

  double? reduise;

  bool fire = false;

  mapData({required String uid, required String lat, required String long, required String radius}) async {

    try {
      Map data = {
        "uid": uid,
        "lats": lat,
        "longs": long,
        "radius_search": radius
      };

      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.mapInfo}", data: data);

      if (response.statusCode == 200) {
        if (response.data["Result"] == "true") {
          mapModel = MapModel.fromJson(response.data);

          fire = true;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setDouble("rediuse", double.parse(radius));

          reduise = prefs.getDouble("rediuse");


          isLoading = false;
          notifyListeners();
          Future.delayed(const Duration(seconds: 1), () {
            mapMarkers();
            notifyListeners();
          });
        }
        else {
          mapModel = MapModel.fromJson(response.data);
          notifyListeners();
          Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
        }
      } else {
        Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  late NotificationModel notificationModel;

  bool isNotification = true;

  updateNotification(bool value) {
    isNotification = value;
    notifyListeners();
  }

  notificationApi() async {
    Map data = {
      "uid": "$uid"
    };
    try {
      var response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.notificationList}", data: data);

      if (response.statusCode == 200) {
        notificationModel = NotificationModel.fromJson(response.data);
        isNotification = false;
        notifyListeners();
      } else {
        Fluttertoast.showToast(msg: "${response.data["ResponseMsg"]}");
      }
    } catch (e) {
      print(e);
    }
  }

  bool isLoading = true;
  String location = "";

  late CameraPosition kGooglePlex;
  late GoogleMapController mapController;

  updatePosition(String eventLatitude, String eventLongtitude) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            double.parse(eventLatitude),
            double.parse(eventLongtitude),
          ),
          zoom: 12,
        ),
      ),
    );
  }


  Future loadDataFrorMap(context) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat!, long!);
    location = "${placemarks[0].name!},${placemarks[0].locality}";

    kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 14.4746,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();

    double? redises = prefs.getDouble("rediuse");
    print("******${redises}");
    if (redises==0) {

      radius = double.parse(userlocalData.userLogin!.radiusSearch.toString());

    }else{
      radius =redises!;
    }
    print("++++++${radius}");


    mapDataList.clear();
    markers.clear();
    mapMarkers();
    notifyListeners();

    mapData(
        uid: userlocalData.userLogin!.id.toString(),
        lat: lat.toString(),
        long: long.toString(),
        radius: radius.toString()
    );

    notifyListeners();
  }

  List<Map> mapDataList = [];
  List<Marker> markers = [];

  mapMarkers() async {
    await Future.wait(mapDataList.mapIndexed((e, i) async {
      await getmarkers(e, i).then((value) {
        markers.add(value);
        notifyListeners();
      });

    }));
  }

  PageController pageController = PageController();

  Future getmarkers(Map data, index) async {
    RenderRepaintBoundary boundary = data["gkey"].currentContext
        .findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    return Marker(
        onTap: () {
          pageController.jumpToPage(index - 1);
          notifyListeners();
        },
        markerId: MarkerId(data["id"]),
        position: data["position"],
        icon: BitmapDescriptor.fromBytes(pngBytes.buffer.asUint8List())
    );
  }


  // CarouselController carouselController = CarouselController();
  final CarouselSliderController carouselController = CarouselSliderController();

  upDateCurrentindex(int value) {
    currentIndex = value;
    notifyListeners();
  }

  upDateinnerindex(int value) {
    interIndex = value;
    notifyListeners();
  }

  upDateinnerindex1(int value) {
    interIndex1 = value;
    notifyListeners();
  }

  Color slidecolor = AppColors.appColor;

  Future cancleButton(state, context) async {
    // carouselController.jumpToPage(0);
    carouselController.jumpToPage(0);
    interIndex = 0;
    slidecolor = const Color(0xffFACC15);
    animation = Tween<Offset>(begin: Offset.zero, end: const Offset(-0.80, 0.1)).animate(controller);
    notifyListeners();
    swipe(state.homeData.profilelist, context);
  }

  Future likeButton(state, context) async {
    // carouselController.jumpToPage(0);
    carouselController.jumpToPage(0);
    interIndex = 0;
    slidecolor = const Color(0xffFF4D67);
    notifyListeners();
    animation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.80, 0.1)).animate(
            controller);
    notifyListeners();
    swipe(state.homeData.profilelist, context);
  }

  int currentIndex = 0;
  int interIndex = 0;
  int interIndex1 = 0;

  Future alertMessage(context) {
    return showDialog(
      barrierDismissible: false,
      context: context, builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: Theme
            .of(context)
            .cardColor,
        child: Container(
          decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .cardColor,
              borderRadius: BorderRadius.circular(15)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                SvgPicture.asset("assets/Image/seemore.svg"),

                Text(AppLocalizations.of(context)?.translate(
                    "You’ve seen everyone in your filters") ??
                    "You’ve seen everyone in your filters", style: Theme
                    .of(context)
                    .textTheme
                    .headlineMedium, textAlign: TextAlign.center),
                const SizedBox(height: 10,),
                Text(AppLocalizations.of(context)?.translate(
                    "To give you another chance, we’re showing you everyone again.") ??
                    "To give you another chance, we’re showing you everyone again.",
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(height: 1.2), textAlign: TextAlign.center),
                const SizedBox(height: 10,),
                Text(AppLocalizations.of(context)?.translate(
                    "We’ll always show you new and unseen profiles first.") ??
                    "We’ll always show you new and unseen profiles first.",
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.appColor,
                        height: 1.2,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                const SizedBox(height: 15,),

                MainButton(
                  bgColor: AppColors.appColor,
                  title: AppLocalizations.of(context)?.translate("Continue") ??
                      "Continue", onTap: () {
                  BlocProvider.of<HomePageCubit>(context, listen: false).delUnlikeApi(context);
                },
                ),

              ],
            ),
          ),
        ),
      );
    },
    );
  }

  void swipe(List state, context) {
    controller.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (currentIndex == state.length - 1) {
        alertMessage(context);
      }
      currentIndex = (currentIndex + 1) % state.length;
      print("******:---  ${state.length}");
      slidecolor = AppColors.appColor;
      controller.reset();
      notifyListeners();
    }).then((value) {
      // BlocProvider.of<HomePageCubit>(context).getHomeData(uid: uid,
      //     lat: lat.toString(),
      //     long: long.toString(),
      //     context: context).then((value) {
      //   currentIndex = 0;
      //   notifyListeners();
      // });
    });
  }


  commonDivider(context) {
    return Divider(color: Theme
        .of(context)
        .dividerTheme
        .color!, height: 25);
  }

  double filterRadius = 0;
  RangeValues ageRangeValues = const RangeValues(16, 40);
  int searchPreference = -1;
  int selectRelationShip = -1;
  int selectReligion = -1;
  List interestList = [];
  List languageList = [];

  List verifylist = [
    "Unverify",
    "Verify",
  ];

  int selectverfy = -1;

  filterBottomSheet(context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 100),
      context: context, builder: (context) {
      return Consumer<HomeProvider>(
        builder: (context, value, child) {
          return Consumer<EditProfileProvider>(
              builder: (context, editPro, child) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Scaffold(
                    bottomNavigationBar: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: MainButton(
                            title: AppLocalizations.of(context)?.translate(
                                "Reset") ?? "Reset",
                            bgColor: const Color(0xffF7ECFF),
                            titleColor: AppColors.appColor,
                            onTap: () {
                              BlocProvider.of<HomePageCubit>(context).getHomeData(uid: uid, lat: lat.toString(), long: long.toString(), context: context).then((value) {
                                Navigator.pop(context);
                                filterRadius = 0;
                                ageRangeValues = const RangeValues(16, 40);
                                searchPreference = -1;
                                selectRelationShip = -1;
                                selectReligion = -1;
                                interestList = [];
                                languageList = [];
                                notifyListeners();
                              });
                            },)),
                          const SizedBox(width: 10,),
                          Expanded(child: MainButton(
                            bgColor: AppColors.appColor,
                            title: AppLocalizations.of(context)?.translate(
                                "Apply") ?? "Apply", onTap: () {
                            BlocProvider.of<HomePageCubit>(
                                context, listen: false).filterHome(
                                relationGoal: selectRelationShip.toString(),
                                religion: selectReligion.toString(),
                                interest: interestList.join(","),
                                language: languageList.join(","),
                                lat: lat.toString(),
                                long: long.toString(),
                                maxage: ageRangeValues.end.round().toString(),
                                minage: ageRangeValues.start.round().toString(),
                                radiusSearch: filterRadius.toString(),
                                searchPreference: editPro.maleFemaleBoth(
                                    searchPreference),
                                uid: uid,
                                isverify: selectverfy.toString()).then((value) {
                              Navigator.pop(context);
                            });
                          },),)
                        ],
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: SvgPicture.asset(
                                  "assets/icons/times.svg",
                                  colorFilter: ColorFilter.mode(
                                      AppColors.black, BlendMode.srcIn),)),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Text(
                                  AppLocalizations.of(context)?.translate(
                                      "Filter & Show") ?? "Filter & Show",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .headlineSmall!
                                  ,
                                ),
                              ],
                            ),
                            commonDivider(context),
                            Row(
                              children: [

                                Text(
                                  AppLocalizations.of(context)?.translate(
                                      "Distance Range") ?? "Distance Range",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyLarge!
                                  ,
                                ),

                                const Spacer(),

                                RichText(text: TextSpan(children: [
                                  TextSpan(
                                    text: filterRadius.toStringAsFixed(2),
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodySmall,),
                                  TextSpan(text: AppLocalizations.of(context)
                                      ?.translate(" KM") ?? " KM",
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .bodySmall,),
                                ])),

                              ],
                            ),
                            const SizBoxH(size: 0.008),
                            SliderTheme(
                              data: SliderThemeData(
                                  overlayShape: SliderComponentShape.noOverlay),
                              child: Slider(
                                value: filterRadius,
                                max: 500,
                                min: 0,
                                activeColor: AppColors.appColor,
                                inactiveColor: Theme
                                    .of(context)
                                    .dividerTheme
                                    .color!,
                                label: filterRadius.abs().toString(),
                                onChanged: (double value) {
                                  filterRadius = value;
                                  notifyListeners();
                                },
                              ),
                            ),
                            commonDivider(context),
                            Row(
                              children: [

                                Text(
                                  AppLocalizations.of(context)?.translate(
                                      "Age Range") ?? "Age Range",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyLarge!
                                  ,
                                ),

                                const Spacer(),

                                Text("${ageRangeValues.start.round()} - ${ageRangeValues.end.round()}",
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodySmall,),

                              ],
                            ),
                            const SizBoxH(size: 0.008),
                            SliderTheme(
                              data: SliderThemeData(
                                  overlayShape: SliderComponentShape.noOverlay),
                              child: RangeSlider(
                                values: ageRangeValues,
                                max: 100,
                                activeColor: AppColors.appColor,
                                inactiveColor: Theme
                                    .of(context)
                                    .dividerTheme
                                    .color!,

                                onChanged: (RangeValues values) {
                                  ageRangeValues = values;
                                  notifyListeners();
                                },
                              ),
                            ),

                            commonDivider(context),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // "Search Preference".tr,
                                      AppLocalizations.of(context)?.translate(
                                          "Search Preference") ??
                                          "Search Preference",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyLarge!
                                      ,
                                    ),

                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(
                                  runSpacing: 13,
                                  children: [
                                    for (int a = 0; a <
                                        editPro.searchPref.length; a++)
                                      Builder(builder: (context) {
                                        return InkWell(
                                          onTap: () {
                                            searchPreference = a;
                                            notifyListeners();
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                                color: searchPreference == a
                                                    ? AppColors.appColor
                                                    : Theme
                                                    .of(context)
                                                    .cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color:
                                                    Theme
                                                        .of(context)
                                                        .dividerTheme
                                                        .color!)),
                                            child: Text(editPro.searchPref[a]
                                                .toString(),
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                    color:
                                                    searchPreference == a
                                                        ? AppColors.white
                                                        : null)),
                                          ),
                                        );
                                      })
                                  ],
                                ),
                              ],
                            ),


                            commonDivider(context),

                            InkWell(
                              onTap: () {},
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Interests",
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .bodyLarge!
                                        ,
                                      ),

                                    ],
                                  ),
                                  const SizBoxH(size: 0.008),
                                  Wrap(

                                    runSpacing: 13,
                                    children: [
                                      for (int a = 0; a <
                                          editPro.interest!.length; a++)
                                        Builder(builder: (context) {
                                          Interestlist data = editPro
                                              .interest![a];
                                          return InkWell(
                                            onTap: () {
                                              if (interestList.contains(
                                                  data.id) == true) {
                                                interestList.remove(data.id);
                                                notifyListeners();
                                              } else {
                                                if (interestList.length < 5) {
                                                  interestList.add(data.id);
                                                  notifyListeners();
                                                }
                                              }
                                            },
                                            child: Container(
                                              margin: const EdgeInsets
                                                  .symmetric(horizontal: 5),
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                  color: interestList.contains(
                                                      data.id) ? AppColors
                                                      .appColor : Theme
                                                      .of(context)
                                                      .cardColor,
                                                  borderRadius:
                                                  BorderRadius.circular(40),
                                                  border: Border.all(
                                                      color: Theme
                                                          .of(context)
                                                          .dividerTheme
                                                          .color!)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(data.title.toString(),
                                                      style: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .bodySmall!
                                                          .copyWith(
                                                          color:
                                                          interestList.contains(
                                                              data.id)
                                                              ? AppColors.white
                                                              : null)),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Image.network(
                                                    "${Config.baseUrl}${data
                                                        .img}",
                                                    height: 24,
                                                    width: 24,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        })
                                    ],
                                  )
                                ],
                              ),
                            ),
                            commonDivider(context),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.translate(
                                          "Languages I Know") ??
                                          "Languages I Know",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyLarge!
                                      ,
                                    ),

                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(
                                  runSpacing: 13,
                                  children: [
                                    for (int a = 0;
                                    a < editPro.language!.length;
                                    a++)
                                      Builder(builder: (context) {
                                        Languagelist data = editPro
                                            .language![a];
                                        return InkWell(
                                          onTap: () {
                                            if (languageList.contains(
                                                data.id) == true) {
                                              languageList.remove(data.id);
                                              notifyListeners();
                                            } else {
                                              if (languageList.length < 5) {
                                                languageList.add(data.id);
                                                notifyListeners();
                                              }
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                                color: languageList.contains(
                                                    data.id) ? AppColors
                                                    .appColor : Theme
                                                    .of(context)
                                                    .cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color: Theme
                                                        .of(context)
                                                        .dividerTheme
                                                        .color!)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(data.title.toString(),
                                                    style: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                        color:
                                                        languageList.contains(
                                                            data.id) ? AppColors
                                                            .white : null)),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Image.network(
                                                  "${Config.baseUrl}${data
                                                      .img}",
                                                  height: 24,
                                                  width: 24,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                  ],
                                )
                              ],
                            ),
                            commonDivider(context),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.translate(
                                          "Religion") ?? "Religion",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyLarge!
                                      ,
                                    ),
                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(

                                  runSpacing: 13,
                                  children: [
                                    for (int a = 0;
                                    a < editPro.religion!.length;
                                    a++)
                                      Builder(builder: (context) {
                                        Religionlist data = editPro.religion![a];
                                        return InkWell(
                                          onTap: () {
                                            selectReligion = int.parse(data.id.toString());
                                            notifyListeners();
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8),
                                            decoration: BoxDecoration(
                                                color: selectReligion ==
                                                    int.parse(
                                                        data.id.toString())
                                                    ? AppColors.appColor
                                                    : Theme
                                                    .of(context)
                                                    .cardColor,
                                                borderRadius:
                                                BorderRadius.circular(40),
                                                border: Border.all(
                                                    color:
                                                    Theme
                                                        .of(context)
                                                        .dividerTheme
                                                        .color!)
                                            ),
                                            child: Text(data.title.toString(),
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                    color:
                                                    selectReligion ==
                                                        int.parse(data.id
                                                            .toString())
                                                        ? AppColors.white
                                                        : null)),
                                          ),
                                        )
                                        ;
                                      })
                                  ],
                                ),
                              ],
                            ),
                            commonDivider(context),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.translate(
                                          "Relationship Goals") ??
                                          "Relationship Goals",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyLarge!
                                      ,
                                    ),
                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(
                                  runSpacing: 13,
                                  children: [
                                    for (int a = 0; a <
                                        editPro.relationShip!.length; a++)
                                      Builder(
                                          builder: (context) {
                                            Goallist data =
                                            editPro.relationShip![a];
                                            return InkWell(
                                              onTap: () {
                                                selectRelationShip = int.parse(
                                                    data.id.toString());
                                                notifyListeners();
                                                print(
                                                    " + + + + :-----  ${selectRelationShip}");
                                              },
                                              child: Container(
                                                margin: const EdgeInsets
                                                    .symmetric(horizontal: 5),
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8
                                                ),
                                                decoration: BoxDecoration(
                                                    color: selectRelationShip ==
                                                        int.parse(
                                                            data.id.toString())
                                                        ? AppColors.appColor
                                                        : Theme
                                                        .of(context)
                                                        .cardColor,
                                                    borderRadius: BorderRadius
                                                        .circular(40),
                                                    border: Border.all(color:
                                                    Theme
                                                        .of(context)
                                                        .dividerTheme
                                                        .color!)),
                                                child: Text(
                                                    data.title.toString(),
                                                    style: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                        color:
                                                        selectRelationShip ==
                                                            int.parse(data.id
                                                                .toString())
                                                            ? AppColors.white
                                                            : null)),
                                              ),
                                            );
                                          })
                                  ],
                                )
                              ],
                            ),


                            commonDivider(context),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      // "Verify Profile".tr,
                                      AppLocalizations.of(context)?.translate(
                                          "Verify Profile") ?? "Verify Profile",
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .bodyLarge!,
                                    ),

                                  ],
                                ),
                                const SizBoxH(size: 0.008),
                                Wrap(
                                  runSpacing: 13,
                                  children: [
                                    Builder(builder: (context) {
                                      return SizedBox(
                                        height: 45,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: verifylist.length,
                                          separatorBuilder: (context, index) {
                                            return const SizedBox(width: 10);
                                          },
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                selectverfy = index;
                                                selectverfy = int.parse(
                                                    index == 0 ? "0" : "2");
                                                print(
                                                    " + + + + :--- ${selectverfy}");
                                                notifyListeners();
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets
                                                    .symmetric(vertical: 5,
                                                    horizontal: 20),
                                                decoration: BoxDecoration(
                                                  color: selectverfy ==
                                                      int.parse(index == 0
                                                          ? "0"
                                                          : "2") ? AppColors
                                                      .appColor : Theme
                                                      .of(context)
                                                      .cardColor,
                                                  border: Border.all(
                                                      color: Theme
                                                          .of(context)
                                                          .dividerTheme
                                                          .color!, width: 1),
                                                  borderRadius: BorderRadius
                                                      .circular(35),
                                                ),
                                                child: Text(
                                                  "${verifylist[index]}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: selectverfy ==
                                                        int.parse(index == 0
                                                            ? "0"
                                                            : "2") ? AppColors
                                                        .white : null,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        },
      );
    },);
  }
}
extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}