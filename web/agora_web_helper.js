// web/agora_web_helper.js
// WebRTC calling bridge for LoveCloud PWA using Agora Web SDK NG (v4.x)

window.agoraWebBridge = {
  client: null,
  appId: null,
  channel: null,
  localAudioTrack: null,
  localVideoTrack: null,
  remoteUsers: {},
  containers: {},
  onJoinSuccessCallback: null,
  onUserJoinedCallback: null,
  onUserOfflineCallback: null,

  onContainerCreated: function(id, el) {
    console.log("[AgoraWeb] Container created from Flutter:", id, el);
    this.containers[id] = el;
    if (id === 'agora-local-video' && this.localVideoTrack) {
      this._renderLocalVideo();
    }
    if (id === 'agora-remote-video') {
      const uids = Object.keys(this.remoteUsers);
      if (uids.length > 0) {
        const lastUser = this.remoteUsers[uids[uids.length - 1]];
        this._renderRemoteVideo(lastUser);
      }
    }
  },

  _findContainer: function(id) {
    if (this.containers[id] && document.contains(this.containers[id])) {
      return this.containers[id];
    }
    let el = document.getElementById(id);
    if (el) return el;

    function findInTree(root) {
      if (!root) return null;
      if (root.getElementById) {
        const found = root.getElementById(id);
        if (found) return found;
      }
      if (root.querySelector) {
        const found = root.querySelector('#' + id);
        if (found) return found;
      }
      const children = root.children || [];
      for (let i = 0; i < children.length; i++) {
        if (children[i].shadowRoot) {
          const found = findInTree(children[i].shadowRoot);
          if (found) return found;
        }
      }
      return null;
    }
    return findInTree(document.body) || this.containers[id] || null;
  },

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

    if (AgoraRTC.onAudioAutoplayFailed) {
      AgoraRTC.onAudioAutoplayFailed = () => {
        console.warn("[AgoraWeb] Audio autoplay blocked. Waiting for user interaction to resume...");
        const unlock = () => {
          AgoraRTC.resumeAudio();
          console.log("[AgoraWeb] Audio resumed via user interaction");
          window.removeEventListener("click", unlock);
          window.removeEventListener("touchstart", unlock);
        };
        window.addEventListener("click", unlock, { once: true });
        window.addEventListener("touchstart", unlock, { once: true });
      };
    }

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

  _renderLocalVideo: function(retries = 15) {
    if (!this.localVideoTrack) return;
    const el = this._findContainer("agora-local-video");
    if (el) {
      el.innerHTML = "";
      this.localVideoTrack.play(el);
      console.log("[AgoraWeb] Local video mounted in container");
    } else if (retries > 0) {
      setTimeout(() => this._renderLocalVideo(retries - 1), 200);
    } else {
      console.warn("[AgoraWeb] Container #agora-local-video not found after retries");
    }
  },

  _renderRemoteVideo: function(user, retries = 15) {
    if (!user || !user.videoTrack) return;
    const el = this._findContainer("agora-remote-video");
    if (el) {
      el.innerHTML = "";
      user.videoTrack.play(el);
      console.log("[AgoraWeb] Remote video mounted in container for uid:", user.uid);
    } else if (retries > 0) {
      setTimeout(() => this._renderRemoteVideo(user, retries - 1), 200);
    } else {
      console.warn("[AgoraWeb] Container #agora-remote-video not found after retries for uid:", user.uid);
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
