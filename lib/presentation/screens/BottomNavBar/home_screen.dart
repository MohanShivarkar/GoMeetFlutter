import 'package:carousel_slider/carousel_slider.dart';
import 'package:dating/Logic/cubits/Home_cubit/home_cubit.dart';
import 'package:dating/data/models/homemodel.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/screens/BottomNavBar/notification_page.dart';
import 'package:dating/presentation/screens/other/editProfile/editprofile_provider.dart';
import 'package:dating/presentation/screens/other/likeMatch/like_match.dart';
import 'package:dating/presentation/screens/other/likeMatch/likematch_provider.dart';
import 'package:dating/presentation/screens/other/premium/premium.dart';
import 'package:dating/presentation/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../Logic/cubits/Home_cubit/homestate.dart';
import '../../../Logic/cubits/onBording_cubit/onbording_cubit.dart';
import '../../../core/config.dart';
import '../../../core/ui.dart';
import '../../../language/localization/app_localization.dart';
import '../../firebase/chat_page.dart';
import '../../widgets/sizeboxx.dart';
import '../other/editProfile/editprofile.dart';
import '../other/profileAbout/detailprovider.dart';
import '../other/profileAbout/detailscreen.dart';
import '../splash_bording/onBordingProvider/onbording_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String homeScrennRoute = "/homeScreen";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

int sum = 0;
List selectedItems = [];
List imagelist = [];
List coinlist = [];


