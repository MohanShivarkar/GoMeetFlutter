// ignore_for_file: deprecated_member_use, avoid_print

import 'package:dating/by_coin_screen/coin_history.dart';
import 'package:dating/core/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Logic/cubits/Home_cubit/home_cubit.dart';
import '../Logic/cubits/Home_cubit/homestate.dart';
import '../Logic/cubits/premium_cubit/premium_bloc.dart';
import '../Logic/cubits/premium_cubit/premium_state.dart';
import '../Logic/paymentGateway/razorpayy.dart';
import '../core/config.dart';
import '../language/localization/app_localization.dart';
import '../payment/common_webview.dart';
import '../payment/inputformater.dart';
import '../payment/paymentcard.dart';
import '../payment/paypal_screen.dart';
import '../presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import '../presentation/screens/other/premium/premium_provider.dart';
import '../presentation/widgets/main_button.dart';
import '../wallete_code/wallet_provider.dart';
import 'coin_provider.dart';

String secretkey = "";
int isPayment = -1;
List<String> payType = ["UPI", "BANK Transfer", "Paypal"];

class ByCoiin extends StatefulWidget {
  const ByCoiin({super.key});

  @override
  State<ByCoiin> createState() => _ByCoiinState();
}

class _ByCoiinState extends State<ByCoiin> {

  late ByCoinProvider byCoinProvider;
  late PremiumProvider premiumProvider;
  late PremiumBloc premiumBloc;
  late HomeProvider homeProvider;
  late WalleteProvider walleteProvider;


  List text = [
  "Coin can be used for sending gifts only.",
  "Coins don’t have any expiry date.",
  "Coins can be used with all payment modes.",
  "Coins are credited to your Coin balance only.",
  "Coins can be withdrawn with the described method only.",
  "Coins cannot be transferred to any users.",
  ];


  @override
  void initState() {
    super.initState();

    byCoinProvider = Provider.of<ByCoinProvider>(context,listen: false);
    walleteProvider = Provider.of<WalleteProvider>(context,listen: false);
    byCoinProvider.ListPackageApi(context);
    byCoinProvider.coinreportApi(context);
    walleteProvider.walletreportApi(context: context);
    _razorPayClass.initiateRazorPay(
      handlePaymentError: handlePaymentError,
      handleExternalWallet: handleExternalWallet,
      handlePaymentSuccess: handlePaymentSuccess,
    );
    BlocProvider.of<PremiumBloc>(context,listen: false).planDataApi(context).then((value) {
      BlocProvider.of<PremiumBloc>(context,listen: false).paymentGateway(context).then((value1) {

        BlocProvider.of<PremiumBloc>(context).completeApi(value.planData!, value1.paymentdata!);
      });
    });

    if(isPayment!=-1){
      print("Payment Respons:---");
    }else{
      print("Payment Respons:-ELSE--");

    }

  }



  final RazorPayClass _razorPayClass = RazorPayClass();


