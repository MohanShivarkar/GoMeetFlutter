// lib/stubs/agora_stub.dart
//
// Web stub for agora_rtc_engine.
// Selected by conditional import when dart.library.html is available.
// All methods are no-ops; video/audio calls are not supported on web.

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

class RtcEngine {
  Future<void> initialize(RtcEngineContext context) async {}
  void registerEventHandler(RtcEngineEventHandler handler) {}
  Future<void> setClientRole({required ClientRoleType role}) async {}
  Future<void> enableVideo() async {}
  Future<void> startPreview() async {}
  Future<void> joinChannel({
    required String token,
    required String channelId,
    required int uid,
    ChannelMediaOptions? options,
  }) async {}
  Future<void> leaveChannel() async {}
  Future<void> release() async {}
  Future<void> disableAudio() async {}
  Future<void> disableVideo() async {}
  Future<void> muteAllRemoteAudioStreams(bool mute) async {}
  Future<void> switchCamera() async {}
  Future<void> muteLocalAudioStream(bool mute) async {}
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

class AgoraVideoView extends StatelessWidget {
  final VideoViewController controller;
  const AgoraVideoView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
