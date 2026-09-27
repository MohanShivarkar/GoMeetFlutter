import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'dart:convert';
// ignore_for_file: unused_local_variable, avoid_print, unnecessary_brace_in_string_interps, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:dating/Logic/cubits/Home_cubit/home_cubit.dart';
import 'package:dating/Logic/cubits/language_cubit/language_bloc.dart';
import 'package:dating/Logic/cubits/litedark/lite_dark_cubit.dart';
import 'package:dating/core/ui.dart';
import 'package:dating/presentation/screens/Splash_Bording/auth_screen.dart';
import 'package:dating/presentation/screens/other/editProfile/editprofile.dart';
import 'package:dating/presentation/screens/other/premium/plandetials.dart';
import 'package:dating/presentation/screens/other/premium/premium.dart';
import 'package:dating/presentation/screens/other/profileScreen/faqpage.dart';
import 'package:dating/presentation/screens/other/profileScreen/pagelist.dart';
import 'package:dating/presentation/screens/other/profileScreen/profile_privacy.dart';
import 'package:dating/presentation/screens/other/profileScreen/profile_provider.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dating/presentation/widgets/sizeboxx.dart';
import 'package:dating/wallete_code/wallete_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' if (dart.library.html) 'package:dating/stubs/google_mobile_ads_stub.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Logic/cubits/Home_cubit/homestate.dart';
import '../../../../Logic/cubits/onBording_cubit/onbording_cubit.dart';
import '../../../../by_coin_screen/coin_screen.dart';
import '../../../../by_coin_screen/mygift.dart';
import '../../../../by_coin_screen/refer_and_earn_screen.dart';
import '../../../../core/config.dart';
import '../../../../core/google_ads.dart';
import '../../../../core/app_download_helper.dart';
import '../../../../data/localdatabase.dart';
import '../../../../language/localization/app_localization.dart';
import '../../../../wallete_code/wallet_provider.dart';
import '../../../firebase/chat_page.dart';
import '../../../widgets/appbarr.dart';
import '../../../widgets/main_button.dart';
import '../../BottomNavBar/bottombar.dart';
import '../../BottomNavBar/homeProvider/homeprovier.dart';

List<CameraDescription> cameras = [];

