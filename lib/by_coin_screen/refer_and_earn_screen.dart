// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/ui.dart';
import '../language/localization/app_localization.dart';
import '../presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import 'coin_provider.dart';


class Refer_And_Earn extends StatefulWidget {
  const Refer_And_Earn({super.key});

  @override
  State<Refer_And_Earn> createState() => _Refer_And_EarnState();
}

class _Refer_And_EarnState extends State<Refer_And_Earn> {


  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
  late ByCoinProvider byCoinProvider;

  @override
  void initState() {
    super.initState();
    byCoinProvider = Provider.of<ByCoinProvider>(context,listen: false);
    byCoinProvider.referandearnApi(context);
    getPackage();
  }

  void getPackage() async {
    //! App details get
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    packageName = packageInfo!.packageName;
  }


  @override
  Widget build(BuildContext context) {
    byCoinProvider = Provider.of<ByCoinProvider>(context);
    return Scaffold(
      body:
      byCoinProvider.isreferload ?
      Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppColors.appColor,
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(15),bottomLeft: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40,left: 15),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/BackIcon.svg",
                          height: 25,
                          width: 25,
                          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)?.translate("Refer your friends") ?? "Refer your friends",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 25,color: Colors.white)),
                          Text(AppLocalizations.of(context)?.translate("& Earn Coins!") ?? "& Earn Coins!",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 25,color: Colors.white)),
                        ],
                      ),
                      const Spacer(),
                      Lottie.asset('assets/lottie/refer&earnscreen.json',height: 170)
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(
                        children: [
                          TextSpan(text: AppLocalizations.of(context)?.translate("Invite all your friend to ") ?? "Invite all your friend to ",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20,fontWeight: FontWeight.bold)),
                          TextSpan(text: AppLocalizations.of(context)?.translate("GoMeet") ?? "GoMeet",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20,color: AppColors.appColor,fontWeight: FontWeight.bold)),
                        ]
                    )),
                    const SizedBox(height: 15,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration:  BoxDecoration(
                                color: Colors.grey.withOpacity(0.6),
                                shape: BoxShape.circle
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: RichText(text: TextSpan(
                              children: [
                                TextSpan(text: AppLocalizations.of(context)?.translate("Your referred person gets ") ?? "Your referred person gets ",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                                TextSpan(text: byCoinProvider.referAndEarnApiModel.signupcredit,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: AppLocalizations.of(context)?.translate(" coins when they sign up using your code") ?? " coins when they sign up using your code",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                              ]
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration:  BoxDecoration(
                                color: Colors.grey.withOpacity(0.6),
                                shape: BoxShape.circle
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: RichText(text: TextSpan(
                              children: [
                                TextSpan(text: AppLocalizations.of(context)?.translate("and you receive ") ?? "and you receive ",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                                TextSpan(text: byCoinProvider.referAndEarnApiModel.refercredit,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
                                TextSpan(text: AppLocalizations.of(context)?.translate(" coins when the person you referred purchases a membership.") ?? " coins when the person you referred purchases a membership.",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                              ]
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration:  BoxDecoration(
                                color: Colors.grey.withOpacity(0.6),
                                shape: BoxShape.circle
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: RichText(text: TextSpan(
                              children: [
                                TextSpan(text: AppLocalizations.of(context)?.translate("Start inviting friends today and enjoy the benefits together!") ?? "Start inviting friends today and enjoy the benefits together!",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                              ]
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFe1e9f5),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 40,
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(byCoinProvider.referAndEarnApiModel.code, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: AppColors.appColor),),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                new ClipboardData(text: byCoinProvider.referAndEarnApiModel.code),
                              );
                            },
                            child: Image(image: const AssetImage('assets/icons/copyicon.png'),height: 25,width: 25,color: AppColors.appColor,),
                          ),
                          const SizedBox(width: 10,),
                          const SizedBox(width: 20,),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () async {
                          // await FlutterShare.share(
                          //     title: '$appName',
                          //     text: 'Hey! Now use our app to share with your family or friends. User will get wallet coin on your 1st successful transaction. Enter my referral code ${Provider.of<HomeProvider>(context,listen: false).currency}${byCoinProvider.referAndEarnApiModel.signupcredit} & Enjoy your day !!!'.tr,
                          //     linkUrl: Platform.isAndroid
                          //         ? 'https://play.google.com/store/apps/details?id=$packageName'
                          //         : Platform.isIOS
                          //         ? 'https://play.google.com/store/apps/details?id=$packageName'
                          //         : "",
                          //     chooserTitle: '$appName');
                          print("!!!!!.+_.-.-._+.!!!!!" + appName.toString());
                          print("!!!!!.+_.-.-._+.!!!!!" + packageName.toString());

                          final String text =
                              'Hey! Now use our app to share with your family or friends. '
                              'User will get wallet amount on your 1st successful transaction. '
                              'Enter my referral code ${Provider.of<HomeProvider>(context,listen: false).currency}${byCoinProvider.referAndEarnApiModel.signupcredit} & Enjoy your shopping !!!';

                          final String linkUrl = 'https://play.google.com/store/apps/details?id=$packageName';

                          await Share.share(
                            '$text\n$linkUrl',
                            subject: appName,
                          );
                        },
                        style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(AppColors.appColor),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)))),
                        child:  Text(AppLocalizations.of(context)?.translate("Refer a Friend") ?? "Refer a Friend",style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          )
        ],
      )
          : Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
    );
  }
}