class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeProvider homeProvider;
  late EditProfileProvider editProfileProvider;
  late OnbordingCubit onbordingCubit;

  @override
  void initState() {
    super.initState();

    BlocProvider.of<HomePageCubit>(context).initforHome(context);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
    initForHome();

    // Client-side Firebase service-account token bootstrap stays disabled
    // because it is not required for the legacy home landing path.

    homeProvider.localData(context);
    homeProvider.giftlistApi(context);

    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context);

    // Google Ads and client-side access token bootstrap stay disabled here
    // because they are out of scope for the current recovery pass and break web compatibility.
    homeProvider.controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400),);
    homeProvider.animation = Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, -1.0)).animate(homeProvider.controller);

  }

  initForHome(){
    BlocProvider.of<OnbordingCubit>(context).religionApi().then((value) {
      editProfileProvider.valuInReligion(value.religionlist!);
      BlocProvider.of<OnbordingCubit>(context).relationGoalListApi().then((value) {
        editProfileProvider.valuInrelationShip(value.goallist!);
        BlocProvider.of<OnbordingCubit>(context).languagelistApi().then((value)  {
          editProfileProvider.valuInLanguage(value.languagelist!); 
          BlocProvider.of<OnbordingCubit>(context).getInterestApi().then((value) {
            editProfileProvider.valuInIntrest(value.interestlist!);
          });
        });
      });
    });
  }

  String emapty = '';
  String emapty1 = '';

  @override
  void dispose() {
    homeProvider.controller.dispose();
    super.dispose();
  }


  bool ontapvarable = false;

  List<String> _profileImages(Profilelist? profile) {
    return (profile?.profileImages ?? <String>[])
        .where((image) => image.trim().isNotEmpty)
        .toList();
  }

  String? _profileImageUrl(Profilelist? profile) {
    final images = _profileImages(profile);
    if (images.isEmpty) {
      return null;
    }
    return "${Config.baseUrl}${images.first}";
  }

  String? _currentUserAvatarUrl() {
    try {
      final profilePic = homeProvider.userlocalData.userLogin?.profilePic?.toString();
      if (profilePic == null || profilePic.trim().isEmpty) {
        return null;
      }
      return "${Config.baseUrl}$profilePic";
    } catch (_) {
      return null;
    }
  }

  String _safeName(String? value) {
    final trimmed = value?.trim() ?? "";
    return trimmed.isEmpty ? "Guest" : trimmed;
  }

  String _safeInitial(String? value) {
    final trimmed = value?.trim() ?? "";
    return trimmed.isEmpty ? "G" : trimmed[0].toUpperCase();
  }

  int _matchPercent(Profilelist? profile) {
    final ratio = profile?.matchRatio;
    if (ratio == null || !ratio.isFinite) {
      return 0;
    }
    final safeRatio = ratio.clamp(0, 100);
    return safeRatio.round();
  }

  Future<void> _openProfileDetails(HomeCompleteState state) async {
    if (state.homeData.profilelist == null || state.homeData.profilelist!.isEmpty) {
      return;
    }

    final currentProfile = state.homeData.profilelist![homeProvider.currentIndex];
    final userId = (() {
      try {
        return homeProvider.userlocalData.userLogin?.id ?? "";
      } catch (_) {
        return "";
      }
    })();
    if (userId.isEmpty) {
      Fluttertoast.showToast(msg: "User session is still loading");
      return;
    }

    final lat = Provider.of<OnBordingProvider>(context, listen: false).lat;
    final long = Provider.of<OnBordingProvider>(context, listen: false).long;
    Provider.of<DetailProvider>(context, listen: false).updateIsMatch(false);
    Provider.of<DetailProvider>(context, listen: false).status = "1";
    await Provider.of<DetailProvider>(context, listen: false).detailsApi(
      uid: userId,
      lat: lat.toString(),
      long: long.toString(),
      profileId: currentProfile.profileId ?? "",
    );
    if (!mounted) {
      return;
    }
    Navigator.pushNamed(context, DetailScreen.detailScreenRoute);
  }




  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context);
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return Scaffold(
      appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: BlocBuilder<HomePageCubit, HomePageStates>(
                builder: (context, state) {
                  if (state is HomeCompleteState) {
          if (state.homeData.profilelist!.isNotEmpty &&
              homeProvider.currentIndex >= state.homeData.profilelist!.length) {
            homeProvider.currentIndex = 0;
          }
          final avatarUrl = _currentUserAvatarUrl();
          return Container(
            // height: 70,
            margin: const EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Theme.of(context).scaffoldBackgroundColor,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const Spacer(),
                Row(
                  children: [
                    avatarUrl != null ? Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover
                          ),
                      ),
                    ) : Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(_safeInitial((() {
                        try {
                          return homeProvider.userlocalData.userLogin?.name?.toString();
                        } catch (_) {
                          return null;
                        }
                      })()),style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
                    ),
                    const SizBoxW(size: 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                                  children: [
                                  TextSpan(text: AppLocalizations.of(context)?.translate("Hello") ?? "Hello",style: Theme.of(context).textTheme.bodySmall,),
                                  TextSpan(text: " 👋",style: Theme.of(context).textTheme.bodySmall,),
                           ])
                          ),

                          Text(
                            _safeName((() {
                              try {
                                return homeProvider.userlocalData.userLogin?.name?.toString();
                              } catch (_) {
                                return null;
                              }
                            })()),
                            style: Theme.of(context).textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        ],
                      ),
                    ),


                    InkWell(
                        onTap: () {
                          Navigator.pushNamed(context,  NotificationPage.notificationRoute);
                        },
                        child: SvgPicture.asset("assets/icons/notificationicon.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)),

                    const SizBoxW(size: 0.03),

                    InkWell(
                        onTap: () {
                          state.homeData.filterInclude == "0" ? Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute):
                          homeProvider.filterBottomSheet(context);
                        },
                        child: SvgPicture.asset("assets/icons/Filter.svg",colorFilter: ColorFilter.mode(Theme.of(context).indicatorColor, BlendMode.srcIn),)
                    ),


                  ],
                ),

              ],
            ),
          );
          }else{
            return const SizedBox();
          }
        }
              ),
            ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<HomePageCubit, HomePageStates>(
          builder: (context1, state) {
            if (state is HomeLoadingState) {
              return Center(child: CircularProgressIndicator(color: AppColors.appColor));
            } else if (state is HomeCompleteState) {
              return state.homeData.profilelist!.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                   children: [
                     const Spacer(),
                     Text(AppLocalizations.of(context)?.translate("No New Profiles") ?? "No New Profiles",style: Theme.of(context).textTheme.headlineMedium,),
                     Text(AppLocalizations.of(context)?.translate("Change your preferences to expand your search and see new profiles.") ?? "Change your preferences to expand your search and see new profiles.",style: Theme.of(context).textTheme.bodyMedium,textAlign: TextAlign.center),
                     const Spacer(),
                     MainButton(
                        bgColor: AppColors.appColor,
                        title: AppLocalizations.of(context)?.translate("Change my preferences") ?? "Change my preferences",onTap: () {
                        homeProvider.setSelectPage(4);
                        Navigator.pushNamed(context, EditProfile.editProfileRoute);
                     },),
                     const SizedBox(height: 12,),
                     MainButton(
                       title: AppLocalizations.of(context)?.translate("Refresh") ?? "Refresh",
                       bgColor: AppColors.borderColor,
                       titleColor: AppColors.black,
                       onTap: () {
                       BlocProvider.of<HomePageCubit>(context).initforHome(context);
                     },
                   ),
                   ],
                ),
              )
                  : Stack (
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                     children: [

                  PageView.builder(
                    itemCount: state.homeData.profilelist!.length,
                    onPageChanged: (i) {
                      homeProvider.upDateCurrentindex(i);
                    },
                    itemBuilder: (context, index) {
                      int nextIndex = homeProvider.currentIndex == state.homeData.profilelist!.length - 1 ? 0 : homeProvider.currentIndex + 1;
                      final nextProfile = state.homeData.profilelist![nextIndex];
                      final nextPreviewImage = _profileImageUrl(nextProfile);
                      return index == state.homeData.profilelist!.length - 1 ? const SizedBox() :
                      SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height / 1.45,
                              child: Stack(
                                children: [

                                  Container(
                                    height: MediaQuery.of(context).size.height / 1.45,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      image: nextPreviewImage != null
                                          ? DecorationImage(
                                              image: NetworkImage(nextPreviewImage),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: nextPreviewImage == null
                                        ? Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              color: Theme.of(context).indicatorColor.withOpacity(0.5),
                                              size: 48,
                                            ),
                                          )
                                        : null,
                                  ),

                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [

                                      Container(
                                        height: MediaQuery.of(context).size.height / 1.45,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            stops: const [0.4, 1, 1.5],
                                            colors: [
                                              Colors.transparent,
                                              AppColors.appColor,
                                              AppColors.appColor,
                                            ],
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [

                                                state.homeData.profilelist![nextIndex].profileName!.length >= 7 ?
                                                Expanded(
                                                  child: Text(
                                                    "${state.homeData.profilelist![nextIndex].profileName}",
                                                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ):
                                                Text(
                                                  "${state.homeData.profilelist![nextIndex].profileName}",
                                                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),

                                                Expanded(
                                                  child: Text(
                                                    ",${state.homeData.profilelist![nextIndex].profileAge}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall!
                                                        .copyWith(
                                                        color: Colors.white),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),



                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Stack(
                                                        alignment: Alignment.center,
                                                        clipBehavior: Clip.none,
                                                        children: [

                                                          nextProfile.isSubscribe != "0" ?  Row(
                                                            children: [
                                                              Image.asset("assets/Image/premium.png",height: 25,width: 25,),
                                                              const SizedBox(width: 8,),
                                                              Text("Premium",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white),)
                                                            ],
                                                          ) : const SizedBox(),

                                                          SizedBox(
                                                            height: 50,
                                                            width: 50,
                                                            child: CircularProgressIndicator(
                                                                backgroundColor: Colors.white.withOpacity(0.3),
                                                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                                                value: _matchPercent(nextProfile) / 100
                                                            ),
                                                          ),

                                                          // COMMET CODE

                                                          nextProfile.isSubscribe != "0"? const SizBoxH(size: 0.02) : const SizedBox(),

                                                          Text("${_matchPercent(nextProfile)}%", style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),),

                                                        ],
                                                      ),
                                                      const SizBoxH(size: 0.02),
                                                      Container(
                                                        alignment: Alignment.center,
                                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(16),
                                                          color: const Color(0xffF0F0F0).withOpacity(0.25),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/icons/Location.svg",
                                                              height: 15,
                                                              width: 15,
                                                            ),
                                                            const SizBoxW(size: 0.02),
                                                            Flexible(
                                                              child: Text(
                                                                state.homeData.profilelist![nextIndex].profileDistance.toString(),
                                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white,fontSize: 12),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "${state.homeData.profilelist![nextIndex].profileBio}",
                                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizBoxH(size: 0.04),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),

                                  _profileImages(nextProfile).length > 1 ?  SizedBox(
                                    height: 25,
                                    width : MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        ...List.generate(
                                            _profileImages(nextProfile).length,
                                                (index) {
                                              return Indicator(
                                                isActive: homeProvider.interIndex1 == index ? true : false,
                                              );
                                            }),

                                      ],
                                    ),
                                  ) : const SizedBox(),

                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  InkWell(
                        onTap: () {
                          print("hiii");

                          var lat = Provider.of<OnBordingProvider>(context, listen: false).lat;
                          var long = Provider.of<OnBordingProvider>(context, listen: false).long;
                          Provider.of<DetailProvider>(context, listen: false).updateIsMatch(false);
                          Provider.of<DetailProvider>(context, listen: false).status = "1";
                          Provider.of<DetailProvider>(context, listen: false).detailsApi(uid: homeProvider.userlocalData.userLogin!.id ?? "", lat: lat.toString(), long: long.toString(), profileId: state.homeData.profilelist![homeProvider.currentIndex].profileId ?? '').then((value) {
                            Navigator.pushNamed(
                              context,
                              DetailScreen.detailScreenRoute,
                            );
                            ontapvarable = false;
                            setState(() {});
                          });

                        },
                        child: SwipeDetector(
                          onSwipeLeft: (offset) {
                            print("11111111111111111fhdhh111111111111");
                            homeProvider.cancleButton(state,context);
                            print("22222222222222dfhdfhdh222222222222222");
                            BlocProvider.of<HomePageCubit>(context).profileLikeDislikeApi(uid: homeProvider.uid, proId: state.homeData.profilelist![homeProvider.currentIndex].profileId!, action: "UNLIKE", lat: homeProvider.lat, long: homeProvider.long).then((value) {
                              BlocProvider.of<HomePageCubit>(context).getHomeData(uid: homeProvider.uid,
                                  lat: homeProvider.lat.toString(),
                                  long: homeProvider.long.toString(),
                                  context: context).then((value) {
                                  homeProvider.currentIndex = 0;
                                  setState(() {});
                               });
                             },);
                            print("33333333333333333333333333333");
                          },
                          onSwipeRight: (offset) {
                            print("vjhsvjhvfjhvfjhvfjfvjhv");
                            homeProvider.likeButton(state,context);
                            BlocProvider.of<HomePageCubit>(context).profileLikeDislikeApi(uid: homeProvider.uid, proId: state.homeData.profilelist![homeProvider.currentIndex].profileId!, action: "LIKE", lat: homeProvider.lat, long: homeProvider.long).then((value) {
                              BlocProvider.of<HomePageCubit>(context).getHomeData(uid: homeProvider.uid,
                                  lat: homeProvider.lat.toString(),
                                  long: homeProvider.long.toString(),
                                  context: context).then((value) {
                                homeProvider.currentIndex = 0;
                                setState(() { });
                              });
                            },);
                          },
                          child: PageView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.homeData.profilelist!.length,
                            onPageChanged: (i) {
                              homeProvider.upDateCurrentindex(i);
                            },
                            itemBuilder: (context, index) {
                              if (state.homeData.profilelist!.isEmpty) {
                                return const SizedBox();
                              } else {
                                return SlideTransition(
                                  position: homeProvider.animation,
                                  child: SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: GestureDetector(
                                      onTap: () => _openProfileDetails(state),
                                      // onPanUpdate: _onDragUpdate,
                                      // onPanEnd: (details) {
                                      //   // if (profiles.isNotEmpty) {
                                      //     if (swipeDirection == "Right") {
                                      //       print("Liked: ${profiles.first}");
                                      //       homeProvider.likeButton(state,context);
                                      //       BlocProvider.of<HomePageCubit>(context).profileLikeDislikeApi(
                                      //         uid: homeProvider.uid,
                                      //         proId: state.homeData.profilelist![homeProvider.currentIndex].profileId!,
                                      //         action: "LIKE",
                                      //         lat: homeProvider.lat,
                                      //         long: homeProvider.long,
                                      //       ).then((value) {
                                      //         // After success, fetch updated data
                                      //         BlocProvider.of<HomePageCubit>(context).getHomeData(
                                      //           uid: homeProvider.uid,
                                      //           lat: homeProvider.lat.toString(),
                                      //           long: homeProvider.long.toString(),
                                      //           context: context,
                                      //         ).then((value) {
                                      //           homeProvider.currentIndex = 0;
                                      //           setState(() {});
                                      //         });
                                      //       });
                                      //
                                      //     }
                                      //     else if (swipeDirection == "Left") {
                                      //       print("Disliked: ${profiles.first}");
                                      //       homeProvider.cancleButton(state,context);
                                      //       BlocProvider.of<HomePageCubit>(context).profileLikeDislikeApi(
                                      //         uid: homeProvider.uid,
                                      //         proId: state.homeData.profilelist![homeProvider.currentIndex].profileId!,
                                      //         action: "UNLIKE",
                                      //         lat: homeProvider.lat,
                                      //         long: homeProvider.long,
                                      //       ).then((value) {
                                      //         // After success, fetch updated data
                                      //         BlocProvider.of<HomePageCubit>(context).getHomeData(
                                      //           uid: homeProvider.uid,
                                      //           lat: homeProvider.lat.toString(),
                                      //           long: homeProvider.long.toString(),
                                      //           context: context,
                                      //         ).then((value) {
                                      //           homeProvider.currentIndex = 0;
                                      //           setState(() {});
                                      //         });
                                      //       });
                                      //     // }
                                      //
                                      //     // Remove the swiped profile
                                      //     setState(() {
                                      //       profiles.removeAt(0);
                                      //     });
                                      //
                                      //
                                      //   } // Trigger swipe completion
                                      //   swipeDirection = ''; // Reset swipe direction
                                      // },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(48),
                                          child: Container(
                                            color: Theme.of(context).cardColor,
                                            height: MediaQuery.of(context).size.height / 1.45,
                                            child: Stack(
                                              children: [
                                                Builder(
                                                  builder: (context) {
                                                    final currentProfile = state.homeData.profilelist![homeProvider.currentIndex];
                                                    final currentImages = _profileImages(currentProfile);

                                                    return CarouselSlider.builder(
                                                      itemCount: currentImages.isEmpty ? 1 : currentImages.length,
                                                      carouselController: homeProvider.carouselController,
                                                      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
                                                        final imageUrl = currentImages.isEmpty
                                                            ? null
                                                            : "${Config.baseUrl}${currentImages[itemIndex]}";

                                                        return Container(
                                                          height: MediaQuery.of(context).size.height / 1.45,
                                                          width: MediaQuery.of(context).size.width,
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context).cardColor,
                                                            image: imageUrl != null
                                                                ? DecorationImage(
                                                                    image: NetworkImage(imageUrl),
                                                                    fit: BoxFit.cover,
                                                                  )
                                                                : null,
                                                          ),
                                                          child: imageUrl == null
                                                              ? Center(
                                                                  child: Icon(
                                                                    Icons.image_outlined,
                                                                    color: Theme.of(context).indicatorColor.withOpacity(0.5),
                                                                    size: 48,
                                                                  ),
                                                                )
                                                              : null,
                                                        );
                                                      },
                                                      options: CarouselOptions(
                                                        autoPlay: currentImages.length > 1,
                                                        enableInfiniteScroll: currentImages.length > 1,
                                                        height: MediaQuery.of(context).size.height / 1.45,
                                                        onPageChanged: (i, r) {
                                                          homeProvider.upDateinnerindex(i);
                                                        },
                                                        viewportFraction: 1,
                                                      ),
                                                    );
                                                  },
                                                ),

                                                Stack(
                                                  alignment: Alignment.bottomCenter,
                                                  children: [

                                                    Positioned(
                                                      bottom: 0,
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height / 1.45,
                                                        width: MediaQuery.of(context).size.width,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                            stops: const [0.4, 1, 1.5],
                                                            colors: [
                                                              Colors.transparent,
                                                              homeProvider.slidecolor,
                                                              homeProvider.slidecolor,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding: const EdgeInsets.all(15.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [

                                                              state.homeData.profilelist![homeProvider.currentIndex].profileName!.length >= 7 ?
                                                              Expanded(
                                                                child: Text(
                                                                  "${state.homeData.profilelist![homeProvider.currentIndex].profileName}",
                                                                  // "123456789",
                                                                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                              ) :
                                                              Text(
                                                                "${state.homeData.profilelist![homeProvider.currentIndex].profileName}",
                                                                // "123456789",
                                                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                              ),

                                                              Expanded(
                                                                child: Text(
                                                                  ",${state.homeData.profilelist![homeProvider.currentIndex].profileAge}",
                                                                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                              ),

                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [

                                                                    state.homeData.profilelist![homeProvider.currentIndex].isSubscribe != "0" ?  Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Image.asset("assets/Image/premium.png",height: 25,width: 25,),
                                                                        const SizedBox(width: 8,),
                                                                        Text(AppLocalizations.of(context)?.translate("Premium") ?? "Premium",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white),),
                                                                      ],
                                                                    ) : const SizedBox(),

                                                                    const SizBoxH(size: 0.02),

                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Stack(
                                                                          alignment: Alignment.center,
                                                                          clipBehavior: Clip.none,
                                                                          children: [
                                                                            SizedBox(
                                                                              height: 50,
                                                                              width : 50,
                                                                              child: CircularProgressIndicator(
                                                                                  backgroundColor: Colors.white.withOpacity(0.3),
                                                                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                                                                  value: _matchPercent(state.homeData.profilelist![homeProvider.currentIndex]) / 100
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              "${_matchPercent(state.homeData.profilelist![homeProvider.currentIndex])}%",
                                                                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),

                                                                    state.homeData.profilelist![homeProvider.currentIndex].isSubscribe != "0" ? const SizedBox() : const SizBoxH(size: 0.02),

                                                                    state.homeData.profilelist![homeProvider.currentIndex].isSubscribe != "0" ? const SizBoxH(size: 0.02) : const SizedBox(),

                                                                    Container(
                                                                      alignment: Alignment.center,
                                                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(16),
                                                                        color: const Color(0xffF0F0F0).withOpacity(0.25),
                                                                      ),

                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: [

                                                                          SvgPicture.asset(
                                                                            "assets/icons/Location.svg",
                                                                            height: 15,
                                                                            width: 15,
                                                                          ),

                                                                          const SizBoxW(size: 0.01),

                                                                          Flexible(
                                                                            child: Text(
                                                                              state.homeData.profilelist![homeProvider.currentIndex].profileDistance.toString(),
                                                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white,fontSize: 12),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          // Spacer()

                                                                        ],
                                                                      ),
                                                                    ),

                                                                  ],
                                                                ),
                                                              ),

                                                            ],
                                                          ),

                                                          Text(
                                                            "${state.homeData.profilelist![homeProvider.currentIndex].profileBio}",
                                                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),

                                                          const SizBoxH(size: 0.04),

                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                _profileImages(state.homeData.profilelist![homeProvider.currentIndex]).length > 1 ? SizedBox(
                                                  height: 25,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [

                                                      ...List.generate(
                                                          _profileImages(state.homeData.profilelist![homeProvider.currentIndex]).length, (index) {
                                                        return Indicator(
                                                          isActive: homeProvider.interIndex == index ? true : false,
                                                        );
                                                      }
                                                      ),

                                                    ],
                                                  ),
                                                ) : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                  ),

                  Positioned(
                    bottom: -7,
                    child: SizedBox(
                      height: 90,
                      child: Column(
                        children: [

                          Expanded(
                            child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                separatorBuilder: (c, i) {
                                  return const SizedBox(
                                    width: 20,
                                  );
                                },
                                itemCount: onbordingCubit.smaTypeApiModel?.giftFun == "Enabled" ? homeProvider.flotingIcons.length : homeProvider.flotingIconscondition.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (c, i) {
                                  return Center(
                                    child: InkWell(
                                      onTap: () {

                                        if (i == 2  && state.homeData.planId == "0") {
                                          Navigator.pushNamed(context, PremiumScreen.premiumScreenRoute);
                                        }

                                        if (state.homeData.profilelist!.isNotEmpty){
                                          if (i == 0) {
                                            print("11111111111111111fhdhh111111111111");
                                            homeProvider.cancleButton(state,context);
                                            print("22222222222222dfhdfhdh222222222222222");
                                            BlocProvider.of<HomePageCubit>(context).profileLikeDislikeApi(uid: homeProvider.uid, proId: state.homeData.profilelist![homeProvider.currentIndex].profileId!, action: "UNLIKE", lat: homeProvider.lat, long: homeProvider.long).then((value) {
                                              BlocProvider.of<HomePageCubit>(context).getHomeData(uid: homeProvider.uid,
                                                  lat: homeProvider.lat.toString(),
                                                  long: homeProvider.long.toString(),
                                                  context: context).then((value) {
                                                homeProvider.currentIndex = 0;
                                                // notifyListeners();
                                                setState(() {

                                                });
                                              });
                                            },);
                                            print("33333333333333333333333333333");
                                          } else if (i == 1) {
                                            print("vjhsvjhvfjhvfjhvfjfvjhv");
                                            homeProvider.likeButton(state,context);
                                            BlocProvider.of<HomePageCubit>(context).profileLikeDislikeApi(uid: homeProvider.uid, proId: state.homeData.profilelist![homeProvider.currentIndex].profileId!, action: "LIKE", lat: homeProvider.lat, long: homeProvider.long).then((value) {
                                              BlocProvider.of<HomePageCubit>(context).getHomeData(uid: homeProvider.uid,
                                                  lat: homeProvider.lat.toString(),
                                                  long: homeProvider.long.toString(),
                                                  context: context).then((value) {
                                                homeProvider.currentIndex = 0;
                                                // notifyListeners();
                                                setState(() {

                                                });
                                              });
                                            },);
                                          }
                                        }

                                        if(i == 3){
                                          print("++++: (${state.homeData.profilelist![homeProvider.currentIndex].profileId})");
                                          selectedItems.clear();
                                          coinlist.clear();
                                          imagelist.clear();
                                          sum = 0;

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
                                                            title: AppLocalizations.of(context)?.translate("Send") ?? "Send", onTap: () {
                                                            print("hello");


                                                            if(selectedItems.isEmpty){
                                                              Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Please select gift") ?? "Please select gift");
                                                            }else{
                                                              homeProvider.giftbuyApi(context: context,coin: sum.toString(),receiver_id: "${state.homeData.profilelist![homeProvider.currentIndex].profileId}", gift_img: imagelist.join(",")).then((value) {
                                                                Navigator.pop(context);
                                                                print("+++++++uper:--------- ${value['coin']}");
                                                                // sum == 0 ? state.homeData.coin :
                                                                sum == 0 ?
                                                                state.homeData.coin = state.homeData.coin
                                                                    :
                                                                state.homeData.coin = value['coin'];
                                                                print("+++++++down:--------- ${value['coin']}");

                                                                showModalBottomSheet(
                                                                  context: context,
                                                                  constraints: const BoxConstraints(maxHeight: 250),
                                                                  isScrollControlled: true,
                                                                  builder: (context) {
                                                                    return StatefulBuilder(builder: (context, setState) {
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
                                                                                const SizedBox(height: 40,),
                                                                                Row(
                                                                                  children: [
                                                                                    const Spacer(),
                                                                                    Lottie.asset("assets/lottie/giftsend.json",height: 100),
                                                                                    const Spacer(),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(height: 30,),
                                                                                Text("You`ve sent a gift to ${state.homeData.profilelist![homeProvider.currentIndex].profileName}",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),)
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },);
                                                                  },
                                                                );

                                                              },);
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
                                                              padding: EdgeInsets.zero,
                                                              itemCount: homeProvider.giftListApiModel.giftlist.length,
                                                              itemBuilder: (context, a) {
                                                                return  InkWell(
                                                                  onTap: () {
                                                                    setState((){


                                                                      if(state.homeData.coin == "0"){

                                                                        if(homeProvider.giftListApiModel.giftlist[a].price == "0"){

                                                                          if (selectedItems.contains(a)){
                                                                            coinlist.remove(homeProvider.giftListApiModel.giftlist[a].price);
                                                                            imagelist.remove(homeProvider.giftListApiModel.giftlist[a].img);
                                                                            sum -= int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                                            selectedItems.remove(a);
                                                                          } else {
                                                                            coinlist.add(homeProvider.giftListApiModel.giftlist[a].price);
                                                                            imagelist.add(homeProvider.giftListApiModel.giftlist[a].img);
                                                                            sum += int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                                            selectedItems.add(a);
                                                                          }

                                                                        }else{
                                                                          Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Insufficient coins in wallet") ?? "Insufficient coins in wallet");
                                                                        }

                                                                      }else{

                                                                        if (selectedItems.contains(a)){
                                                                          coinlist.remove(homeProvider.giftListApiModel.giftlist[a].price);
                                                                          imagelist.remove(homeProvider.giftListApiModel.giftlist[a].img);
                                                                          sum -= int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                                          selectedItems.remove(a);
                                                                          print("+++++:-- ${sum}");
                                                                        } else {
                                                                          coinlist.add(homeProvider.giftListApiModel.giftlist[a].price);
                                                                          imagelist.add(homeProvider.giftListApiModel.giftlist[a].img);
                                                                          int temp = 0;
                                                                          temp= sum + int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                                          if(temp > int.parse(state.homeData.coin.toString())){
                                                                            Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Insufficient coins in wallet") ?? "Insufficient coins in wallet");
                                                                          }else{
                                                                            sum += int.parse(homeProvider.giftListApiModel.giftlist[a].price);
                                                                            selectedItems.add(a);
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
                                                                            Image(image: NetworkImage("${Config.baseUrl}${homeProvider.giftListApiModel.giftlist[a].img}"),height: 40,),
                                                                            const SizedBox(height: 10,),
                                                                            homeProvider.giftListApiModel.giftlist[a].price == "0" ?
                                                                            Text(AppLocalizations.of(context)?.translate("Free") ?? "Free",style: Theme.of(context).textTheme.bodySmall!.copyWith())
                                                                                :
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 12,),
                                                                                const SizedBox(width: 2,),
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

                                        }

                                      },
                                      child: (i == 2 && state.homeData.planId != "0") ? (state.homeData.directChat == "1") ? InkWell(
                                        onTap: () {
                                          final currentProfile = state.homeData.profilelist![homeProvider.currentIndex];

                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChattingPage(
                                            proPic: _profileImageUrl(currentProfile) ?? "",
                                            resiverUserId: currentProfile.profileId ?? "",
                                            resiverUseremail: currentProfile.profileName ?? "",
                                          )));

                                        },
                                        child: Container(
                                          height: (i == 0 || i == homeProvider.flotingIcons.length-1) ? 60 : 72,
                                          width:  (i == 0 || i == homeProvider.flotingIcons.length-1) ? 60 : 72,
                                          decoration: BoxDecoration(color: AppColors.darkContainer,
                                              borderRadius: BorderRadius.circular(20)),
                                          child: Center(child: SvgPicture.asset("assets/icons/Chat-fill.svg",height: 29, width: 29,)),
                                        ),
                                      ) : const SizedBox() :
                                      onbordingCubit.smaTypeApiModel?.giftFun == "Enabled" ?   Container(
                                        height: (i == 0 || i == homeProvider.flotingIcons.length-1) ? 60 : 72,
                                        width:  (i == 0 || i == homeProvider.flotingIcons.length-1) ? 60 : 72,
                                        decoration: BoxDecoration(color: AppColors.darkContainer,
                                            borderRadius: BorderRadius.circular(20)),
                                        child:  Center(child: SvgPicture.asset(homeProvider.flotingIcons[i],height: 29, width: 29, color: i == 3 ? Colors.yellow : null)),
                                      ) : Container(
                                        height: (i == 0 || i == homeProvider.flotingIconscondition.length-1) ? 60 : 72,
                                        width:  (i == 0 || i == homeProvider.flotingIconscondition.length-1) ? 60 : 72,
                                        decoration: BoxDecoration(color: AppColors.darkContainer,
                                            borderRadius: BorderRadius.circular(20)),
                                        child:  Center(child: SvgPicture.asset(homeProvider.flotingIconscondition[i],height: 29, width: 29,)),
                                      ),
                                    ),
                                  );
                                }),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                        ],
                      ),
                    ),
                  ),

                ],
              );
            } else {
              return const SizedBox();
            }

          },
          listener: (context, state) {

            if (state is HomeErrorState) {
              Fluttertoast.showToast(msg: state.error);
            }

            if(state is HomeCompleteState) {
              if(state.homeData.totalliked!.isNotEmpty) {
                Provider.of<LikeMatchProvider>(context,listen: false).likeMatchData.addAll(state.homeData.totalliked!);
                Provider.of<LikeMatchProvider>(context,listen: false).updateIsHome(true);
                Navigator.pushNamed(context, LikeMatchScreen.likeMatchScreenRoute).then((value) {
                  BlocProvider.of<HomePageCubit>(context).getHomeData(uid: homeProvider.uid, lat: homeProvider.lat.toString(), long: homeProvider.long.toString(),context: context);
                });
              }
            }

          },
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final bool isActive;
  const Indicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        height: isActive ?  6 : 6,
        width: isActive  ? 15 : 6,
        decoration: BoxDecoration(
          color: isActive ? AppColors.appColor : AppColors.borderColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class MarqueeWidget extends StatefulWidget {
  final String text;
  final double velocity;

  MarqueeWidget({required this.text, this.velocity = 100.0});

  @override
  _MarqueeWidgetState createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;
  late double _screenWidth;
  late double _textWidth;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDimensions();
    });
  }

  void _calculateDimensions() {
    final RenderBox renderBoxText = _textKey.currentContext!.findRenderObject() as RenderBox;
    _textWidth = renderBoxText.size.width;
    _screenWidth = MediaQuery.of(context).size.width;
    _startScrolling();
  }

  void _startScrolling() {
    final double scrollLength = _textWidth + _screenWidth;
    _scrollController.animateTo(
      scrollLength,
      duration: Duration(seconds: (scrollLength / widget.velocity).round()),
      curve: Curves.linear,
    ).then((_) {
      if (mounted) {
        _scrollController.jumpTo(0.0);
        _startScrolling();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: [
          Text(widget.text, key: _textKey, style: const TextStyle()),
        ],
      ),
    );
  }
}