late CameraController imagecontroller;
late Future<void> initializeControllerFuture;


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const profilePageRoute = "/profilePage";

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late HomeProvider homeProvider;
  late ProfileProvider profileProvider;
  late OnBordingProvider onBordingProvider;

  late HomePageCubit homePageCubit;
  late HomeCompleteState homeCompleteState;
  late WalleteProvider walleteProvider;
  late OnbordingCubit onbordingCubit;

  late Future<void> _initializeControllerFuture;


  @override
  void initState() {
    super.initState();

    loadAd();
    BlocProvider.of<HomePageCubit>(context).initforHome(context);
    profileProvider = Provider.of<ProfileProvider>(context,listen: false);
    walleteProvider = Provider.of<WalleteProvider>(context,listen: false);
    homeProvider = Provider.of<HomeProvider>(context,listen: false);
    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context);
    profileProvider.faqApi(context);

    profileProvider.pageListApi(context);
    profileProvider.getPackage();
    walleteProvider.walletreportApi(context: context);
    getTheme().then((value) {
      setState(() {
        if(value == "dark"){
          profileProvider.isDartMode = true;
        }else{
          profileProvider.isDartMode = false;
        }
      });
    });
    getdata();
    fun();
  }



  @override
  void dispose() {
    try {
      imagecontroller.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _showProfilePhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.translate("Update Profile Photo") ?? "Update Profile Photo",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickAndUploadProfilePic(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: Text(AppLocalizations.of(context)?.translate("Gallery") ?? "Gallery"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _pickAndUploadProfilePic(kIsWeb ? ImageSource.gallery : ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(AppLocalizations.of(context)?.translate("Camera") ?? "Camera"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadProfilePic(ImageSource source) async {
    try {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          profileloader = true;
          selectImageprofile = picked;
        });
        final bytes = await picked.readAsBytes();
        setState(() {
          selectImageprofileBytes = Uint8List.fromList(bytes);
        });
        final base64Str = base64Encode(bytes);
        await profileProvider.profilepicApi(context: context, img: base64Str);
        setState(() {
          profileloader = false;
        });
        Fluttertoast.showToast(msg: "Profile photo updated successfully!");
      }
    } catch (e) {
      setState(() {
        profileloader = false;
      });
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }


  String networkImage = "";
  XFile? selectImageprofile;
  Uint8List? selectImageprofileBytes;
  XFile? selectImageprofilevaridfy;
  ImagePicker picker = ImagePicker();
  ImagePicker pickervaridfy = ImagePicker();
  String? base64String;
  String? base64Stringverfy;


  bool _isFrontCamera = false;


  void _toggleCamera() async {
    CameraDescription newCameraDescription;
    if (_isFrontCamera) {
      newCameraDescription = cameras.firstWhere((camera) =>
      camera.lensDirection == CameraLensDirection.back);
    } else {
      newCameraDescription = cameras.firstWhere((camera) =>
      camera.lensDirection == CameraLensDirection.front);
    }

    imagecontroller = CameraController(
      newCameraDescription,
      ResolutionPreset.medium,
      enableAudio: false
    );

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      initializeControllerFuture = imagecontroller.initialize();
    });
  }

  int value = 0;

  List languageimage = [
    'assets/icons/L-English.png',
    'assets/icons/L-Spanish.png',
    'assets/icons/L-Arabic.png',
    'assets/icons/L-Hindi-Gujarati.png',
    'assets/icons/L-Portuguese.png',
    'assets/icons/L-Afrikaans.png',
    'assets/icons/L-Bengali.png',
    'assets/icons/L-German.png',
    'assets/icons/L-Indonesian.png',
  ];

  List languagetext = [
    'English',
    'Spanish',
    'Arabic',
    'Hindi',
    'Gujarati',
    'Portuguese',
    'Afrikaans',
    'Bengali',
    'German',
    'Indonesian',
  ];


  fun() async {
    for(int a= 0 ;a<languagetext.length;a++){
      if(languagetext[a].toString().compareTo(Get.locale.toString()) == 0){
        setState(() {
          value = a;
        });
      }else{
      }
    }
  }


  getdata() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    value = preferences.getInt("valuelangauge") ?? 0;
  }

  bool profileloader = false;

  @override
  Widget build(BuildContext context) {
    walleteProvider = Provider.of<WalleteProvider>(context);
    homeProvider = Provider.of<HomeProvider>(context);
    profileProvider = Provider.of<ProfileProvider>(context);
    onBordingProvider = Provider.of<OnBordingProvider>(context);
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return  Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appbarr(context, AppLocalizations.of(context)?.translate("Profile") ?? "Profile"),
      body:  SafeArea(
        child: walleteProvider.islaoding ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: BlocBuilder<HomePageCubit,HomePageStates>(
                builder: (context1, state) {
                if(state is HomeCompleteState){
                  return Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // InkWell(
                          //   onTap: () {
                          //     Provider.of<HomeProvider>(context,listen: false).setSelectPage(0);
                          //     Navigator.pushNamedAndRemoveUntil(context, BottomBar.bottomBarRoute, (route) => true);
                          //   },
                          //   child: Center(
                          //     child: Container(
                          //       height: 50,
                          //       width: 50,
                          //       decoration: BoxDecoration(
                          //         color: AppColors.appColor,
                          //         borderRadius: BorderRadius.circular(10)
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                              clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [


                                   Builder(
                                     builder: (context) {
                                       final profileList = state.homeData.profilelist;
                                       if (profileList == null || profileList.isEmpty) {
                                         return const SizedBox();
                                       }
                                       final safeIndex = (homeProvider.currentIndex >= 0 && homeProvider.currentIndex < profileList.length)
                                           ? homeProvider.currentIndex
                                           : 0;
                                       final ratioStr = profileList[safeIndex].matchRatio?.toString().split(".").first ?? "100";
                                       final ratioVal = (double.tryParse(ratioStr) ?? 100.0) / 100.0;
                                       return SizedBox(
                                         height: 70,
                                         width: 70,
                                         child: CircularProgressIndicator(
                                           strokeCap: StrokeCap.round,
                                           strokeWidth: 4,
                                           valueColor: AlwaysStoppedAnimation(AppColors.appColor),
                                           value: ratioVal,
                                         ),
                                       );
                                     },
                                   ),


                                   InkWell(
                                     onTap: () => _showProfilePhotoSheet(),
                                     child: selectImageprofileBytes != null ? Container(
                                        height: 66,
                                        width: 66,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: MemoryImage(selectImageprofileBytes!), fit: BoxFit.cover),
                                        )) : (homeProvider.userlocalData.userLogin?.profilePic != null && homeProvider.userlocalData.userLogin!.profilePic!.isNotEmpty) ? Container(
                                        height: 66,
                                        width: 66,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: NetworkImage("${Config.baseUrl}${homeProvider.userlocalData.userLogin!.profilePic}"), fit: BoxFit.cover),
                                        )) : CircleAvatar(
                                      backgroundColor: Colors.grey.withOpacity(0.2),
                                      maxRadius: 33,
                                      child: Center(child: Text(
                                        (homeProvider.userlocalData.userLogin?.name != null && homeProvider.userlocalData.userLogin!.name!.isNotEmpty)
                                            ? "${homeProvider.userlocalData.userLogin!.name![0]}"
                                            : "U",
                                        style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                   ),
                                   Positioned(
                                     bottom: 0,
                                     right: 0,
                                     child: InkWell(
                                       onTap: () => _showProfilePhotoSheet(),
                                       child: Container(
                                         padding: const EdgeInsets.all(4),
                                         decoration: BoxDecoration(
                                           color: AppColors.appColor,
                                           shape: BoxShape.circle,
                                           border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                         ),
                                         child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                                       ),
                                     ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    "${homeProvider.userlocalData.userLogin?.name ?? ''}",
                                                    style: Theme.of(context).textTheme.headlineSmall,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                state.homeData.isVerify == "1"
                                                    ? const Padding(
                                                        padding: EdgeInsets.only(top: 2.0),
                                                        child: Image(
                                                          image: AssetImage("assets/icons/newverfy.png"),
                                                          height: 20,
                                                          width: 20,
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                            if (homeProvider.userlocalData.userLogin?.mobile != null && homeProvider.userlocalData.userLogin!.mobile!.isNotEmpty)
                                              Text(
                                                "${homeProvider.userlocalData.userLogin!.mobile}",
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            else if (homeProvider.userlocalData.userLogin?.email != null && homeProvider.userlocalData.userLogin!.email!.isNotEmpty)
                                              Text(
                                                "${homeProvider.userlocalData.userLogin!.email}",
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, EditProfile.editProfileRoute);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.appColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)?.translate("Edit") ?? "Edit",
                                                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 5),
                                              SvgPicture.asset(
                                                "assets/icons/edit.svg",
                                                width: 14,
                                                height: 14,
                                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            (onbordingCubit.smaTypeApiModel?.admobEnabled == "Yes" && !kIsWeb && bannerADs != null && bannerADs() != null)
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 60,
                                    child: AdWidget(ad: bannerADs()!),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                state.homeData.planId != "0"
                                    ? Navigator.pushNamed(context, PlanDetils.planRoutes)
                                    : Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: AppColors.appColor,
                                  image: const DecorationImage(image: AssetImage("assets/Image/profileBg.png"), fit: BoxFit.cover),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              state.homeData.planId != "0"
                                                  ? AppLocalizations.of(context)?.translate("You're Activated Membership!") ?? "You're Activated Membership!"
                                                  : AppLocalizations.of(context)?.translate("Join Our Membership Today!") ?? "Join Our Membership Today!",
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              state.homeData.planId != "0"
                                                  ? AppLocalizations.of(context)?.translate("Enjoy  premium and match anywhere.") ?? "Enjoy  premium and match anywhere."
                                                  : "Checkout LoveCloud Premium",
                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.white, overflow: TextOverflow.ellipsis),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          state.homeData.planId != "0"
                                              ? AppLocalizations.of(context)?.translate("Active") ?? "Active"
                                              : AppLocalizations.of(context)?.translate("Go") ?? "Go",
                                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.appColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizBoxH(size: 0.01),
                            if (kIsWeb)
                              Container(
                                margin: const EdgeInsets.only(top: 8, bottom: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1E162B), Color(0xFF2B1829)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFF9933).withOpacity(0.4)),
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 42,
                                      width: 42,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFF4458)]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.install_mobile_rounded, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "LoveCloud Mobile App",
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Get native HD voice & video calls.",
                                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.72)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        AppDownloadHelper.downloadApk(url: '/app/lovecloud.apk', filename: 'lovecloud.apk');
                                        Fluttertoast.showToast(msg: "Downloading LoveCloud Android APK...");
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9933),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text("Get APK", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                          onbordingCubit.smaTypeApiModel?.giftFun == "Enabled" ?  ListView.builder(
                            clipBehavior: Clip.none,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (c, i) {
                                return i == 6 ? profileProvider.isLoading ?  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {

                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Loream(title: profileProvider.privacyPolicy.pagelist![index].title.toString(), discription: profileProvider.privacyPolicy.pagelist![index].description.toString()),));

                                        },
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Center(
                                            child: SvgPicture.asset("assets/icons/clipboard-text.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),
                                              // height: 25,
                                              // width: 25,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          profileProvider.privacyPolicy.pagelist![index].title.toString(),
                                          style: Theme.of(context).textTheme.bodyMedium!,
                                        ),
                                        trailing:  SvgPicture.asset("assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),),
                                      );
                                    }  ,itemCount: profileProvider.privacyPolicy.pagelist!.length) : const SizedBox() :



                                ListTile(
                                  onTap: () async {
                                    if (i == 0) {
                                      Navigator.pushNamed(context, EditProfile.editProfileRoute);
                                    }
                                    else if(i == 1){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Wallete_Screen(),));
                                    }
                                    else if(i == 2){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ByCoiin(),));
                                    }
                                    else if(i == 3){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Coin_Withdraw_Screen(),));
                                    }
                                    else if(i == 4){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Refer_And_Earn(),));
                                    }
                                    else if(i == 7){
                                      Navigator.pushNamed(context, FaqPage.faqRoute);
                                    }
                                    else if(i == 8){
                                      profileProvider.blocklistaApi(context).then((value) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const profile_privacyy(),));
                                        setState(() {
                                        });
                                      });
                                    }
                                    else if(i == 9){

                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                        return Container(
                                          height: 610,
                                          decoration:  BoxDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                                          ),
                                          child:  Padding(
                                            padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.vertical,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: 8,
                                                    itemBuilder: (context, index) {
                                                      return GestureDetector(
                                                        onTap: () async{

                                                          SharedPreferences preferences = await SharedPreferences.getInstance();

                                                          setState(()  {
                                                            value = index;
                                                            preferences.setInt("valuelangauge", value);
                                                          });



                                                          switch (index) {
                                                            case 0:
                                                              BlocProvider.of<LanguageCubit>(context).toEnglish();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 1:
                                                              BlocProvider.of<LanguageCubit>(context).toSpanish();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 2:
                                                              BlocProvider.of<LanguageCubit>(context).toArabic();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 3:
                                                              BlocProvider.of<LanguageCubit>(context).toHindi();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 4:
                                                              BlocProvider.of<LanguageCubit>(context).toGujarati();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 5:
                                                              BlocProvider.of<LanguageCubit>(context).toAfrikaans();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 6:
                                                              BlocProvider.of<LanguageCubit>(context).toBengali();
                                                              Navigator.pop(context);
                                                              break;
                                                            case 7:
                                                              BlocProvider.of<LanguageCubit>(context).toIndonesian();
                                                              Navigator.pop(context);
                                                              break;
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 60,
                                                          width: MediaQuery.of(context).size.width,
                                                          margin: const EdgeInsets.symmetric(vertical: 7),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(color: value == index ? AppColors.appColor : Colors.transparent,),
                                                              color:  Theme.of(context).scaffoldBackgroundColor,
                                                              borderRadius: BorderRadius.circular(10)),
                                                          child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      height: 45,
                                                                      width: 60,
                                                                      margin: const EdgeInsets.symmetric(
                                                                          horizontal: 10),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.transparent,
                                                                        borderRadius: BorderRadius.circular(100),
                                                                      ),
                                                                      child: Center(
                                                                        child: Container(
                                                                          height: 32,
                                                                          width: 32,
                                                                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(languageimage[index]),)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(height: 10),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(languagetext[index], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
                                                                      ],
                                                                    ),
                                                                    const Spacer(),
                                                                    CheckboxListTile(index),
                                                                    const SizedBox(width: 15,),
                                                                  ],
                                                                ),
                                                              ]),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                         },
                                      );

                                    }
                                    else if(i == profileProvider.menuList.length -2) {
                                      profileProvider.deleteButtomSheet(context);
                                    }else if(i == profileProvider.menuList.length -3) {
                                      Share.share(
                                        "Hey! 👋've found this awesome dating app called ${profileProvider.appName} and thought you might be interested too! 😊.Check it out:${kIsWeb ? '' : (Platform.isAndroid
                                            ? 'https://play.google.com/store/apps/details?id=${profileProvider.packageName}'
                                            : Platform.isIOS
                                            ? 'https://apps.apple.com/us/app/${profileProvider.appName}/id${profileProvider.packageName}'
                                            : '')}",
                                      );
                                    }
                                    else if(i == profileProvider.menuList.length -1) {
                                      isUserLogOut(Provider.of<HomeProvider>(context,listen: false).uid);
                                      Navigator.pushNamedAndRemoveUntil(context, AuthScreen.authScreenRoute,(route) => false,);
                                      homeProvider.setSelectPage(0);
                                      Preferences.clear();
                                      // await GoogleSignIn().signOut();
                                      // await FacebookAuth.instance.logOut();
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setDouble("rediuse", 0);
                                    }
                                  },
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Center(
                                      child: SvgPicture.asset("${profileProvider.menuList[i]["icon"]}",colorFilter: ColorFilter.mode(profileProvider.menuList[i]["iconShow"] == "0" ? Colors.red : Theme.of(context).indicatorColor, BlendMode.srcIn),
                                        // height: 25,
                                        // width: 25,
                                      ),
                                    ),
                                  ),
                                  title: Text(AppLocalizations.of(context)?.translate("${profileProvider.menuList[i]["title"]}") ?? "${profileProvider.menuList[i]["title"]}", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: profileProvider.menuList[i]["iconShow"] == "0" ? Colors.red : null),),
                                  trailing: profileProvider.menuList[i]["iconShow"] == "2" ? SizedBox(
                                    height: 40,
                                    width: 30,
                                    child: Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                            value: profileProvider.isDartMode,
                                            onChanged: (r) async {
                                              profileProvider.changeMode();

                                              if(r) {
                                                BlocProvider.of<ThemeBloc>(context).addTheme(ThemeEvent.toggleDark);
                                                setThemeData('dark');
                                              } else {
                                                BlocProvider.of<ThemeBloc>(context).addTheme(ThemeEvent.toggleLight);
                                                setThemeData('lite');
                                              }

                                            })),
                                  ) :
                                  profileProvider.menuList[i]["iconShow"] == "1" ? SvgPicture.asset("${profileProvider.menuList[i]["traling"]}",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),) : const SizedBox(),
                                );
                              },
                              itemCount: profileProvider.menuList.length
                          ) : ListView.builder(
                              clipBehavior: Clip.none,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (c, i) {
                                return i == 3 ? profileProvider.isLoading ?  ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        onTap: () {

                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Loream(title: profileProvider.privacyPolicy.pagelist![index].title.toString(), discription: profileProvider.privacyPolicy.pagelist![index].description.toString()),));

                                        },
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: Center(
                                            child: SvgPicture.asset("assets/icons/clipboard-text.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),
                                              // height: 25,
                                              // width: 25,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          profileProvider.privacyPolicy.pagelist![index].title.toString(),
                                          style: Theme.of(context).textTheme.bodyMedium!,
                                        ),
                                        trailing:  SvgPicture.asset("assets/icons/Arrow - Right 2.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),),
                                      );
                                    }  ,itemCount: profileProvider.privacyPolicy.pagelist!.length) : const SizedBox() :



                                ListTile(
                                  onTap: () async {
                                    if (i == 0) {
                                      Navigator.pushNamed(context, EditProfile.editProfileRoute);
                                    }
                                    else if(i == 1){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Wallete_Screen(),));
                                      // Navigator.pushNamed(context, FaqPage.faqRoute);
                                    }
                                    else if(i == 2){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Refer_And_Earn(),));
                                    }
                                    else if(i == 5){
                                      Navigator.pushNamed(context, FaqPage.faqRoute);
                                    }
                                    else if(i == 6){
                                      profileProvider.blocklistaApi(context).then((value) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const profile_privacyy(),));
                                        setState(() {
                                        });
                                      });
                                    }
                                    else if(i == 7){
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Container(
                                            height: 610,
                                            decoration:  BoxDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                                            ),
                                            child:  Padding(
                                              padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.vertical,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemCount: 8,
                                                      itemBuilder: (context, index) {
                                                        return GestureDetector(
                                                          onTap: () async{

                                                            SharedPreferences preferences = await SharedPreferences.getInstance();

                                                            setState(()  {
                                                              value = index;
                                                              preferences.setInt("valuelangauge", value);
                                                            });



                                                            switch (index) {
                                                              case 0:
                                                                BlocProvider.of<LanguageCubit>(context).toEnglish();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 1:
                                                                BlocProvider.of<LanguageCubit>(context).toSpanish();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 2:
                                                                BlocProvider.of<LanguageCubit>(context).toArabic();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 3:
                                                                BlocProvider.of<LanguageCubit>(context).toHindi();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 4:
                                                                BlocProvider.of<LanguageCubit>(context).toGujarati();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 5:
                                                                BlocProvider.of<LanguageCubit>(context).toAfrikaans();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 6:
                                                                BlocProvider.of<LanguageCubit>(context).toBengali();
                                                                Navigator.pop(context);
                                                                break;
                                                              case 7:
                                                                BlocProvider.of<LanguageCubit>(context).toIndonesian();
                                                                Navigator.pop(context);
                                                                break;
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 60,
                                                            width: MediaQuery.of(context).size.width,
                                                            margin: const EdgeInsets.symmetric(vertical: 7),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(color: value == index ? AppColors.appColor : Colors.transparent,),
                                                                color:  Theme.of(context).scaffoldBackgroundColor,
                                                                borderRadius: BorderRadius.circular(10)),
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        height: 45,
                                                                        width: 60,
                                                                        margin: const EdgeInsets.symmetric(
                                                                            horizontal: 10),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.transparent,
                                                                          borderRadius: BorderRadius.circular(100),
                                                                        ),
                                                                        child: Center(
                                                                          child: Container(
                                                                            height: 32,
                                                                            width: 32,
                                                                            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(languageimage[index]),)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 10),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(languagetext[index], style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14)),
                                                                        ],
                                                                      ),
                                                                      const Spacer(),
                                                                      CheckboxListTile(index),
                                                                      const SizedBox(width: 15,),
                                                                    ],
                                                                  ),
                                                                ]),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );

                                    }
                                    else if(i == profileProvider.menuListcondition.length -2) {
                                      profileProvider.deleteButtomSheet(context);
                                    }else if(i == profileProvider.menuListcondition.length -3) {
                                      Share.share(
                                        "Hey! 👋've found this awesome dating app called ${profileProvider.appName} and thought you might be interested too! 😊.Check it out:${kIsWeb ? '' : (Platform.isAndroid
                                            ? 'https://play.google.com/store/apps/details?id=${profileProvider.packageName}'
                                            : Platform.isIOS
                                            ? 'https://apps.apple.com/us/app/${profileProvider.appName}/id${profileProvider.packageName}'
                                            : '')}",
                                      );
                                    }
                                    else if(i == profileProvider.menuListcondition.length -1) {
                                      isUserLogOut(Provider.of<HomeProvider>(context,listen: false).uid);
                                      Navigator.pushNamedAndRemoveUntil(context, AuthScreen.authScreenRoute,(route) => false,);
                                      homeProvider.setSelectPage(0);
                                      Preferences.clear();
                                      // await GoogleSignIn().signOut();
                                      // await FacebookAuth.instance.logOut();
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setDouble("rediuse", 0);
                                    }
                                  },
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Center(
                                      child: SvgPicture.asset("${profileProvider.menuListcondition[i]["icon"]}",colorFilter: ColorFilter.mode(profileProvider.menuListcondition[i]["iconShow"] == "0" ? Colors.red : Theme.of(context).indicatorColor, BlendMode.srcIn),
                                        // height: 25,
                                        // width: 25,
                                      ),
                                    ),
                                  ),
                                  title: Text(AppLocalizations.of(context)?.translate("${profileProvider.menuListcondition[i]["title"]}") ?? "${profileProvider.menuListcondition[i]["title"]}", style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: profileProvider.menuListcondition[i]["iconShow"] == "0" ? Colors.red : null),),
                                  trailing: profileProvider.menuListcondition[i]["iconShow"] == "2" ? SizedBox(
                                    height: 40,
                                    width: 30,
                                    child: Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                            value: profileProvider.isDartMode,
                                            onChanged: (r) async {
                                              profileProvider.changeMode();

                                              if(r) {
                                                BlocProvider.of<ThemeBloc>(context).addTheme(ThemeEvent.toggleDark);
                                                setThemeData('dark');
                                              } else {
                                                BlocProvider.of<ThemeBloc>(context).addTheme(ThemeEvent.toggleLight);
                                                setThemeData('lite');
                                              }

                                            })),
                                  ) :
                                  profileProvider.menuListcondition[i]["iconShow"] == "1" ? SvgPicture.asset("${profileProvider.menuListcondition[i]["traling"]}",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),) : const SizedBox(),
                                );
                              },
                              itemCount: profileProvider.menuListcondition.length
                          ),
                          // SizedBox(height: 100,)
                        ],
                      ),
                      profileloader ? Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
                      ) : SizedBox()
                    ],
                  );
                }
                else{
                  return Padding(
                    padding: const EdgeInsets.only(top: 300),
                    child: Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
                  );
                }
              }
            ),
          ),
        ) : Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
      ),
    );
  }

  setThemeData(String value) async {
    SharedPreferences preferences =  await SharedPreferences.getInstance();

    preferences.setString("ThemeData", value);
  }


  Widget CheckboxListTile(int index) {
    return SizedBox(
      height: 24,
      width: 24,
      child: ElevatedButton(
        onPressed: () async {
          value = index;
          SharedPreferences preferences = await SharedPreferences.getInstance();
          setState(() {
            value = index;
            preferences.setInt("valuelangauge", value);

            switch (index) {
              case 0:
                BlocProvider.of<LanguageCubit>(context).toEnglish();
                Navigator.pop(context);
                break;
              case 1:
                BlocProvider.of<LanguageCubit>(context).toSpanish();
                Navigator.pop(context);
                break;
              case 2:
                BlocProvider.of<LanguageCubit>(context).toArabic();
                Navigator.pop(context);
                break;
              case 3:
                BlocProvider.of<LanguageCubit>(context).toHindi();
                Navigator.pop(context);
                break;
              case 4:
                BlocProvider.of<LanguageCubit>(context).toGujarati();
                Navigator.pop(context);
                break;
              case 5:
                BlocProvider.of<LanguageCubit>(context).toAfrikaans();
                Navigator.pop(context);
                break;
              case 6:
                BlocProvider.of<LanguageCubit>(context).toBengali();
                Navigator.pop(context);
                break;
              case 7:
                BlocProvider.of<LanguageCubit>(context).toIndonesian();
                Navigator.pop(context);

            }

          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xffEEEEEE),
          side: BorderSide(
            color: (value == index)
                ? Colors.transparent
                : Colors.transparent,
            width: (value == index) ? 2 : 2,
          ),
          padding: const EdgeInsets.all(0),
        ),
        child: Center(
            child: Icon(
              Icons.check,
              color: value == index ? Colors.black : Colors.transparent,
              size: 18,
            )),
      ),
    );
  }



}