  void handlePaymentSuccess(PaymentSuccessResponse response) {
    switchValue ?
    byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "$walletValue").then((value) {
      byCoinProvider.coinreportApi(context);
    },) :
    byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
      byCoinProvider.coinreportApi(context);
    },);

  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: ${response.code} - ${response.message!}", toastLength: Toast.LENGTH_SHORT);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: ${response.walletName!}", toastLength: Toast.LENGTH_SHORT);
  }

  String select = '';
  String ammount = '';
  double mainpayment = 0.0;
  bool switchValue = false;
  double walletMain = 0;
  double walletValue = 0;

  String coinamount = "";

  void navigatebackfunction(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    byCoinProvider = Provider.of<ByCoinProvider>(context);
    premiumProvider = Provider.of<PremiumProvider>(context);
    premiumBloc = Provider.of<PremiumBloc>(context);
    homeProvider = Provider.of<HomeProvider>(context);
    walleteProvider = Provider.of<WalleteProvider>(context);
    return Container(
      color: AppColors.appColor,
      child: SafeArea(
        // top: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.appColor,
            leadingWidth: 35,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  "assets/icons/BackIcon.svg",
                  height: 10,
                  width: 10,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            centerTitle: true,
            title: Text(AppLocalizations.of(context)?.translate("Coin") ?? "Coin",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18,color: Colors.white)),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CoinHistory(),));
                },
                child: Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(AppLocalizations.of(context)?.translate("History") ?? "History",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontSize: 12))),
                ),
              ),
              const SizedBox(width: 10,)
            ],
          ),
          body: BlocBuilder<PremiumBloc,PremiumState>(
              builder: (context, state)  {
                if(state is PremiumComplete){
                  return BlocBuilder<HomePageCubit,HomePageStates>(builder: (context, state1) {
                    if(state1 is HomeCompleteState){
                      return

                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: 250,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                                border: Border.all(color: Colors.white),
                                                borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              children: [
                                                const Spacer(),
                                                Text(AppLocalizations.of(context)?.translate("Your coin") ?? "Your coin",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18,color: Colors.white)),
                                                const SizedBox(height: 10,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(byCoinProvider.coinReportApiModel.coin,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 30,color: Colors.white)),
                                                    const SizedBox(width: 5,),
                                                    SvgPicture.asset("assets/icons/finalcoiniconwhite.svg",height: 30,),
                                                  ],
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 150),
                                    child: Container(
                                      height: 220,
                                      margin: const EdgeInsets.only(right: 10,left: 10),
                                      width: MediaQuery.of(context).size.width * 0.95,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(25)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)?.translate("Select coin package") ?? "Select coin package",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15)),
                                            byCoinProvider.isLoading ? SizedBox(
                                              height: 100,
                                              child: ListView.separated(
                                                  separatorBuilder: (context, index) {
                                                    return const SizedBox(height: 0);
                                                  },
                                                  shrinkWrap: true,
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: byCoinProvider.listPackageApiModel.packlist.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          select = byCoinProvider.listPackageApiModel.packlist[index].id;
                                                          ammount = byCoinProvider.listPackageApiModel.packlist[index].amt;
                                                          mainpayment = double.parse(ammount);
                                                          print("++++++:---  $ammount");
                                                        });
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(6),
                                                        child: Stack(
                                                          clipBehavior: Clip.none,
                                                          children: [

                                                            Container(
                                                              width: 110,
                                                              decoration: BoxDecoration(
                                                                border: Border.all(color: select == byCoinProvider.listPackageApiModel.packlist[index].id ?  AppColors.appColor : Colors.grey.withOpacity(0.4)
                                                                ),
                                                                borderRadius: BorderRadius.circular(20),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(15),
                                                                child: Column(
                                                                  children: [
                                                                    const Spacer(),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 15,),
                                                                        const SizedBox(width: 5,),
                                                                        Text(byCoinProvider.listPackageApiModel.packlist[index].coin,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15,fontWeight: FontWeight.bold)),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(height: 10,),
                                                                    Text("${Provider.of<HomeProvider>(context,listen: false).currency} ${byCoinProvider.listPackageApiModel.packlist[index].amt}",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                                                                    const Spacer(),

                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            select == byCoinProvider.listPackageApiModel.packlist[index].id ? Positioned(
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
                                                            ) : const SizedBox()
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ) : Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
                                            const SizedBox(height: 10,),
                                            Row(
                                              children: [

                                                select == "" ? Expanded(
                                                  flex: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Please Select Coin Package") ?? "Please Select Coin Package");
                                                    },
                                                    child: Container(
                                                      // height: 50,
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.appColor,
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(child: Image(image: AssetImage("assets/Image/arrow-up.png"),height: 18,width: 18,),),
                                                          ),
                                                          const SizedBox(width: 10,),
                                                          Text(AppLocalizations.of(context)?.translate("Top-up") ?? "Top-up",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )  : Expanded(
                                                  flex: 5,
                                                  child: InkWell(
                                                    onTap: () {



                                                      setState(() {
                                                        mainpayment = double.parse(ammount);
                                                        walletMain = double.parse(walleteProvider.walletReportApiModel.wallet);

                                                        switchValue = false;
                                                        showModalBottomSheet(
                                                          context: context,
                                                          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 200),
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
                                                                        mainpayment <= 0.0 ? Expanded(child: MainButton(
                                                                          bgColor: AppColors.appColor,
                                                                          title: AppLocalizations.of(context)
                                                                              ?.translate("Wallet Pay") ??
                                                                              "Wallet Pay", onTap: () {

                                                                          byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "$walletValue").then((value) {
                                                                            byCoinProvider.coinreportApi(context);
                                                                          },);

                                                                        },
                                                                        )) : Expanded(child: MainButton(
                                                                          bgColor: AppColors.appColor,
                                                                          title: AppLocalizations.of(context)
                                                                              ?.translate("Continue") ??
                                                                              "Continue", onTap: () {


                                                                          if (premiumProvider.selectedPayment == 1) {
                                                                            _razorPayClass.openCheckout(
                                                                              name: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString(),
                                                                              number: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString(),
                                                                              amount: mainpayment.toString(),
                                                                              key: premiumProvider.selectedPaymentattributes.toString(),
                                                                            );
                                                                            Navigator.pop(context);
                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 3) {
                                                                            List ids = premiumProvider.selectedPaymentattributes.toString().split(",");
                                                                            print('++++++++++ids:------ $ids');
                                                                            paypalPayment(
                                                                              urlStatus: ids[2],
                                                                              amt: mainpayment.toString(),
                                                                              clientId: ids[0],
                                                                              secretKey: ids[1],
                                                                              function: (e) {
                                                                                print("payment function done 1");
                                                                                  byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                                    print("payment function done 2");
                                                                                    byCoinProvider.coinreportApi(context);
                                                                                  },);
                                                                                print("payment function done 3");
                                                                              },
                                                                              context: context
                                                                            );
                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 4) {
                                                                            Navigator.pop(context);
                                                                            stripePayment();
                                                                          }



                                                                          else if (premiumProvider.selectedPayment == 6) {

                                                                            byCoinProvider.paystackApi(amount: mainpayment.toString(),email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString(),context: context).then((value) {


                                                                              Navigator.push(context, MaterialPageRoute(
                                                                                builder: (context) => PaymentWebVIew(
                                                                                  initialUrl: "${value}",
                                                                                  navigationDelegate: (request) async {
                                                                                    final uri = Uri.parse(request.url);
                                                                                    print("Navigating to URL: ${request.url}");
                                                                                    print("Parsed URI: $uri");

                                                                                    // Check the status parameter instead of Result
                                                                                    final status = uri.queryParameters["status"];
                                                                                    print("Hello Status:---- $status");

                                                                                    if (status == null) {
                                                                                      print("No status parameter found.");
                                                                                    } else {
                                                                                      print("Status parameter: $status");
                                                                                      if (status == "success") {
                                                                                        print("Purchase successful.");
                                                                                        await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                        await byCoinProvider.coinreportApi(context);
                                                                                        return NavigationDecision.prevent;
                                                                                      } else {
                                                                                        print("Purchase failed with status: $status.");
                                                                                        Navigator.pop(context);
                                                                                        Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                        return NavigationDecision.prevent;
                                                                                      }
                                                                                    }
                                                                                    return NavigationDecision.navigate;
                                                                                  },
                                                                                ),
                                                                              ));


                                                                            },);



                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 7) {
                                                                            print("========:---  ${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email}");

                                                                            // https://gomeet.cscodetech.cloud/flutterwave/index.php?amt=500&email=alicesmith@gmail.com

                                                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => Flutterwave(totalAmount: mainpayment.toString(), email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email,),)).then((otid) {
                                                                            //   if (otid != null) {
                                                                            //     byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                            //       byCoinProvider.coinreportApi(context);
                                                                            //     },);
                                                                            //     Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment Successfully") ?? "Payment Successfully",timeInSecForIosWeb: 4);
                                                                            //   } else {
                                                                            //     Navigator.pop(context);
                                                                            //   }
                                                                            // });

                                                                            // 8686868686


                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}flutterwave/index.php?amt=${mainpayment.toString()}&email=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["status"];
                                                                                  final transactionn_id = uri.queryParameters["transaction_id"];
                                                                                  print("Hello Status:---- $status");
                                                                                  print("Hello Status:---- $transactionn_id");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "successful") {
                                                                                      print("Purchase successful.");
                                                                                      // Navigator.pop(context);
                                                                                      // await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      // await byCoinProvider.coinreportApi(context);
                                                                                      byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                                        byCoinProvider.coinreportApi(context);
                                                                                      },);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));



                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 8) {

                                                                            // Navigator.push(context,
                                                                            //     MaterialPageRoute(builder: (context) => PayTmPayment(totalAmount: mainpayment.toString(), uid: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()),)).then((otid) {
                                                                            //   if (otid != null) {
                                                                            //     byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                            //       byCoinProvider.coinreportApi(context);
                                                                            //     },);
                                                                            //     Fluttertoast.showToast(
                                                                            //         msg: AppLocalizations.of(
                                                                            //             context)?.translate(
                                                                            //             "Payment Successfully") ??
                                                                            //             "Payment Successfully",
                                                                            //         timeInSecForIosWeb: 4);
                                                                            //   } else {
                                                                            //     Navigator.pop(context);
                                                                            //   }
                                                                            // });




                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}paytm/index.php?amt=${mainpayment.toString()}&uid=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["status"];
                                                                                  final transaction_idddd = uri.queryParameters["transaction_id"];
                                                                                  print("Hello Status:---- $status");
                                                                                  print("Hello Status:---- $transaction_idddd");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "successful") {
                                                                                      print("Purchase successful.");
                                                                                      // Navigator.pop(context);
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));


                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 10) {


                                                                            // Navigator.push(context, MaterialPageRoute(
                                                                            //       builder: (context) =>
                                                                            //           SenangPay(email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString(),
                                                                            //               totalAmount: mainpayment.toString(), name: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString(),
                                                                            //               phon: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString()),)
                                                                            // )
                                                                            //     .then((otid) {
                                                                            //   if (otid != null) {
                                                                            //     byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                            //       byCoinProvider.coinreportApi(context);
                                                                            //     },);
                                                                            //   } else {
                                                                            //     Navigator.pop(context);
                                                                            //   }
                                                                            // });

                                                                          // https://gomeet.cscodetech.cloud/result.php?detail=Movers&amount=500.0&order_id=501592598&name=propi&email=propi@gmail.com&phone=8686868686
                                                                          // 14
                                                                          // https://gomeet.cscodetech.cloud/detail=Movers&amount=500.0&order_id=234205222&name=propi&email=propi@gmail.com&phone=8686868686

                                                                            final notificationId = UniqueKey().hashCode;

                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}result.php?detail=Movers&amount=${mainpayment.toString()}&order_id=$notificationId&name=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString()}&email=${ Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()}&phone=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["msg"];
                                                                                  final transactionn_id = uri.queryParameters["transaction_id"];
                                                                                  print("Hello Status:---- $status");
                                                                                  print("Hello Status:---- $transactionn_id");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "Payment_was_successful") {
                                                                                      print("Purchase successful.");
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));



                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 12) {


                                                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => PayFast(totalAmount: mainpayment.toString(),),)).then((otid) {
                                                                            //
                                                                            //   if (otid != null) {
                                                                            //     byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                            //       byCoinProvider.coinreportApi(context);
                                                                            //     },);
                                                                            //     Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment Successfully") ?? "Payment Successfully", timeInSecForIosWeb: 4);
                                                                            //   } else {
                                                                            //     Navigator.pop(context);
                                                                            //   }
                                                                            // });

                                                                            // no tensaction id


                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}Payfast/index.php?amt=${mainpayment.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["status"];
                                                                                  final payment_iddd = uri.queryParameters["payment_id"];
                                                                                  print("Hello Status:---- $status");
                                                                                  print("Hello Status:---- $payment_iddd");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "success") {
                                                                                      print("Purchase successful.");
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));


                                                                          }



                                                                          else if (premiumProvider.selectedPayment == 13) {


                                                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => MidTranse(
                                                                            //   name: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString(),
                                                                            //   email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString(),
                                                                            //   phone: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString(),
                                                                            //   amount: mainpayment.toString(),
                                                                            // ),)).then((otid) {
                                                                            //
                                                                            //   if (otid != null) {
                                                                            //     byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                                                                            //       byCoinProvider.coinreportApi(context);
                                                                            //     },);
                                                                            //     Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment Successfully") ?? "Payment Successfully", timeInSecForIosWeb: 4);
                                                                            //   } else {
                                                                            //     Navigator.pop(context);
                                                                            //   }
                                                                            // });

                                                                            // No teansaction id

                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}Midtrans/index.php?name=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString()}&email=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()}&phone=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString()}&amt=${mainpayment.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["status_code"];
                                                                                  final order_iddd = uri.queryParameters["order_id"];
                                                                                  print("Hello Status:---- $status");
                                                                                  print("Hello Status:---- $order_iddd");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "200") {
                                                                                      print("Purchase successful.");
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));



                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 14) {

                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}2checkout/index.php?amt=${mainpayment.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["Result"];
                                                                                  print("Hello Status:---- $status");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "success") {
                                                                                      print("Purchase successful.");
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));



                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 15) {

                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}Khalti/index.php?amt=${mainpayment.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["status"];
                                                                                  final transactionn_id = uri.queryParameters["transaction_id"];
                                                                                  print("Hello Status:---- $status");
                                                                                  print("Hello Status:---- $transactionn_id");
                                                                                  // https://gomeet.cscodetech.cloud/Khalti/return.php?pidx=CWKP6ifRqssmzjKVdY9iX8&transaction_id=DGobCnm38qS4z5oPMDdawW&tidx=DGobCnm38qS4z5oPMDdawW&amount=50000&total_amount=50000&mobile=98XXXXX005&status=Completed&purchase_order_id=Order01&purchase_order_name=test

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "Completed") {
                                                                                      print("Purchase successful.");
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));



                                                                          }
                                                                          else if (premiumProvider.selectedPayment == 16) {

                                                                            Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context) => PaymentWebVIew(
                                                                                initialUrl: "${Config.baseUrl}merpago/index.php?amt=${mainpayment.toString()}",
                                                                                navigationDelegate: (request) async {
                                                                                  final uri = Uri.parse(request.url);
                                                                                  print("Navigating to URL: ${request.url}");
                                                                                  print("Parsed URI: $uri");

                                                                                  // Check the status parameter instead of Result
                                                                                  final status = uri.queryParameters["Result"];
                                                                                  print("Hello Status:---- $status");

                                                                                  if (status == null) {
                                                                                    print("No status parameter found.");
                                                                                  } else {
                                                                                    print("Status parameter: $status");
                                                                                    if (status == "success") {
                                                                                      print("Purchase successful.");
                                                                                      await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                                                      await byCoinProvider.coinreportApi(context);
                                                                                      return NavigationDecision.prevent;
                                                                                    } else {
                                                                                      print("Purchase failed with status: $status.");
                                                                                      Navigator.pop(context);
                                                                                      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                                                      return NavigationDecision.prevent;
                                                                                    }
                                                                                  }
                                                                                  return NavigationDecision.navigate;
                                                                                },
                                                                              ),
                                                                            ));



                                                                          }
                                                                          else {
                                                                            Navigator.pop(context);
                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.translate("Not Valid") ?? "Not Valid"), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),),);
                                                                          }
                                                                        },
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  body: Container(
                                                                    decoration: BoxDecoration(
                                                                      color: Theme.of(context).scaffoldBackgroundColor,
                                                                      borderRadius: const BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15)),
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisSize: MainAxisSize.min,
                                                                        children: <Widget>[
                                                                          const SizedBox(height: 10,),

                                                                          Padding(
                                                                            padding: const EdgeInsets.only(left: 6,right: 6),
                                                                            child: Text(AppLocalizations.of(context)?.translate("Select Payment Method") ?? "Select Payment Method",style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 15)),
                                                                          ),
                                                                          const SizedBox(height: 20,),
                                                                          walleteProvider.walletReportApiModel.wallet == "0" ? const SizedBox() :  Row(
                                                                            children: [
                                                                              SvgPicture.asset("assets/icons/wallet.svg",height: 30,color: AppColors.appColor,),
                                                                              const SizedBox(width: 10,),
                                                                              switchValue ?  Text("My Wallet (${Provider.of<HomeProvider>(context,listen: false).currency}$walletMain)") : Text("My Wallet (${Provider.of<HomeProvider>(context,listen: false).currency}${walleteProvider.walletReportApiModel.wallet})"),
                                                                              const Spacer(),
                                                                              Transform.scale(
                                                                                scale: 0.8,
                                                                                child: CupertinoSwitch(
                                                                                  value: switchValue,
                                                                                  activeColor: AppColors.appColor,
                                                                                  onChanged: (bool value) {

                                                                                    setState(() {
                                                                                      switchValue = value;

                                                                                      print("+++ walletMain +++:-($walletValue)");
                                                                                      print("+++ mainpayment +++:-($mainpayment)");

                                                                                      if(switchValue) {
                                                                                        print("hello if$walletMain");
                                                                                        if (mainpayment > walletMain) {
                                                                                          walletValue = walletMain;
                                                                                          mainpayment -= walletValue;
                                                                                          walletMain = 0;
                                                                                        } else {
                                                                                          walletValue = mainpayment;
                                                                                          mainpayment -= mainpayment;
                                                                                          double good = double.parse(walleteProvider.walletReportApiModel.wallet);
                                                                                          walletMain = (good - walletValue);
                                                                                          print("++++++ good +++++ : --   $walletMain");
                                                                                        }
                                                                                      }else{
                                                                                        print("hello else");
                                                                                        walletValue = 0;
                                                                                        walletMain = double.parse(walleteProvider.walletReportApiModel.wallet);
                                                                                        mainpayment = double.parse(ammount);
                                                                                      }

                                                                                    });

                                                                                  },
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),

                                                                          Consumer<PremiumProvider>(
                                                                            builder: (BuildContext context, value,
                                                                                Widget? child) {
                                                                              return Expanded(
                                                                                child: ListView.separated(
                                                                                    padding: const EdgeInsets.only(top: 10.0, bottom: 50, right: 10, left: 10),
                                                                                    shrinkWrap: true,
                                                                                    itemBuilder: (context, index) {
                                                                                      return mainpayment <= 0 ? Container(
                                                                                        padding: const EdgeInsets
                                                                                            .all(12),
                                                                                        decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius
                                                                                                .circular(12),
                                                                                            border: Border.all(
                                                                                                color:  Theme.of(context).dividerTheme.color!)
                                                                                        ),
                                                                                        child: Row(
                                                                                          children: [
                                                                                            Container(
                                                                                                height: 60,
                                                                                                width: 60,
                                                                                                decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                                    border: Border.all(color: Theme.of(context).dividerTheme.color!)
                                                                                                ),
                                                                                                child: Image.network("${Config.baseUrl}${state.payment[index].img}")),
                                                                                            const SizedBox(width: 10,),
                                                                                            Expanded(
                                                                                              flex: 10,
                                                                                              child: Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Text(state.payment[index].title.toString(), style: Theme.of(context).textTheme.bodyMedium!),
                                                                                                  const SizedBox(
                                                                                                    height: 2,),
                                                                                                  Text(state.payment[index].subtitle.toString(), style: Theme.of(context).textTheme.bodySmall!),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            const Spacer(flex: 1),
                                                                                            Radio(
                                                                                              activeColor: AppColors.appColor,
                                                                                              value:  false,
                                                                                              groupValue: true,
                                                                                              onChanged: (value1) {
                                                                                              },
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ) :  InkWell(
                                                                                        onTap: () {
                                                                                          value.updateSelectPayment(int.parse(state.payment[index].id.toString()));
                                                                                          value.updateAttributes(state.payment[index].attributes.toString());
                                                                                          value.updatePaymentName(state.payment[index].title.toString());
                                                                                          secretkey = state.payment[index].attributes.toString().split(",").last;
                                                                                          print("++++:--  ${secretkey}");
                                                                                        },
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets
                                                                                              .all(12),
                                                                                          decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius
                                                                                                  .circular(12),
                                                                                              border: Border.all(
                                                                                                  color: value.selectedPayment == int.parse(state.payment[index].id.toString()) ? AppColors.appColor : Theme.of(context).dividerTheme.color!)
                                                                                          ),
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                  height: 60,
                                                                                                  width: 60,
                                                                                                  decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.circular(12),
                                                                                                      border: Border.all(color: Theme.of(context).dividerTheme.color!)
                                                                                                  ),
                                                                                                  child: Image.network("${Config.baseUrl}${state.payment[index].img}")
                                                                                              ),
                                                                                              const SizedBox(width: 10,),
                                                                                              Expanded(
                                                                                                flex: 10,
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text(state.payment[index].title.toString(), style: Theme.of(context).textTheme.bodyMedium!),
                                                                                                    const SizedBox(
                                                                                                      height: 2,),
                                                                                                    Text(state.payment[index].subtitle.toString(), style: Theme.of(context).textTheme.bodySmall!),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                              const Spacer(flex: 1),
                                                                                              Radio(
                                                                                                activeColor: AppColors.appColor,
                                                                                                value: value.selectedPayment == int.parse(state.payment[index].id.toString()) ? true : false,
                                                                                                groupValue: true,
                                                                                                onChanged: (value1) {
                                                                                                  value.updateSelectPayment(int.parse(state.payment[index].id.toString()));
                                                                                                  value.updateAttributes(state.payment[index].attributes.toString());
                                                                                                  value.updatePaymentName(state.payment[index].title.toString());
                                                                                                },
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                    separatorBuilder: (context,
                                                                                        index) {
                                                                                      return const SizedBox(
                                                                                        height: 10,);
                                                                                    },
                                                                                    itemCount: state.payment.length),
                                                                              );
                                                                            },
                                                                          ),


                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },);
                                                          },);

                                                      });



                                                    },
                                                    child: Container(
                                                      // height: 50,
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.appColor,
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(child: Image(image: AssetImage("assets/Image/arrow-up.png"),height: 18,width: 18,),),
                                                          ),
                                                          const SizedBox(width: 10,),
                                                          Text(AppLocalizations.of(context)?.translate("Top-up") ?? "Top-up",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10,),
                                                byCoinProvider.coinReportApiModel.coin == "0" ? Expanded(
                                                  flex: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Fluttertoast.showToast(msg: "Min ${byCoinProvider.coinReportApiModel.coin_limit} coins required");
                                                    },
                                                    child: Container(
                                                      // height: 50,
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color: AppColors.appColor,
                                                          borderRadius: BorderRadius.circular(30)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(child: Image(image: AssetImage("assets/Image/arrow-down.png"),height: 18,width: 18,),),
                                                          ),
                                                          const SizedBox(width: 10,),
                                                          Text(AppLocalizations.of(context)?.translate("Withdraw") ?? "Withdraw",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ) : Expanded(
                                                  flex: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      amount.text = "";
                                                      accountNumber.text = "";
                                                      bankName.text = "";
                                                      accountHolderName.text = "";
                                                      ifscCode.text = "";
                                                      upi.text = "";
                                                      emailId.text = "";
                                                      requestSheet();
                                                      coinamount = byCoinProvider.coinReportApiModel.coin;
                                                      print("++++:--  $coinamount");
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                          color: AppColors.appColor,
                                                          borderRadius: BorderRadius.circular(30)
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(child: Image(image: AssetImage("assets/Image/arrow-down.png"),height: 18,width: 18,),),
                                                          ),
                                                          const SizedBox(width: 10,),
                                                          Text(AppLocalizations.of(context)?.translate("Withdraw") ?? "Withdraw",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),


                              byCoinProvider.isLoading ? SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15,right: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      const SizedBox(height: 20,),
                                      Text(AppLocalizations.of(context)?.translate("Coin buying & Info") ?? "Coin buying & Info",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20,fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 15,),
                                      ListView.separated(
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: 15);
                                        },
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: text.length,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              const Image(image: AssetImage("assets/icons/afinal.png"),height: 25,),
                                              const SizedBox(width: 10),
                                              Flexible(child: Text(AppLocalizations.of(context)?.translate("${text[index]}") ?? "${text[index]}",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 17,color: Colors.grey),maxLines: 2)),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 15,),
                                      Row(
                                        children: [
                                          const Image(image: AssetImage("assets/icons/afinal.png"),height: 25,),
                                          const SizedBox(width: 10,),
                                          Flexible(child: Text("You need a minimum of ${byCoinProvider.coinReportApiModel.coin_limit} coins to make a withdrawal.",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 17,color: Colors.grey),maxLines: 2))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ) : Center(child: CircularProgressIndicator(color: AppColors.appColor,)),
                              const SizedBox(height: 10,),
                            ],
                          ),
                        );



                    }else{
                      return Center(child: CircularProgressIndicator(color: AppColors.appColor,));
                    }
                  }
                  );
                }else{
                  return Center(child: CircularProgressIndicator(color: AppColors.appColor,));
                }
              }
          ),
        ),
      ),
    );
  }






  // Strip code


  final _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  final _paymentCard = PaymentCardCreated();
  var _autoValidateMode = AutovalidateMode.disabled;

  final _card = PaymentCardCreated();


  stripePayment() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Ink(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height / 45),
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 85,
                            width: MediaQuery.of(context).size.width / 5,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.4),
                                borderRadius: const BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                              Text(AppLocalizations.of(context)?.translate("Add Your payment information") ?? "Add Your payment information",
                                  style:  TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5)),
                              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                              Form(
                                key: _formKey,
                                autovalidateMode: _autoValidateMode,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      style:  TextStyle(color: AppColors.black),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(19),
                                        CardNumberInputFormatter()
                                      ],
                                      controller: numberController,
                                      onSaved: (String? value) {
                                        _paymentCard.number =
                                            CardUtils.getCleanedNumber(value!);

                                        CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(
                                            _paymentCard.number.toString());
                                        setState(() {
                                          _card.name = cardType.toString();
                                          _paymentCard.type = cardType;
                                        });
                                      },
                                      onChanged: (val) {
                                        CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(val);
                                        setState(() {
                                          _card.name = cardType.toString();
                                          _paymentCard.type = cardType;
                                        });
                                      },
                                      validator: CardUtils.validateCardNum,
                                      decoration: InputDecoration(
                                        prefixIcon: SizedBox(
                                          height: 10,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 6,
                                            ),
                                            child: CardUtils.getCardIcon(_paymentCard.type,),
                                          ),
                                        ),
                                        focusedErrorBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        errorBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        enabledBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        focusedBorder:  OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.4),
                                          ),
                                        ),
                                        hintText:
                                        AppLocalizations.of(context)?.translate("What number is written on card?") ?? "What number is written on card?",
                                        hintStyle: const TextStyle(color: Colors.grey),
                                        labelStyle: const TextStyle(color: Colors.grey),
                                        labelText: AppLocalizations.of(context)?.translate("Number") ?? "Number",
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: TextFormField(
                                            style:  TextStyle(color: AppColors.black),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                            ],
                                            decoration: InputDecoration(
                                                prefixIcon: const SizedBox(
                                                  height: 10,
                                                  child: Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 14),
                                                    child: Icon(Icons.credit_card,color: Color(0xff7D2AFF)),
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.4),
                                                  ),
                                                ),
                                                errorBorder:  OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.4),
                                                  ),
                                                ),
                                                enabledBorder:  OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.withOpacity(0.4),
                                                  ),
                                                ),
                                                focusedBorder:  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                        Colors.grey.withOpacity(0.4))),
                                                hintText: AppLocalizations.of(context)?.translate("Number behind the card") ?? "Number behind the card",
                                                hintStyle:
                                                const TextStyle(color: Colors.grey),
                                                labelStyle:
                                                const TextStyle(color: Colors.grey),
                                                labelText: AppLocalizations.of(context)?.translate("CVV") ?? "CVV"),
                                            validator: CardUtils.validateCVV,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              _paymentCard.cvv = int.parse(value!);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                                        Flexible(
                                          flex: 4,
                                          child: TextFormField(
                                            style:  TextStyle(color: AppColors.black),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(4),
                                              CardMonthInputFormatter()
                                            ],
                                            decoration: InputDecoration(
                                              prefixIcon: const SizedBox(
                                                height: 10,
                                                child: Padding(
                                                  padding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 14),
                                                  child: Icon(Icons.calendar_month,color: Color(0xff7D2AFF)),
                                                ),
                                              ),
                                              errorBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              enabledBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              focusedBorder:  OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.4),
                                                ),
                                              ),
                                              hintText: AppLocalizations.of(context)?.translate("MM/YY") ?? "MM/YY",
                                              hintStyle:  const TextStyle(color: Colors.grey),
                                              labelStyle: const TextStyle(color: Colors.grey),
                                              labelText: AppLocalizations.of(context)?.translate("Expiry Date") ?? "Expiry Date",
                                            ),
                                            validator: CardUtils.validateDate,
                                            keyboardType: TextInputType.number,
                                            onSaved: (value) {
                                              List<int> expiryDate =
                                              CardUtils.getExpiryDate(value!);
                                              _paymentCard.month = expiryDate[0];
                                              _paymentCard.year = expiryDate[1];
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.055),
                                    Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: CupertinoButton(
                                          onPressed: () {
                                            _validateInputs();
                                          },
                                          color: const Color(0xff7D2AFF),
                                          child: Text(
                                            "Pay ${mainpayment.toString()}",
                                            style:  const TextStyle(fontSize: 17.0,color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.065),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });

      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Please fix the errors in red before submitting.") ?? "Please fix the errors in red before submitting.",timeInSecForIosWeb: 4);
    }
    else {
      var username = Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.name.toString();

      var email = Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.email.toString();
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount = mainpayment.toString();
      form.save();

      // print("++++++++++:--- $_paymentCard");
      // Navigator.push(context, MaterialPageRoute(builder: (context) => StripePaymentWeb(paymentCard: _paymentCard),)).then((otid) {
      //
      //   if (otid != null) {
      //     byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
      //       byCoinProvider.coinreportApi(context);
      //     },);
      //   }
      //
      // });

      // https://gomeet.cscodetech.cloud/stripe/index.php?name=propi&email=propi@gmail.com&cardno=4242424242424242&cvc=123&amt=500&mm=1&yyyy=25

      print("........:--- ${_paymentCard.name}");
      print("........:--- ${_paymentCard.email}");
      print("........:--- ${_paymentCard.number}");
      print("........:--- ${_paymentCard.cvv}");
      print("........:--- ${_paymentCard.amount}");
      print("........:--- ${_paymentCard.month}");
      print("........:--- ${_paymentCard.year}");



      Navigator.push(context, MaterialPageRoute(
        builder: (context) => PaymentWebVIew(
          initialUrl: "${Config.baseUrl}stripe/index.php?name=${_paymentCard.name}&email=${_paymentCard.email}&cardno=${_paymentCard.number}&cvc=${_paymentCard.cvv}&amt=${_paymentCard.amount}&mm=${_paymentCard.month}&yyyy=${_paymentCard.year}",
          navigationDelegate: (request) async {
            final uri = Uri.parse(request.url);
            print("Navigating to URL: ${request.url}");
            print("Parsed URI: $uri");

            // Check the status parameter instead of Result
            final status = uri.queryParameters["status"];
            final transaction_iddd = uri.queryParameters["Transaction_id"];
            print("........:--- $status");
            print("........:--- $transaction_iddd");
            if (status == null) {
              print("No status parameter found.");
            } else {
              print("Status parameter: $status");
              if (status == "success") {
                print("Purchase successful.");
                byCoinProvider.packagepurchaseApi(packageid: select,context: context,wall_amt: "0").then((value) {
                  byCoinProvider.coinreportApi(context);
                },);
                return NavigationDecision.prevent;
              } else {
                print("Purchase failed with status: $status.");
                Navigator.pop(context);
                Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      ));


      // Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment card is valid") ?? "Payment card is valid",timeInSecForIosWeb: 4);
    }
  }




  // withdraw code


  textfield({String? type, labelText, prefixtext, suffix, Color? labelcolor, prefixcolor, floatingLabelColor, focusedBorderColor, TextDecoration? decoration, bool? readOnly, double? Width, int? max, TextEditingController? controller, TextInputType? textInputType, Function(String)? onChanged, String? Function(String?)? validator, Height}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10,right: 10),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: textInputType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLength: max,
        readOnly: readOnly ?? false,

        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
          hintText: labelText,
          hintStyle: const TextStyle(
              color: Colors.grey, fontFamily: "Gilroy Medium", fontSize: 16),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xff7D2AFF)),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  BorderSide(color: Colors.grey.withOpacity(0.4)),
          ),
          border: OutlineInputBorder(
            borderSide:  BorderSide(color: Colors.grey.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }



  TextEditingController amount = TextEditingController();
  TextEditingController upi = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController emailId = TextEditingController();

  String? selectType;

  double finaltotal = 0.0;


  Future<void> requestSheet() {
    return  showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 200),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Spacer(),
                          SvgPicture.asset("assets/icons/finalcoinicon.svg",height: 30,),
                          // const Image(image: AssetImage("assets/icons/coin.png"),height: 30,),
                          const SizedBox(width: 5,),
                          Text("1 coin = ${Provider.of<HomeProvider>(context,listen: false).currency}${byCoinProvider.coinReportApiModel.coin_amt}",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20)),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      textfield(
                        controller: amount,
                        labelText: "Number of coin",
                        textInputType: TextInputType.number,
                        onChanged: (p0) {

                          if(double.parse(coinamount) < double.parse(amount.text)){
                           setState((){
                             amount.clear();
                             Fluttertoast.showToast(msg: "Please enter your correct coin");
                           });
                          }
                          else{
                            setState((){
                              finaltotal = double.parse(amount.text) * double.parse(byCoinProvider.coinReportApiModel.coin_amt);
                            });
                          }


                          print("+++++:---  $finaltotal");
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            amount.text.isEmpty ? const SizedBox() :  Text("${Provider.of<HomeProvider>(context,listen: false).currency}$finaltotal",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(left: 15),
                        child: Text(
                          "Select Type",
                         style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        decoration: BoxDecoration(
                          // color: notifier.textColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.withOpacity(0.4)),
                        ),
                        child: DropdownButton(
                          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                          hint: const Text(
                            "Select Type",
                            style: TextStyle(color: Colors.grey),
                          ),
                          value: selectType,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items:
                          payType.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectType = value ?? "";
                            });
                          },
                        ),
                      ),
                      selectType == "UPI"
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "UPI",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          textfield(
                            controller: upi,
                            labelText: "UPI",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter UPI';
                              }
                              return null;
                            },
                          )
                        ],
                      )
                          : selectType == "BANK Transfer"
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Account Number",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          textfield(
                            controller: accountNumber,
                            labelText: "Account Number",
                            textInputType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Account Number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Bank Name",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          textfield(
                            controller: bankName,
                            labelText: "Bank Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Bank Name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Account Holder Name",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          textfield(
                            controller:
                            accountHolderName,
                            labelText: "Account Holder Name",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Account Holder Name'
                                    ;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "IFSC Code",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          textfield(
                            controller: ifscCode,
                            labelText: "IFSC Code",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter IFSC Code';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                          : selectType == "Paypal"
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              "Email ID",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          textfield(
                            controller: emailId,
                            labelText: "Email Id",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Paypal id';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 60)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(45))),backgroundColor: const MaterialStatePropertyAll(Colors.white)),
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel',style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(fixedSize: const MaterialStatePropertyAll(Size(120, 60)),elevation: const MaterialStatePropertyAll(0),shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(45))),backgroundColor:  MaterialStatePropertyAll(AppColors.appColor)),
                                onPressed: () => {


                                    if (_formKey.currentState?.validate() ?? false) {
                                      if (selectType != null) {
                                        if(double.parse(byCoinProvider.coinReportApiModel.coin_limit) > double.parse(amount.text)){
                                          Fluttertoast.showToast(msg: "Min ${byCoinProvider.coinReportApiModel.coin_limit} coins required")
                                        }else{
                                          byCoinProvider.requestwithdrewApi(context: context,coin: amount.text, r_type: "$selectType", acc_number: accountNumber.text, bank_name: bankName.text, acc_name: accountHolderName.text, ifsc_code: ifscCode.text, upi_id: upi.text, paypal_id: emailId.text).then((value) {
                                            byCoinProvider.coinreportApi(context);
                                          },),
                                          Navigator.pop(context),
                                        }
                                      } else {
                                        Fluttertoast.showToast(msg: 'Please Select Type',timeInSecForIosWeb: 4),
                                      }
                                    }





                                },
                                child: Text('Proceed', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },);
      },);
  }
}
