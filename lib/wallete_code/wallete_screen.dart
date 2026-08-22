import 'package:dating/by_coin_screen/refer_and_earn_screen.dart';
import 'package:dating/core/ui.dart';
import 'package:dating/wallete_code/wallet_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Logic/cubits/Home_cubit/home_cubit.dart';
import '../Logic/cubits/Home_cubit/homestate.dart';
import '../Logic/cubits/premium_cubit/premium_bloc.dart';
import '../Logic/cubits/premium_cubit/premium_state.dart';
import '../Logic/paymentGateway/razorpayy.dart';
import '../by_coin_screen/coin_provider.dart';
import '../core/config.dart';
import '../language/localization/app_localization.dart';
import '../payment/common_webview.dart';
import '../payment/inputformater.dart';
import '../payment/paymentcard.dart';
import '../payment/paypal_screen.dart';
import '../presentation/screens/BottomNavBar/homeProvider/homeprovier.dart';
import '../presentation/screens/other/premium/premium_provider.dart';
import '../presentation/widgets/main_button.dart';
import '../presentation/widgets/other_widget.dart';

TextEditingController walletController = TextEditingController();
class Wallete_Screen extends StatefulWidget {
  const Wallete_Screen({super.key});

  @override
  State<Wallete_Screen> createState() => _Wallete_ScreenState();
}

class _Wallete_ScreenState extends State<Wallete_Screen> {

  late PremiumBloc premiumBloc;
  late PremiumProvider premiumProvider;
  late WalleteProvider walleteProvider;
  late HomeProvider homeProvider;
  late ByCoinProvider byCoinProvider;



