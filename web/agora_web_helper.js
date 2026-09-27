// web/agora_web_helper.js
// WebRTC calling bridge for LoveCloud PWA using Agora Web SDK NG (v4.x)

window.agoraWebBridge = {
  client: null,
  appId: null,
  channel: null,
  localAudioTrack: null,
  localVideoTrack: null,
  remoteUsers: {},
  onJoinSuccessCallback: null,
  onUserJoinedCallback: null,
  onUserOfflineCallback: null,

  initClient: async function(appId) {
    if (!window.AgoraRTC) {
      console.error("[AgoraWeb] AgoraRTC SDK not available on window!");
      return false;
    }
    if (this.client) {
      try { await this.leaveChannel(); } catch(e) {}
    }
    this.appId = appId;
    this.client = AgoraRTC.createClient({ mode: "rtc", codec: "vp8" });
    this._setupListeners();
    console.log("[AgoraWeb] Client initialized with appId:", appId);
    return true;
  },

  _setupListeners: function() {
    if (!this.client) return;

    this.client.on("user-published", async (user, mediaType) => {
      console.log("[AgoraWeb] Remote user published:", user.uid, "mediaType:", mediaType);
      try {
        await this.client.subscribe(user, mediaType);
        this.remoteUsers[user.uid] = user;

        if (mediaType === "audio") {
          if (user.audioTrack) {
            user.audioTrack.play();
            console.log("[AgoraWeb] Playing remote audio for:", user.uid);
          }
        }
        if (mediaType === "video") {
          this._renderRemoteVideo(user);
        }

        if (this.onUserJoinedCallback) {
          this.onUserJoinedCallback(user.uid);
        }
      } catch (err) {
        console.error("[AgoraWeb] Error subscribing to remote user:", err);
      }
    });

    this.client.on("user-unpublished", (user, mediaType) => {
      console.log("[AgoraWeb] Remote user unpublished:", user.uid, mediaType);
    });

    this.client.on("user-left", (user, reason) => {
      console.log("[AgoraWeb] Remote user left:", user.uid, "reason:", reason);
      delete this.remoteUsers[user.uid];
      if (this.onUserOfflineCallback) {
        this.onUserOfflineCallback(user.uid);
      }
    });
  },

  joinChannel: async function(appId, channel, token, uid, isVideo) {
    this.channel = channel;
    if (!this.client) {
      await this.initClient(appId);
    }
    try {
      console.log("[AgoraWeb] Joining channel:", channel, "uid:", uid, "isVideo:", isVideo);
      // Join Agora channel
      const joinedUid = await this.client.join(
        appId,
        channel,
        (token && token !== appId) ? token : null,
        uid ? parseInt(uid) : null
      );
      console.log("[AgoraWeb] Joined channel successfully with uid:", joinedUid);

      const tracksToPublish = [];

      // 1. Microphone track (Audio)
      try {
        this.localAudioTrack = await AgoraRTC.createMicrophoneAudioTrack({
          AEC: true,
          ANS: true,
          AGC: true
        });
        tracksToPublish.push(this.localAudioTrack);
        console.log("[AgoraWeb] Local microphone track ready");
      } catch (err) {
        console.warn("[AgoraWeb] Failed to create mic track:", err);
      }

      // 2. Camera track (Video)
      if (isVideo) {
        try {
          this.localVideoTrack = await AgoraRTC.createCameraVideoTrack({
            encoderConfig: "720p_1",
            facingMode: "user"
          });
          tracksToPublish.push(this.localVideoTrack);
          console.log("[AgoraWeb] Local camera track ready");
          setTimeout(() => this._renderLocalVideo(), 300);
        } catch (err) {
          console.warn("[AgoraWeb] Failed to create camera track:", err);
        }
      }

      if (tracksToPublish.length > 0) {
        await this.client.publish(tracksToPublish);
        console.log("[AgoraWeb] Published tracks successfully");
      }

      if (this.onJoinSuccessCallback) {
        this.onJoinSuccessCallback(joinedUid);
      }
      return true;
    } catch (e) {
      console.error("[AgoraWeb] joinChannel error:", e);
      return false;
    }
  },

  _renderLocalVideo: function() {
    const el = document.getElementById("agora-local-video");
    if (el && this.localVideoTrack) {
      el.innerHTML = "";
      this.localVideoTrack.play(el);
      console.log("[AgoraWeb] Local video mounted in container");
    }
  },

  _renderRemoteVideo: function(user) {
    const el = document.getElementById("agora-remote-video");
    if (el && user && user.videoTrack) {
      el.innerHTML = "";
      user.videoTrack.play(el);
      console.log("[AgoraWeb] Remote video mounted in container for uid:", user.uid);
    }
  },

  leaveChannel: async function() {
    console.log("[AgoraWeb] Leaving channel...");
    try {
      if (this.localAudioTrack) {
        this.localAudioTrack.stop();
        this.localAudioTrack.close();
        this.localAudioTrack = null;
      }
      if (this.localVideoTrack) {
        this.localVideoTrack.stop();
        this.localVideoTrack.close();
        this.localVideoTrack = null;
      }
      if (this.client) {
        await this.client.leave();
      }
      this.remoteUsers = {};
      console.log("[AgoraWeb] Left channel cleanly");
    } catch (e) {
      console.warn("[AgoraWeb] Error leaving channel:", e);
    }
  },

  muteLocalAudio: function(mute) {
    if (this.localAudioTrack) {
      this.localAudioTrack.setEnabled(!mute);
      console.log("[AgoraWeb] Mic enabled:", !mute);
    }
  },

  muteLocalVideo: function(mute) {
    if (this.localVideoTrack) {
      this.localVideoTrack.setEnabled(!mute);
      console.log("[AgoraWeb] Camera enabled:", !mute);
    }
  },

  switchCamera: async function() {
    if (!this.localVideoTrack) return;
    try {
      const cams = await AgoraRTC.getCameras();
      if (cams.length > 1) {
        const cur = this.localVideoTrack.getTrackLabel();
        const nextCam = cams.find(c => c.label !== cur) || cams[0];
        await this.localVideoTrack.setDevice(nextCam.deviceId);
        console.log("[AgoraWeb] Switched camera to:", nextCam.label);
      }
    } catch (e) {
      console.warn("[AgoraWeb] switchCamera error:", e);
    }
  }
};
