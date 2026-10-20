import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart'
    if (dart.library.html) 'package:dating/stubs/agora_stub.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/core/config.dart';
import 'package:dating/presentation/firebase/vc_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui.dart';
import '../screens/splash_bording/splash_screen.dart';
import 'chat_page.dart';

import 'package:dating/core/web_call_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VideoCall extends StatefulWidget {
  final String channel;
  const VideoCall({Key? key, required this.channel}) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {

  late VcProvider vcProvider;
  late StreamSubscription streamSubscription;
  Timer? _callTimeoutTimer;

  @override
  void initState() {
    super.initState();
    WebCallHelper.stopRingtone();
    vcProvider = Provider.of<VcProvider>(context,listen: false);
    final effectiveKey = agoraVcKey.isNotEmpty ? agoraVcKey : "3b2d066ea4da4c84ad4492ea72780653";
    vcProvider.initAgora(effectiveKey, effectiveKey, widget.channel, context);

    _callTimeoutTimer = Timer(const Duration(seconds: 35), () {
      if (mounted && vcProvider.remoteUid == null) {
        Fluttertoast.showToast(msg: "User is not available right now. Please try again.");
        isvc(widget.channel, false);
        Navigator.pop(context);
      }
    });

    streamSubscription =  FirebaseFirestore.instance.collection("chat_rooms").doc(widget.channel).collection("isVcAvailable").doc(widget.channel).snapshots().listen((event) {
      if (!mounted || event.data() == null) return;
      Map data = event.data()!;
      print("xxxxxxxxxxxxxx${data}");

      if(data["isVc"] == false){
        Navigator.pop(context);
      }

    });
  }

  @override
  void dispose() {
    _callTimeoutTimer?.cancel();
    WebCallHelper.stopRingtone();
    super.dispose();
    isvc(widget.channel,false);
    vcProvider.disposee();
    vcProvider.localUserJoined = false;
    vcProvider.muteUnmute = false;
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    vcProvider = Provider.of<VcProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D14),
      body: Stack(
        children: [

          // Fullscreen Remote Video Feed
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0B0D14),
              child: vcProvider.remoteVideo(widget.channel, context),
            ),
          ),

          // Floating Local User Video Preview
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, right: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 110,
                  height: 160,
                  child: Container(
                    color: Colors.black,
                    child: vcProvider.localUserJoined
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: vcProvider.engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : Center(child: CircularProgressIndicator(color: AppColors.appColor)),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 50,
            left: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  const Spacer(),

                  InkWell(
                    onTap: () async {
                      vcProvider.muteUnmute =! vcProvider.muteUnmute;
                      await vcProvider.engine.muteAllRemoteAudioStreams(vcProvider.muteUnmute);
                      setState(() {});
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black),
                      child: Icon(
                        vcProvider.muteUnmute ? Icons.media_bluetooth_off : Icons.media_bluetooth_on_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Spacer(),
                  InkWell(
                    onTap: () {
                      isvc(widget.channel,false);
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red,
                      ),
                      child: const Icon(Icons.call_end),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      await vcProvider.engine.switchCamera();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black),
                      child: const Icon(
                        Icons.cameraswitch_sharp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}
