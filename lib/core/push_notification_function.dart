// ignore_for_file: avoid_print

import 'package:dating/core/config.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'
    if (dart.library.html) 'package:dating/stubs/onesignal_stub.dart';



// Future<void> initPlatformState({context}) async {
//   OneSignal.shared.setAppId(Config.oneSignel).then((value) {
//     print("accepted123:------  ");
//   });
//   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
//     print("accepted:------   $accepted");
//   });
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     print("Accepted OSPermissionStateChanges : $changes");
//   });
//
// }

Future<void> initPlatformState() async {
  if (kIsWeb) {
    return;
  }
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(Config.oneSignel);
  OneSignal.Notifications.requestPermission(true).then(
        (value) {
      print("Signal value:- $value");
    },
  );
}
