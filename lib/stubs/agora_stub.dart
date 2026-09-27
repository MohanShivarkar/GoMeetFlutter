// lib/stubs/agora_stub.dart
//
// WebRTC implementation of Agora RTC Engine for Flutter Web.
// Bridges Flutter call pages with Agora Web SDK NG (v4.x) via window.agoraWebBridge.

// ignore_for_file: avoid_classes_with_only_static_members, avoid_web_libraries_in_flutter, undefined_prefixed_name

import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class RtcEngine {
  RtcEngineEventHandler? _handler;
  String _appId = '';
  bool _isVideo = false;

  Future<void> initialize(RtcEngineContext context) async {
    _appId = context.appId;
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('initClient', [_appId]);
      }
    } catch (e) {
      debugPrint('[AgoraWeb] initialize error: $e');
    }
  }

  void registerEventHandler(RtcEngineEventHandler handler) {
    _handler = handler;
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge']['onJoinSuccessCallback'] = (dynamic uid) {
          final int parsedUid = uid is int ? uid : int.tryParse(uid.toString()) ?? 0;
          _handler?.onJoinChannelSuccess?.call(
            RtcConnection(localUid: parsedUid),
            0,
          );
        };

        js.context['agoraWebBridge']['onUserJoinedCallback'] = (dynamic uid) {
          final int parsedUid = uid is int ? uid : int.tryParse(uid.toString()) ?? 0;
          _handler?.onUserJoined?.call(
            RtcConnection(),
            parsedUid,
            0,
          );
        };

        js.context['agoraWebBridge']['onUserOfflineCallback'] = (dynamic uid) {
          final int parsedUid = uid is int ? uid : int.tryParse(uid.toString()) ?? 0;
          _handler?.onUserOffline?.call(
            RtcConnection(),
            parsedUid,
            UserOfflineReasonType.userOfflineQuit,
          );
        };
      }
    } catch (e) {
      debugPrint('[AgoraWeb] registerEventHandler error: $e');
    }
  }

  Future<void> setClientRole({required ClientRoleType role}) async {}

  Future<void> enableVideo() async {
    _isVideo = true;
  }

  Future<void> startPreview() async {}

  Future<void> joinChannel({
    required String token,
    required String channelId,
    required int uid,
    ChannelMediaOptions? options,
  }) async {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('joinChannel', [
          _appId,
          channelId,
          token,
          uid,
          _isVideo,
        ]);
      }
    } catch (e) {
      debugPrint('[AgoraWeb] joinChannel error: $e');
    }
  }

  Future<void> leaveChannel() async {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('leaveChannel');
      }
    } catch (e) {
      debugPrint('[AgoraWeb] leaveChannel error: $e');
    }
  }

  Future<void> release() async {}
  Future<void> disableAudio() async {}
  Future<void> disableVideo() async {}

  Future<void> muteAllRemoteAudioStreams(bool mute) async {}

  Future<void> switchCamera() async {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('switchCamera');
      }
    } catch (e) {
      debugPrint('[AgoraWeb] switchCamera error: $e');
    }
  }

  Future<void> muteLocalAudioStream(bool mute) async {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('muteLocalAudio', [mute]);
      }
    } catch (e) {
      debugPrint('[AgoraWeb] muteLocalAudio error: $e');
    }
  }
}

RtcEngine createAgoraRtcEngine() => RtcEngine();

class RtcEngineContext {
  final String appId;
  final ChannelProfileType? channelProfile;
  const RtcEngineContext({required this.appId, this.channelProfile});
}

class RtcEngineEventHandler {
  final void Function(RtcConnection connection, int elapsed)? onJoinChannelSuccess;
  final void Function(RtcConnection connection, int remoteUid, int elapsed)? onUserJoined;
  final void Function(RtcConnection connection, int remoteUid, UserOfflineReasonType reason)? onUserOffline;
  final void Function(RtcConnection connection, String token)? onTokenPrivilegeWillExpire;
  const RtcEngineEventHandler({
    this.onJoinChannelSuccess,
    this.onUserJoined,
    this.onUserOffline,
    this.onTokenPrivilegeWillExpire,
  });
}

class RtcConnection {
  final String? channelId;
  final int? localUid;
  const RtcConnection({this.channelId, this.localUid});
  Map<String, dynamic> toJson() => {};
}

enum ChannelProfileType {
  channelProfileLiveBroadcasting,
  channelProfileCommunication,
}

enum ClientRoleType {
  clientRoleBroadcaster,
  clientRoleAudience,
}

enum UserOfflineReasonType {
  userOfflineQuit,
  userOfflineDropped,
  userOfflineBecomeAudience,
}

class ChannelMediaOptions {
  final ClientRoleType? clientRoleType;
  final ChannelProfileType? channelProfile;
  const ChannelMediaOptions({this.clientRoleType, this.channelProfile});
}

class VideoCanvas {
  final int? uid;
  const VideoCanvas({this.uid});
}

class VideoViewController {
  final RtcEngine rtcEngine;
  final VideoCanvas canvas;
  final RtcConnection? connection;

  VideoViewController({
    required this.rtcEngine,
    required this.canvas,
    this.connection,
  });

  VideoViewController.remote({
    required this.rtcEngine,
    required this.canvas,
    required RtcConnection connection,
  }) : connection = connection;
}

class AgoraVideoView extends StatefulWidget {
  final VideoViewController controller;
  const AgoraVideoView({super.key, required this.controller});

  @override
  State<AgoraVideoView> createState() => _AgoraVideoViewState();
}

class _AgoraVideoViewState extends State<AgoraVideoView> {
  static bool _registered = false;
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    final isLocal = (widget.controller.canvas.uid ?? 0) == 0;
    _viewType = isLocal ? 'agora-local-video-view' : 'agora-remote-video-view';
    _registerViewFactory();
  }

  static void _registerViewFactory() {
    if (_registered) return;
    _registered = true;

    ui_web.platformViewRegistry.registerViewFactory(
      'agora-local-video-view',
      (int viewId) {
        final div = html.DivElement()
          ..id = 'agora-local-video'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#000000'
          ..style.overflow = 'hidden'
          ..style.borderRadius = '12px';
        return div;
      },
    );

    ui_web.platformViewRegistry.registerViewFactory(
      'agora-remote-video-view',
      (int viewId) {
        final div = html.DivElement()
          ..id = 'agora-remote-video'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#0B0D14'
          ..style.overflow = 'hidden';
        return div;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