  @override
  void initState() {
    super.initState();
    byCoinProvider = Provider.of<ByCoinProvider>(context,listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.giftlistApi(context);
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
    walleteProvider = Provider.of<WalleteProvider>(context,listen: false);
    walleteProvider.walletreportApi(context: context);
  }


  final RazorPayClass _razorPayClass = RazorPayClass();


  void handlePaymentSuccess(PaymentSuccessResponse response) {
    walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
      walleteProvider.walletreportApi(context: context);
    },);
  }

  void handlePaymentError(PaymentFailureResponse response) {

    Fluttertoast.showToast(msg: "ERROR: ${response.code} - ${response.message!}", toastLength: Toast.LENGTH_SHORT);

  }

  void handleExternalWallet(ExternalWalletResponse response) {

    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: ${response.walletName!}", toastLength: Toast.LENGTH_SHORT

    );
  }
  String emapty = '';



  @override
  Widget build(BuildContext context) {
    byCoinProvider = Provider.of<ByCoinProvider>(context);
    premiumBloc = Provider.of<PremiumBloc>(context);
    premiumProvider = Provider.of<PremiumProvider>(context);
    walleteProvider = Provider.of<WalleteProvider>(context);
    homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(AppLocalizations.of(context)?.translate("Wallet") ?? "Wallet",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18)),
        leading: const BackButtons(),
      ),
      body: BlocBuilder<PremiumBloc,PremiumState>(
          builder: (context, state)  {
            if(state is PremiumComplete){
              return  BlocBuilder<HomePageCubit,HomePageStates>(builder: (context, state1) {
                if(state1 is HomeCompleteState){
                  return

                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)?.translate("Total Balance") ?? "Total Balance",style: Theme.of(context).textTheme.bodyMedium!.copyWith(),),
                                  Text("${Provider.of<HomeProvider>(context,listen: false).currency}${walleteProvider.walletReportApiModel.wallet}",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 35,fontWeight: FontWeight.bold),),
                                ],
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 200),
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                        child: Scaffold(
                                          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
                                          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                                          floatingActionButton: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Expanded(child:
                                                MainButton(
                                                  bgColor: AppColors.appColor,
                                                  title: AppLocalizations.of(context)
                                                      ?.translate("Continue") ??
                                                      "Continue", onTap: () {
                                                  if (premiumProvider.selectedPayment == 1) {
                                                    _razorPayClass.openCheckout(
                                                      name: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString(),
                                                      number: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString(),
                                                      amount: walletController.text,
                                                      key: premiumProvider.selectedPaymentattributes.toString(),
                                                    );
                                                    Navigator.pop(context);
                                                  }
                                                  else if (premiumProvider.selectedPayment == 3) {
                                                    List ids = premiumProvider
                                                        .selectedPaymentattributes
                                                        .toString().split(",");
                                                    print('++++++++++ids:------$ids');
                                                    paypalPayment(
                                                      urlStatus: ids[2],
                                                      context: context,
                                                      function: (e) {
                                                        walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                          walleteProvider.walletreportApi(context: context);
                                                        },);
                                                      },
                                                      amt: walletController.text,
                                                      clientId: ids[0],
                                                      secretKey: ids[1],
                                                    );
                                                  }
                                                  else if (premiumProvider.selectedPayment == 4) {
                                                    Navigator.pop(context);
                                                    stripePayment();
                                                  }

                                                  else if (premiumProvider.selectedPayment == 6) {

                                                    byCoinProvider.paystackApi(amount: walletController.text,email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString(),context: context).then((value) {


                                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => PayStack(authorization_url: value,),)).then((otid) {
                                                      //         print("payment success");
                                                      //
                                                      //         if (isPayment == 1) {
                                                      //           walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                      //             walleteProvider.walletreportApi(context: context);
                                                      //           },);
                                                      //           Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment Successfully") ?? "Payment Successfully", timeInSecForIosWeb: 4);
                                                      //         } else {
                                                      //           Navigator.pop(context);
                                                      //         }
                                                      //
                                                      //       },);



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
                                                                walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                  walleteProvider.walletreportApi(context: context);
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


                                                    },);
                                                  }
                                                  else if (premiumProvider.selectedPayment == 7) {

                                                    //
                                                    // Navigator.push(context,
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           Flutterwave(totalAmount: walletController.text,
                                                    //             email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString(),
                                                    //           ),)).then((otid) {
                                                    //   if (otid != null) {
                                                    //     walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                    //       walleteProvider.walletreportApi(context: context);
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
                                                        initialUrl: "${Config.baseUrl}flutterwave/index.php?amt=${walletController.text}&email=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email}",
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
                                                            if (status == "successful") {
                                                              print("Purchase successful.");
                                                              // await byCoinProvider.packagepurchaseApi(packageid: select, context: context, wall_amt: "0");
                                                              // await byCoinProvider.coinreportApi(context);
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           PayTmPayment(
                                                    //               totalAmount: walletController.text,
                                                    //               uid: Provider
                                                    //                   .of<
                                                    //                   HomeProvider>(
                                                    //                   context,
                                                    //                   listen: false)
                                                    //                   .userlocalData
                                                    //                   .userLogin!
                                                    //                   .email
                                                    //                   .toString()
                                                    //           ),)).then((otid) {
                                                    //   if (otid != null) {
                                                    //     walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                    //       walleteProvider.walletreportApi(context: context);
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
                                                        initialUrl: "${Config.baseUrl}paytm/index.php?amt=${walletController.text}&uid=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()}",
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
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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
                                                  else if (premiumProvider.selectedPayment == 10) {

                                                    // Navigator.push(context,
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           SenangPay(
                                                    //               email: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString(),
                                                    //               totalAmount: walletController.text,
                                                    //               name: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString(),
                                                    //               phon: Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString()),
                                                    //     ),
                                                    // )
                                                    //     .then((otid) {
                                                    //   if (otid != null) {
                                                    //     walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                    //       walleteProvider.walletreportApi(context: context);
                                                    //     },);
                                                    //   } else {
                                                    //     Navigator.pop(context);
                                                    //   }
                                                    // });



                                                    final notificationId = UniqueKey().hashCode;

                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => PaymentWebVIew(
                                                        initialUrl: "${Config.baseUrl}result.php?detail=Movers&amount=${walletController.text}&order_id=$notificationId&name=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString()}&email=${ Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()}&phone=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString()}",
                                                        navigationDelegate: (request) async {
                                                          final uri = Uri.parse(request.url);
                                                          print("Navigating to URL: ${request.url}");
                                                          print("Parsed URI: $uri");

                                                          // Check the status parameter instead of Result
                                                          final status = uri.queryParameters["msg"];
                                                          print("Hello Status:---- $status");

                                                          if (status == null) {
                                                            print("No status parameter found.");
                                                          } else {
                                                            print("Status parameter: $status");
                                                            if (status == "Payment_was_successful") {
                                                              print("Purchase successful.");
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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
                                                  else if (premiumProvider.selectedPayment == 12) {

                                                    // Navigator.push(context,
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) => PayFast(
                                                    //         totalAmount: walletController.text,
                                                    //       ),)).then((otid) {
                                                    //   if (otid != null) {
                                                    //   walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                    //     walleteProvider.walletreportApi(context: context);
                                                    //   },);
                                                    //   Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment Successfully") ?? "Payment Successfully", timeInSecForIosWeb: 4);
                                                    //   } else {
                                                    //     Navigator.pop(context);
                                                    //   }
                                                    // });



                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => PaymentWebVIew(
                                                        initialUrl: "${Config.baseUrl}Payfast/index.php?amt=${walletController.text}",
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
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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



                                                  else if (premiumProvider.selectedPayment == 13) {

                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => PaymentWebVIew(
                                                        initialUrl: "${Config.baseUrl}Midtrans/index.php?name=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.name.toString()}&email=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.email.toString()}&phone=${Provider.of<HomeProvider>(context, listen: false).userlocalData.userLogin!.mobile.toString()}&amt=${walletController.text}",
                                                        navigationDelegate: (request) async {
                                                          final uri = Uri.parse(request.url);
                                                          print("Navigating to URL: ${request.url}");
                                                          print("Parsed URI: $uri");

                                                          // Check the status parameter instead of Result
                                                          final status = uri.queryParameters["status_code"];
                                                          print("Hello Status:---- $status");

                                                          if (status == null) {
                                                            print("No status parameter found.");
                                                          } else {
                                                            print("Status parameter: $status");
                                                            if (status == "200") {
                                                              print("Purchase successful.");
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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
                                                  else if (premiumProvider.selectedPayment == 14) {

                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => PaymentWebVIew(
                                                        initialUrl: "${Config.baseUrl}2checkout/index.php?amt=${walletController.text}",
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
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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
                                                  else if (premiumProvider.selectedPayment == 15) {

                                                    // Navigator.push(context, MaterialPageRoute(
                                                    //   builder: (context) => PaymentWebVIew(
                                                    //     initialUrl: "${Config.baseUrl}Khalti/index.php?amt=${walletController.text}",
                                                    //     navigationDelegate: (request) async {
                                                    //       final uri = Uri.parse(request.url);
                                                    //       print("Navigating to URL: ${request.url}");
                                                    //       print("Parsed URI: $uri");
                                                    //
                                                    //       // Check the status parameter instead of Result
                                                    //       final status = uri.queryParameters["Result"];
                                                    //       print("Hello Status:---- $status");
                                                    //
                                                    //       if (status == null) {
                                                    //         print("No status parameter found.");
                                                    //       } else {
                                                    //         print("Status parameter: $status");
                                                    //         if (status == "success") {
                                                    //           print("Purchase successful.");
                                                    //           walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                    //             walleteProvider.walletreportApi(context: context);
                                                    //           },);
                                                    //           return NavigationDecision.prevent;
                                                    //         } else {
                                                    //           print("Purchase failed with status: $status.");
                                                    //           Navigator.pop(context);
                                                    //           Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate(status) ?? status, timeInSecForIosWeb: 4);
                                                    //           return NavigationDecision.prevent;
                                                    //         }
                                                    //       }
                                                    //       return NavigationDecision.navigate;
                                                    //     },
                                                    //   ),
                                                    // ));



                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => PaymentWebVIew(
                                                        initialUrl: "${Config.baseUrl}Khalti/index.php?amt=${walletController.text}",
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
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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
                                                  else if (premiumProvider.selectedPayment == 16) {

                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => PaymentWebVIew(
                                                        initialUrl: "${Config.baseUrl}merpago/index.php?amt=${walletController.text}",
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
                                                              walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                                                                walleteProvider.walletreportApi(context: context);
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

                                                  else {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(content: Text(
                                                          AppLocalizations.of(
                                                              context)?.translate(
                                                              "Not Valid") ??
                                                              "Not Valid"),
                                                        behavior: SnackBarBehavior
                                                            .floating,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(10)),),
                                                    );
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
                                            child:  Padding(
                                              padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  const SizedBox(height: 10,),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 6,right: 6),
                                                    child: Text(AppLocalizations.of(context)?.translate("Add Wallet Amount") ?? "Add Wallet Amount",style: TextStyle(color: AppColors.appColor,fontSize: 15,fontWeight: FontWeight.bold)),
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: SizedBox(
                                                      height: 45,
                                                      child: TextFormField(
                                                        controller: walletController,
                                                        cursorColor: Colors.black,
                                                        keyboardType: TextInputType.number,
                                                        style: TextStyle(color: AppColors.appColor,fontSize: 14,fontWeight: FontWeight.bold),
                                                        decoration: InputDecoration(
                                                          contentPadding: const EdgeInsets.only(top: 15),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(
                                                              color: Colors.grey.withOpacity(0.4),
                                                            ),
                                                          ),
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(
                                                              color: Colors.grey.withOpacity(0.4),
                                                            ),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(
                                                              color: Colors.grey.withOpacity(0.4),
                                                            ),
                                                          ),
                                                          prefixIcon: SizedBox(
                                                            height: 20,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                                              child: Image.asset(
                                                                'assets/icons/a1.png',
                                                                width: 20,
                                                                // color: notifier.textcolore,
                                                              ),
                                                            ),
                                                          ),
                                                          hintText: AppLocalizations.of(context)?.translate("Enter Amount") ?? "Enter Amount",
                                                          hintStyle:  const TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10,),
                                                   Padding(
                                                    padding: EdgeInsets.only(left: 6,right: 6),
                                                    child: Text(AppLocalizations.of(context)?.translate("Select Payment Method") ?? "Select Payment Method",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 12)),
                                                  ),
                                                  const SizedBox(height: 0,),

                                                  Consumer<PremiumProvider>(
                                                    builder: (BuildContext context, value,
                                                        Widget? child) {
                                                      return Expanded(
                                                        child: ListView.separated(
                                                            padding: const EdgeInsets.only(top: 10.0, bottom: 50, right: 10, left: 10),
                                                            shrinkWrap: true,
                                                            itemBuilder: (context, index) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  // premiumProvider.selectedPayment = index;
                                                                  value.updateSelectPayment(
                                                                      int.parse(
                                                                          state.payment[index]
                                                                              .id.toString()));
                                                                  value.updateAttributes(
                                                                      state.payment[index]
                                                                          .attributes
                                                                          .toString());
                                                                  value.updatePaymentName(
                                                                      state.payment[index]
                                                                          .title.toString());
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
                                },
                                child: Container(
                                  width: 130,
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
                            ],
                          ),


                          const SizedBox(height: 20,),
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Refer_And_Earn(),));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: AppColors.appColor,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(AppLocalizations.of(context)?.translate("Invite a friend and") ?? "Invite a friend and",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
                                          Text(AppLocalizations.of(context)?.translate("both earn cashback") ?? "both earn cashback",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 15,),
                                          Row(
                                            children: [
                                              Text(AppLocalizations.of(context)?.translate("Invite friend") ?? "Invite friend",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.yellow,fontSize: 14)),
                                              const SizedBox(width: 5,),
                                              const Icon(Icons.arrow_right_alt_sharp,color: Colors.yellow),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Lottie.asset('assets/lottie/maintance_mode.json',height: 120),
                                    ],
                                  )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15,),
                          walleteProvider.walletReportApiModel.walletitem.isEmpty ? const SizedBox() : Row(
                            children: [
                              Text(AppLocalizations.of(context)?.translate("Transaction") ?? "Transaction",style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 20)),
                              const Spacer(),
                              // Text(AppLocalizations.of(context)?.translate("See All") ?? "See All",style: Theme.of(context).textTheme.bodyMedium!.copyWith()),
                            ],
                          ),

                          Expanded(
                            child: ListView.separated(
                                separatorBuilder: (context, index) {
                                  return const SizedBox(width : 0,);
                                },
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: walleteProvider.walletReportApiModel.walletitem.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: walleteProvider.walletReportApiModel.walletitem[index].status == 'Debit' ? const Image(image: AssetImage('assets/Image/Debit.png'),height: 40):const Image(image: AssetImage('assets/Image/Creadit.png'),height: 40),
                                    title: Transform.translate(offset: const Offset(-6, 0),child: Text(walleteProvider.walletReportApiModel.walletitem[index].message,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15))),
                                    subtitle: Transform.translate(offset: const Offset(-6, 0),child: Text(walleteProvider.walletReportApiModel.walletitem[index].status,style: const TextStyle(fontSize: 14,color: Colors.grey))),
                                    trailing: Text('${walleteProvider.walletReportApiModel.walletitem[index].status == 'Debit' ? '-' : "+"} ${Provider.of<HomeProvider>(context,listen: false).currency}${walleteProvider.walletReportApiModel.walletitem[index].amt}',style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: walleteProvider.walletReportApiModel.walletitem[index].status == "Debit"  ? Colors.red : Colors.green)),
                                  );
                                }
                             ),
                          ),
                        ],
                      ),
                    );





                }else{
                  return const SizedBox();
                }
              }
              );
            }else{
              return const SizedBox();
            }
        }
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
                                            "Pay ${walletController.text}",
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
        _autoValidateMode =
            AutovalidateMode.always;
      });

      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Please fix the errors in red before submitting.") ?? "Please fix the errors in red before submitting.",timeInSecForIosWeb: 4);
    } else {

      var username = Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.name.toString();

      var email = Provider.of<HomeProvider>(context,listen: false).userlocalData.userLogin!.email.toString();
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount =walletController.text;
      form.save();


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
            print("........:--- $status");
            if (status == null) {
              print("No status parameter found.");
            } else {
              print("Status parameter: $status");
              if (status == "success") {
                print("Purchase successful.");
                walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
                  walleteProvider.walletreportApi(context: context);
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


      // Navigator.push(context, MaterialPageRoute(builder: (context) => StripePaymentWeb(paymentCard: _paymentCard),)).then((otid) {
      //   Navigator.pop(context);
      //   // if (otid != null) {
      //     walleteProvider.walletupApi(wallet: walletController.text,context: context).then((value) {
      //       walleteProvider.walletreportApi(context: context);
      //     },);
      //     // Book_Ticket( uid: widget.uid, bus_id: widget.bus_id,pick_id: widget.pick_id, dropId: widget.dropId, ticketPrice: widget.ticketPrice,trip_date: widget.trip_date,paymentId: "$otid",boardingCity: widget.boardingCity,dropCity: widget.dropCity,busPicktime: widget.busPicktime,busDroptime: widget.busDroptime,Difference_pick_drop: widget.differencePickDrop);
      //   // }
      // });

      // Fluttertoast.showToast(msg: "Payment card is valid".tr,timeInSecForIosWeb: 4);
      Fluttertoast.showToast(msg: AppLocalizations.of(context)?.translate("Payment card is valid") ?? "Payment card is valid",timeInSecForIosWeb: 4);
    }
  }




}
