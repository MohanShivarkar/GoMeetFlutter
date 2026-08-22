import 'package:dating/presentation/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Logic/cubits/onBording_cubit/onbording_cubit.dart';
import '../../../language/localization/app_localization.dart';
import 'auth_screen.dart';
import 'onBordingProvider/onbording_provider.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String onBoardingScreenRoute = "/OnBoardingScreen";
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  late OnBordingProvider onBordingProvider;

  @override
  void initState() {
    BlocProvider.of<OnbordingCubit>(context).smstypeapi(context);
    super.initState();
  }
  late OnbordingCubit onbordingCubit;


  @override
  Widget build(BuildContext context) {
    onBordingProvider = Provider.of<OnBordingProvider>(context);
    onbordingCubit = Provider.of<OnbordingCubit>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: onBordingProvider.onbordingScroll,
            onPageChanged: (value) {
              onBordingProvider.updateOnboradingCurrent(value);
            },
            itemCount: onBordingProvider.onBordingData.length,
            itemBuilder: (context, index){
              return Container(
                decoration:  BoxDecoration(
                  image: DecorationImage(image: AssetImage(onBordingProvider.onBordingData[index]["image"]))
                ),
                height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,);
            }
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 25,
                    width : MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        ...List.generate(
                            onBordingProvider.onBordingData.length,
                                (index) {
                              return Indicator(
                                isActive: onBordingProvider.onboradingCurrent == index ? true : false,
                              );
                            }),

                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(onBordingProvider.onBordingData[onBordingProvider.onboradingCurrent]["title"],style: Theme.of(context).textTheme.headlineSmall,textAlign: TextAlign.center,maxLines: 2),
                  const SizedBox(height: 20,),
                   onBordingProvider.onboradingCurrent == onBordingProvider.onBordingData.length-1 ? Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Expanded(child: InkWell(
                           onTap: () async {
                             SharedPreferences prefs = await SharedPreferences.getInstance();
                             prefs.setString("maintainanceenabled", onbordingCubit.smaTypeApiModel?.maintainanceEnabled ?? "No");
                             Navigator.pushNamedAndRemoveUntil(context, AuthScreen.authScreenRoute, (route) => false);
                           },
                           child: Text(AppLocalizations.of(context)?.translate("Skip") ?? "Skip",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700),textAlign: TextAlign.center,))
                       ),
                       Expanded(
                         child: MainButton(title: AppLocalizations.of(context)?.translate("Let's Start") ?? "Let's Start",radius: 80,onTap: () async {
                           SharedPreferences prefs = await SharedPreferences.getInstance();
                           prefs.setString("maintainanceenabled", onbordingCubit.smaTypeApiModel?.maintainanceEnabled ?? "No");
                           Navigator.pushNamedAndRemoveUntil(context, AuthScreen.authScreenRoute, (route) => false);
                         },),
                       ),
                     ],
                   ) :Row(
                       children: [
                    Expanded(child: InkWell(
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setString("maintainanceenabled", onbordingCubit.smaTypeApiModel?.maintainanceEnabled ?? "No");
                          Navigator.pushNamedAndRemoveUntil(context, AuthScreen.authScreenRoute, (route) => false);
                        },
                        child: Text(AppLocalizations.of(context)?.translate("Skip") ?? "Skip",style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700),textAlign: TextAlign.center,))
                    ),
                     Expanded(child: MainButton(title: AppLocalizations.of(context)?.translate("Next") ?? "Next",radius: 80,onTap: () {
                       onBordingProvider.onbordingScroll.jumpToPage(onBordingProvider.onboradingCurrent+1);
                    },)),
                  ]),
            ]),
          ),
        ],
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
