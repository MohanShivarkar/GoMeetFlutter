// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'dart:async';

import 'package:dating/core/config.dart';
// import 'package:dating/core/ui.dart';
import 'package:dating/presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dating/presentation/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/ui.dart';
import '../../../language/localization/app_localization.dart';
import '../other/profileAbout/detailprovider.dart';
import '../other/profileAbout/detailscreen.dart';
import 'dart:ui' as ui;

final Set<Marker> _markers = {};
Future<Uint8List> getImages(String path, int width) async{
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return(await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}
class MapScreen extends StatefulWidget {
  static const mapScreenRoute = "/mapScreen";
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late HomeProvider homeProvider;

  @override
  void dispose() {
    super.dispose();
    homeProvider.mapDataList.clear();
    homeProvider.markers.clear();
  }



  @override
  void initState() {
    // fun();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.loadDataFrorMap(context).then((value) {
      fun();
      setState(() {

      });
    },);
    print("++++++++++ return screen ++++++++++");

    super.initState();
  }


  fun(){
    setState(() {
    Future.delayed(
      const Duration(seconds: 1),() {
      updateMarker(context: context,profileuimage: "assets/icons/Pin.png",id: homeProvider.mapModel.profilelist![0].profileId,lat1: double.parse(homeProvider.mapModel.profilelist![0].profileLat.toString()),long1: double.parse(homeProvider.mapModel.profilelist![0].profileLongs.toString()),title: homeProvider.mapModel.profilelist![0].profileName,subTitle: homeProvider.mapModel.profilelist![0].profileBio);
    },);
    });
  }


  bool ontapvarable = false;


  @override
  Widget build(BuildContext context) {
    homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: homeProvider.isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.appColor))
            : Stack(
                children: [

                  ListView(
                    children: [
                      for (int a = 0; a < homeProvider.mapDataList.length; a++)
                        Transform.translate(
                          offset: Offset(-MediaQuery.of(context).size.width * 2, -MediaQuery.of(context).size.height * 2),
                          child: RepaintBoundary(
                            key  : homeProvider.mapDataList[a]["gkey"],
                            child: homeProvider.mapDataList[a]["widget"],
                          ),
                        )
                    ],
                  ),

                  homeProvider.mapModel.profilelist!.isEmpty ?
                  GoogleMap(
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: homeProvider.kGooglePlex,
                  )
                      :  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        homeProvider.updateMapController(controller);
                      });
                    },
                    mapType: MapType.normal,
                    padding: const EdgeInsets.only(top: 110),
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        double.parse(homeProvider.mapModel.profilelist![0].profileLat.toString()),
                        double.parse(homeProvider.mapModel.profilelist![0].profileLongs.toString()),
                      ),
                      zoom: 12,
                    ),
                    markers: _markers,
                  ),


                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Theme.of(context).cardColor,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Row(
                                          children: [

                                            SvgPicture.asset(
                                              "assets/icons/Location.svg",
                                              colorFilter: ColorFilter.mode(AppColors.appColor, BlendMode.srcIn),
                                              height: 22,
                                              width: 22,
                                            ),

                                            const SizedBox(
                                              width: 6,
                                            ),

                                            Flexible(
                                              child: RichText(
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  text: TextSpan(children: [
                                                TextSpan(text: AppLocalizations.of(context)?.translate("Location (Within ") ?? "Location (Within ",style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    ),
                                                TextSpan(
                                                    text: homeProvider.radius.toStringAsFixed(2),style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    ),
                                                TextSpan(text: AppLocalizations.of(context)?.translate(" km)") ?? " km)",style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    ),
                                              ])),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          children: [

                                            const SizedBox(
                                              width: 8,
                                            ),

                                            homeProvider.location.isEmpty ?  Text("Your Current Location",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w800),maxLines: 1,overflow: TextOverflow.ellipsis,) :
                                            Expanded(
                                              child: SizedBox(
                                                child: Text(
                                                  homeProvider.location,
                                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w800),maxLines: 1,overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  homeProvider.isedit
                                      ? InkWell(
                                          onTap: () {
                                            homeProvider.updateisEdit();
                                          },
                                          child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(24),
                                                color: AppColors.appColor,
                                              ),
                                              child: Row(
                                                children: [

                                                  SvgPicture.asset(
                                                      "assets/icons/edit.svg",
                                                      height: 18,
                                                      width: 18,
                                                      colorFilter: ColorFilter.mode(
                                                              AppColors.white,
                                                              BlendMode.srcIn
                                                      )),

                                                  const SizedBox(
                                                    width: 6,
                                                  ),

                                                  Text(
                                                    AppLocalizations.of(context)?.translate("Edit") ?? "Edit",
                                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.white),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),

                                                ],
                                              )),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              homeProvider.isedit ? const SizedBox() : const SizedBox(height: 12),
                              homeProvider.isedit
                                  ? const SizedBox()
                                  : SliderTheme(
                                      data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay),
                                      child: Slider(
                                        value: homeProvider.radius,
                                        max: 500,
                                        min: 10,
                                        activeColor: AppColors.appColor,
                                        inactiveColor: AppColors.greyLight,
                                        label: homeProvider.radius.abs().toString(),
                                        onChanged: (double value) async {
                                          homeProvider.updateRadius(value);
                                        },
                                      ),
                                    ),
                              homeProvider.isedit
                                  ? const SizedBox()
                                  : const SizedBox(height: 12),
                              homeProvider.isedit
                                  ? const SizedBox()
                                  : MainButton(bgColor: AppColors.appColor,
                                      title: AppLocalizations.of(context)?.translate("Continue") ?? "Continue",
                                      onTap: () async {

                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setDouble("rediuse", homeProvider.radius);

                                        var lat = Provider.of<OnBordingProvider>(context, listen: false).lat;
                                        var long = Provider.of<OnBordingProvider>(context, listen: false).long;

                                        homeProvider.updateisEdit();

                                        homeProvider.mapDataList.removeWhere((element) {
                                          return element["id"] != "${Provider.of<HomeProvider>(context, listen: false).uid}";
                                        });

                                        homeProvider.markers.removeWhere((marker) {
                                          return marker.markerId.value != "${Provider.of<HomeProvider>(context, listen: false).uid}";
                                        });

                                        double? redises = prefs.getDouble("rediuse");


                                        homeProvider.mapData(
                                            uid: homeProvider.userlocalData.userLogin!.id.toString(),
                                            lat: lat.toString(),
                                            long: long.toString(),
                                            radius: redises.toString(),
                                        );

                                        fun();

                                      }),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),

                  homeProvider.mapModel.profilelist!.isEmpty ? const SizedBox() :   Positioned(

                    bottom: 0,
                    child: SizedBox(
                      height: 110,
                      width: MediaQuery.of(context).size.width,
                      child: Builder(builder: (context) {
                        return PageView.builder(
                          controller: homeProvider.pageController,
                          itemCount: homeProvider.mapModel.profilelist!.length,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index) {
                            updateMarker(context: context,profileuimage: "assets/icons/Pin.png",id: homeProvider.mapModel.profilelist![index].profileId,lat1: double.parse(homeProvider.mapModel.profilelist![index].profileLat.toString()),long1: double.parse(homeProvider.mapModel.profilelist![index].profileLongs.toString()),title: homeProvider.mapModel.profilelist![index].profileName,subTitle: homeProvider.mapModel.profilelist![index].profileBio);
                            Future.delayed(
                              const Duration(milliseconds: 100),
                                  () {
                                    homeProvider.updatePosition(homeProvider.mapModel.profilelist![index].profileLat.toString(), homeProvider.mapModel.profilelist![index].profileLongs.toString());
                                    setState(() {});
                              },
                            );

                          },
                          itemBuilder: (context, index) {

                            return InkWell(
                              onTap: () {
                                if(ontapvarable){
                                  return;
                                }else{
                                  ontapvarable = true;
                                }
                                var lat = Provider.of<OnBordingProvider>(context, listen: false).lat;
                                var long = Provider.of<OnBordingProvider>(context, listen: false).long;

                                Provider.of<DetailProvider>(context, listen: false).updateIsMatch(true);
                                Provider.of<DetailProvider>(context, listen: false).status = "1";
                                Provider.of<DetailProvider>(context, listen: false).detailsApi(uid: homeProvider.userlocalData.userLogin!.id ?? "", lat: lat.toString(), long: long.toString(), profileId: homeProvider.mapModel.profilelist![index].profileId ?? '').then((value) {

                                  Navigator.pushNamed(
                                    context,
                                    DetailScreen.detailScreenRoute,
                                  );

                                  ontapvarable = false;
                                  setState(() {

                                  });

                                });

                              },
                              child: Container(
                                margin: const EdgeInsets.all(15),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Theme.of(context).cardColor),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                height: 100,
                                width: 100,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage("${Config.baseUrl}${homeProvider.mapModel.profilelist![index].profileImages!.first}"),
                                    ),
                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          Text("${homeProvider.mapModel.profilelist![index].profileName.toString()}, ${homeProvider.mapModel.profilelist![index].profileAge.toString()}", style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w800, overflow: TextOverflow.ellipsis,), maxLines: 1),

                                          const SizedBox(height: 2),

                                          Text(homeProvider.mapModel.profilelist![index].profileBio.toString(), style: Theme.of(context).textTheme.bodySmall!, maxLines: 1, overflow: TextOverflow.ellipsis),

                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 45,
                                      width: 45,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.appColor,
                                      ),

                                      child: Center(
                                          child: SvgPicture.asset('assets/icons/Heart-fill.svg', colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn))
                                      ),

                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),

                ],
         ),
      ),
    );
  }
}



 Future updateMarker({id,lat1, long1,title,subTitle,profileuimage,context}) async {
  final Uint8List markIcons = await getImages("$profileuimage", 100);
    _markers.clear(); // Clear previous marker
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: LatLng(lat1, long1),
        onTap: (){
          showDialog(
            barrierColor: Colors.transparent,
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0,-0.22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          subTitle,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },);
            },
          );
        },
        icon: BitmapDescriptor.fromBytes(markIcons),
        draggable: true,
        onDragEnd: (newPosition) {
        },
      ),
    );
  // });
}