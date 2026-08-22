import 'package:dating/core/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/ui.dart';
import '../language/localization/app_localization.dart';
import '../presentation/widgets/other_widget.dart';
import 'coin_provider.dart';

class Coin_Withdraw_Screen extends StatefulWidget {
  const Coin_Withdraw_Screen({super.key});

  @override
  State<Coin_Withdraw_Screen> createState() => _Coin_Withdraw_ScreenState();
}

class _Coin_Withdraw_ScreenState extends State<Coin_Withdraw_Screen> {

  late ByCoinProvider byCoinProvider;

  @override
  void initState() {
    // TODO: implement initState
    byCoinProvider = Provider.of<ByCoinProvider>(context,listen: false);
    byCoinProvider.payoutlistApi(context);
    byCoinProvider.mygiftApi(context);
    super.initState();
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    byCoinProvider = Provider.of<ByCoinProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context)?.translate("My Gift") ?? "My Gift",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
        leading: const BackButtons(),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: byCoinProvider.giftloading ?  Padding(
        padding: const EdgeInsets.only(left: 10,right: 10,top: 0,bottom: 15),
        child:
        byCoinProvider.myGiftListApiModel.giflist.isEmpty ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Text(AppLocalizations.of(context)?.translate("No Gifts Available") ?? "No Gifts Available",style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 15),overflow: TextOverflow.ellipsis,),),
            Center(child: Text(AppLocalizations.of(context)?.translate("There are no gifts available in your account.") ?? "There are no gifts available in your account.",style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 15),overflow: TextOverflow.ellipsis,),),
          ],
        ) :
        SingleChildScrollView(
          child:  Column(
            children: [
             const SizedBox(height: 10,),

              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                clipBehavior: Clip.none,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: byCoinProvider.myGiftListApiModel.giflist.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 13,
                  mainAxisExtent: 150
              ), itemBuilder: (context, a) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 150,
                        width: 115,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.withOpacity(0.4))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image(image: NetworkImage("${Config.baseUrl}${byCoinProvider.myGiftListApiModel.giflist[a].giftImg}"),height: 50,),
                            const SizedBox(height: 5,),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(image: NetworkImage("${Config.baseUrl}${byCoinProvider.myGiftListApiModel.giflist[a].img}"),fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Text(byCoinProvider.myGiftListApiModel.giflist[a].name,style: Theme.of(context).textTheme.bodySmall!.copyWith(),overflow: TextOverflow.ellipsis,),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -5,
                        right: 0,
                        child: Container(
                          height: 22,
                          width: 22,
                          decoration: BoxDecoration(
                              color: AppColors.appColor,
                              shape: BoxShape.circle
                          ),
                          child: const Center(child: Text("1",style: TextStyle(color: Colors.white,fontSize: 12),)),
                        ),
                      ),
                    ],
                  );
              },),

            ],
          ),
        ),
      ) : Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
    );
  }
}
