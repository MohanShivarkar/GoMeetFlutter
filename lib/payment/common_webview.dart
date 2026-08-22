// // ignore_for_file: deprecated_member_use, file_names, prefer_typing_uninitialized_variables, prefer_const_constructors, depend_on_referenced_packages, prefer_interpolation_to_compose_strings
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../model/font_family_model.dart';
// import 'package:laundry/utils/Custom_widget.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../yourcart_screen.dart';
//
// class PaymentWebVIew extends StatefulWidget {
//   final String initialUrl;
//   final FutureOr<NavigationDecision> Function(NavigationRequest request) navigationDelegate;
//   const PaymentWebVIew({super.key, required this.initialUrl, required this.navigationDelegate});
//
//   @override
//   State<PaymentWebVIew> createState() => _PaymentWebVIewState();
// }
//
// class _PaymentWebVIewState extends State<PaymentWebVIew> {
//   late WebViewController _controller;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   var progress;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     isLoading = false;
//     setState(() {});
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_scaffoldKey.currentState == null) {
//       return WillPopScope(
//         onWillPop: (() async => true),
//         child: Scaffold(
//           body: SafeArea(
//             child: isLoading
//                 ? Center(child: CircularProgressIndicator(color: gradient.defoultColor),)
//                 : WebView(
//               backgroundColor: Colors.grey.shade200,
//               initialUrl: widget.initialUrl,
//               javascriptMode: JavascriptMode.unrestricted,
//               gestureNavigationEnabled: true,
//               onWebViewCreated: (controller) => _controller = controller,
//               onPageFinished: (String url) {
//                 readJS();
//               },
//               navigationDelegate: widget.navigationDelegate,
//               onProgress: (val) {
//                 setState(() {});
//                 progress = val;
//               },
//             ),
//           ),
//         ),
//       );
//     } else {
//       return Scaffold(
//         key: _scaffoldKey,
//         appBar: AppBar(
//             leading: IconButton(
//                 icon: const Icon(Icons.arrow_back,color: Colors.red),
//                 onPressed: () => Get.to(YourCartScreen())),
//             backgroundColor: Colors.black12,
//             elevation: 0.0),
//         body: Center(
//           child: CircularProgressIndicator(
//             color: gradient.defoultColor,
//           ),
//         ),
//       );
//     }
//   }
//
//   Future readJS() async {
//     setState(() {
//       _controller.evaluateJavascript("document.documentElement.innerText").then((value) async {
//         if (value.contains("Transaction_id")) {
//           String fixed = value.replaceAll(r"\'", "");
//           if (GetPlatform.isAndroid) {
//             String json = jsonDecode(fixed);
//             var val1 = jsonStringToMap(json);
//             if ((val1['ResponseCode'] == "200") && (val1['Result'] == "true")) {
//               Get.back(result: val1["Transaction_id"]);
//               showToastMessage(val1["ResponseMsg"]);
//             } else {
//               showToastMessage(val1["ResponseMsg"]);
//               Get.back();
//             }
//           } else {
//             var val2 = jsonStringToMap(fixed);
//             if ((val2['ResponseCode'] == "200") && (val2['Result'] == "true")) {
//               Get.back(result: val2["Transaction_id"]);
//               showToastMessage(val2["ResponseMsg"]);
//             } else {
//               showToastMessage(val2["ResponseMsg"]);
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
//
// }
//

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentWebVIew extends StatefulWidget {
  final String initialUrl;
  final FutureOr<NavigationDecision> Function(NavigationRequest request) navigationDelegate;
  const PaymentWebVIew({super.key, required this.initialUrl, required this.navigationDelegate});

  @override
  State<PaymentWebVIew> createState() => _PaymentWebVIewState();
}

class _PaymentWebVIewState extends State<PaymentWebVIew> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: widget.navigationDelegate,
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )

      ..loadRequest(Uri.parse(widget.initialUrl));
      print("URL------- ${widget.initialUrl}");
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: WebViewWidget(controller: _controller),
      ),
    );
  }
}


