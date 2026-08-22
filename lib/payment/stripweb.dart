// ignore_for_file: avoid_print

import 'package:dating/core/config.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/ui.dart';
import 'paymentcard.dart';

class StripePaymentWeb extends StatefulWidget {
  final PaymentCardCreated paymentCard;

  const StripePaymentWeb({Key? key, required this.paymentCard})
      : super(key: key);

  @override
  State<StripePaymentWeb> createState() => _StripePaymentWebState();
}

class _StripePaymentWebState extends State<StripePaymentWeb> {
  late WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  PaymentCardCreated? payCard;
  var progress;
  bool isLoading = true;
  String? accessToken;
  String? payerID;

  @override
  void initState() {
    super.initState();
    setState(() {});

    payCard = widget.paymentCard;

    print("{{{{{{{{{{{{{{{{{{{{{}}}}}}}}}}}}}}}}}");
    print("++++++:--- ${payCard?.name}");
    print("++++++:--- ${payCard?.email}");
    print("++++++:--- ${payCard?.number}");
    print("++++++:--- ${payCard?.cvv}");
    print("++++++:--- ${payCard?.amount}");
    print("++++++:--- ${payCard?.month}");
    print("++++++:--- ${payCard?.year}");

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            print("+++++++ status +++++++:-- ${uri.queryParameters}");
            if (uri.queryParameters["status"] == null) {
              accessToken = uri.queryParameters["token"];
              print("final if");
            } else {
              print("final else");
              if (uri.queryParameters["status"] == "success") {
                payerID = await uri.queryParameters["payment_id"];
                print("secounde if");
                Navigator.of(context).pop(payerID);
              } else {
                print("secounde else");
                Navigator.pop(context);
                Fluttertoast.showToast(
                    msg: "${uri.queryParameters["status"]}",
                    timeInSecForIosWeb: 4,
                );
              }
            }


            return NavigationDecision.navigate;

          },

        ),

      )..loadRequest(Uri.parse("${Config.baseUrl}stripe/index.php?name=${payCard!.name}&email=${payCard!.email}&cardno=${payCard!.number}&cvc=${payCard!.cvv}&amt=${payCard!.amount}&mm=${payCard!.month}&yyyy=${payCard!.year}"));

  }

  // String get initialUrl => '${Config.baseUrl}stripe/index.php?name=${payCard!.name}&email=${payCard!.email}&cardno=${payCard!.number}&cvc=${payCard!.cvv}&amt=${payCard!.amount}&mm=${payCard!.month}&yyyy=${payCard!.year}';

  @override
  Widget build(BuildContext context) {

    if (_scaffoldKey.currentState == null) {
      print("PayFast ++++++++++++++++++++++----");

      return WillPopScope(
        onWillPop: () {
          return Future(() => true);
        },
        child:  Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                isLoading ?
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: const Text(
                          'Please don`t press back until the transaction is complete',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : const Stack(),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(
          child: Container(
            child: CircularProgressIndicator(color: AppColors.appColor),
          ),
        ),
      );
    }
  }


  jsonStringToMap(String data) {
    List<String> str = data
        .replaceAll("{", "")
        .replaceAll("}", "")
        .replaceAll("\"", "")
        .replaceAll("'", "")
        .split(",");
    Map<String, dynamic> result = {};
    for (int i = 0; i < str.length; i++) {
      List<String> s = str[i].split(":");
      result.putIfAbsent(s[0].trim(), () => s[1].trim());
    }
    return result;
  }



}























// // ignore_for_file: deprecated_member_use, file_names, prefer_typing_uninitialized_variables, prefer_const_constructors, prefer_interpolation_to_compose_strings
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:goproperti/Api/config.dart';
// import 'package:goproperti/screen/payment/PaymentCard.dart';
// import 'package:goproperti/utils/Custom_widget.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class StripePaymentWeb extends StatefulWidget {
//   final PaymentCardCreated paymentCard;
//   const StripePaymentWeb({super.key, required this.paymentCard});
//
//   @override
//   State<StripePaymentWeb> createState() => _StripePaymentWebState();
// }
//
// class _StripePaymentWebState extends State<StripePaymentWeb> {
//   late WebViewController _controller;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   // final dMode = Get.put(DarkMode());
//
//   PaymentCardCreated? payCard;
//   var progress;
//
//   @override
//   void initState() {
//     super.initState();
//     setState(() {});
//
//     payCard = widget.paymentCard;
//   }
//
//   String get initialUrl =>
//       Config.paymentBaseUrl +
//           'stripe/index.php?name=${payCard!.name}&email=${payCard!.email}&cardno=${payCard!.number}&cvc=${payCard!.cvv}&amt=${payCard!.amount}&mm=${payCard!.month}&yyyy=${payCard!.year}';
//   @override
//   Widget build(BuildContext context) {
//     if (_scaffoldKey.currentState == null) {
//       return WillPopScope(
//         onWillPop: (() async => true),
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // loading(size: 60),
//                       SizedBox(height: Get.height * 0.02),
//                       SizedBox(
//                         width: Get.width * 0.80,
//                         child: const Text(
//                           'Please don`t press back until the transaction is complete',
//                           maxLines: 2,
//                           textAlign: TextAlign.center,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500,
//                               letterSpacing: 0.5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: Get.height * 0.01),
//                 Stack(
//                   children: [
//                     Container(
//                       color: Colors.grey.shade200,
//                       height: 25,
//                       child: WebView(
//                         backgroundColor: Colors.grey.shade200,
//                         initialUrl: initialUrl,
//                         javascriptMode: JavascriptMode.unrestricted,
//                         gestureNavigationEnabled: true,
//                         onWebViewCreated: (controller) =>
//                         _controller = controller,
//                         onPageFinished: (String url) {
//                           readJS();
//                         },
//                         onProgress: (val) {
//                           setState(() {});
//                           progress = val;
//                         },
//                       ),
//                     ),
//                     Container(
//                         height: 25, color: Colors.white, width: Get.width),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     } else {
//       return Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//             leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () => Get.back()),
//             backgroundColor: Colors.black12,
//             elevation: 0.0),
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//   }
//
//   void readJS() async {
//     setState(() {
//       _controller
//           .evaluateJavascript("document.documentElement.innerText")
//           .then((value) async {
//         if (value.contains("Transaction_id")) {
//           String fixed = value.replaceAll(r"\'", "");
//           if (GetPlatform.isAndroid) {
//             String json = jsonDecode(fixed);
//             var val = jsonStringToMap(json);
//             if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
//               Get.back(result: val["Transaction_id"]);
//               showToastMessage(val["ResponseMsg"]);
//             } else {
//               showToastMessage(val["ResponseMsg"]);
//               Get.back();
//             }
//           } else {
//             var val = jsonStringToMap(fixed);
//             if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
//               Get.back(result: val["Transaction_id"]);
//               showToastMessage(val["ResponseMsg"]);
//             } else {
//               showToastMessage(val["ResponseMsg"]);
//               Get.back();
//             }
//           }
//         }
//         return "";
//       });
//     });
//   }
//
//   jsonStringToMap(String data) {
//     List<String> str = data
//         .replaceAll("{", "")
//         .replaceAll("}", "")
//         .replaceAll("\"", "")
//         .replaceAll("'", "")
//         .split(",");
//     Map<String, dynamic> result = {};
//     for (int i = 0; i < str.length; i++) {
//       List<String> s = str[i].split(":");
//       result.putIfAbsent(s[0].trim(), () => s[1].trim());
//     }
//     return result;
//   }
// }
