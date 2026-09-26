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

class VideoCall extends StatefulWidget {
  final String channel;
  const VideoCall({Key? key, required this.channel}) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {

  late VcProvider vcProvider;
  late StreamSubscription streamSubscription;

  @override
  void initState() {
    super.initState();
    vcProvider = Provider.of<VcProvider>(context,listen: false);
    if (!kIsWeb) {
      vcProvider.initAgora(agoraVcKey, agoraVcKey, widget.channel,context);
    }
    streamSubscription =  FirebaseFirestore.instance.collection("chat_rooms").doc(widget.channel).collection("isVcAvailable").doc(widget.channel).snapshots().listen((event) {
      Map data = event.data()!;
      print("xxxxxxxxxxxxxx${data}");

      if(data["isVc"] == false){
        Navigator.pop(context);
      }

    });
  }

  @override
  void dispose() {
    super.dispose();
    if (!kIsWeb) {
      isvc(widget.channel,false);
      vcProvider.disposee();
      vcProvider.localUserJoined = false;
      vcProvider.muteUnmute = false;
    }
    streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Video/Audio calls are available in the mobile app.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      );
    }

    vcProvider = Provider.of<VcProvider>(context);
    return Scaffold(
      body: Stack(
        children: [

          Center(
            child: vcProvider.remoteVideo(widget.channel,context),
          ),

          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: vcProvider.localUserJoined ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: vcProvider.engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ) : CircularProgressIndicator(color: AppColors.appColor),
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
