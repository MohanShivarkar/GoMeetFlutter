import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Logic/cubits/onBording_cubit/onbording_cubit.dart';



// 4321098767 :- abcdef
// 9909909901 :- 123


String android_bannerid = "";
String android_in_id = "";

String ios_bannerid = "";
String ios_in_id = "";
String agoraVcKey = "";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String splashScreenRoute = "/";
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context).then((value) {
      fun();
      android_bannerid = value["banner_id"] ?? "";
      android_in_id = value["in_id"] ?? "";
      ios_bannerid = value["ios_banner_id"] ?? "";
      ios_in_id = value["ios_in_id"] ?? "";
      agoraVcKey = value["agora_app_id"] ?? "";
      // agoraVcKey = "3b2d066ea4da4c84ad4492ea72780653";
      print("agoraVcKey:- $agoraVcKey");
    }).catchError((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("maintainanceenabled", "No");
      await prefs.setString("otpauth", "No");
    });
    Provider.of<OnBordingProvider>(context, listen: false).getCurrentLatAndLong(context);

  }
  
  
  fun() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      "maintainanceenabled",
      onbordingCubit.smaTypeApiModel?.maintainanceEnabled ?? "No",
    );
    prefs.setString("otpauth", onbordingCubit.smaTypeApiModel?.otpAuth ?? "No");
  }

  late OnbordingCubit onbordingCubit;

  @override
  Widget build(BuildContext context) {
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: SvgPicture.asset("assets/Image/appLogo.svg",height:60,width: 60,)),
        ],
      ),
    );
  }
}
