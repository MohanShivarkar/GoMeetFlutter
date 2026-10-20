// web/agora_web_helper.js
// WebRTC calling bridge and Web Notifications for LoveCloud PWA using Agora Web SDK NG (v4.x)

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

  _ringtoneAudioCtx: null,
  _ringtoneInterval: null,

  // --- Web Notification & Ringtone Methods ---
  requestNotificationPermission: async function() {
    if (!("Notification" in window)) {
      console.log("[AgoraWeb] Web Notifications not supported in this browser");
      return false;
    }
    if (Notification.permission === "granted") {
      return true;
    }
    if (Notification.permission !== "denied") {
      try {
        const permission = await Notification.requestPermission();
        console.log("[AgoraWeb] Notification permission result:", permission);
        return permission === "granted";
      } catch(e) {
        console.warn("[AgoraWeb] Notification permission error:", e);
        return false;
      }
    }
    return false;
  },

  showWebNotification: function(title, body, icon) {
    if (!("Notification" in window) || Notification.permission !== "granted") {
      return;
    }
    try {
      const options = {
        body: body || "",
        icon: icon || "icons/Icon-192.png",
        badge: "icons/Icon-192.png",
        tag: "lovecloud-" + Date.now(),
        renotify: true,
        vibrate: [200, 100, 200]
      };
      const notif = new Notification(title, options);
      notif.onclick = function() {
        window.focus();
        notif.close();
      };
      setTimeout(() => { try { notif.close(); } catch(e) {} }, 8000);
    } catch(e) {
      console.warn("[AgoraWeb] showWebNotification error:", e);
    }
  },

  playRingtone: function() {
    this.stopRingtone();
    try {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (!AudioCtx) return;
      this._ringtoneAudioCtx = new AudioCtx();
      if (this._ringtoneAudioCtx.state === 'suspended') {
        this._ringtoneAudioCtx.resume();
      }

      const playBurst = () => {
        if (!this._ringtoneAudioCtx || this._ringtoneAudioCtx.state === 'closed') return;
        try {
          const now = this._ringtoneAudioCtx.currentTime;
          // Dual frequency ringback tone: 440Hz + 480Hz
          const osc1 = this._ringtoneAudioCtx.createOscillator();
          const osc2 = this._ringtoneAudioCtx.createOscillator();
          const gain = this._ringtoneAudioCtx.createGain();

          osc1.frequency.value = 440;
          osc2.frequency.value = 480;

          gain.gain.setValueAtTime(0.001, now);
          gain.gain.exponentialRampToValueAtTime(0.18, now + 0.05);
          gain.gain.setValueAtTime(0.18, now + 1.8);
          gain.gain.exponentialRampToValueAtTime(0.001, now + 1.95);

          osc1.connect(gain);
          osc2.connect(gain);
          gain.connect(this._ringtoneAudioCtx.destination);

          osc1.start(now);
          osc2.start(now);
          osc1.stop(now + 2.0);
          osc2.stop(now + 2.0);
        } catch(e) {
          console.warn("[AgoraWeb] playBurst error:", e);
        }
      };

      playBurst();
      this._ringtoneInterval = setInterval(playBurst, 4000);
      console.log("[AgoraWeb] Ringtone started");
    } catch(err) {
      console.warn("[AgoraWeb] Ringtone failed to start:", err);
    }
  },

  stopRingtone: function() {
    if (this._ringtoneInterval) {
      clearInterval(this._ringtoneInterval);
      this._ringtoneInterval = null;
    }
    if (this._ringtoneAudioCtx) {
      try { this._ringtoneAudioCtx.close(); } catch(e) {}
      this._ringtoneAudioCtx = null;
    }
    console.log("[AgoraWeb] Ringtone stopped");
  },

  // --- Agora Container Registration & Shadow DOM Traversal ---
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
    if (this.containers[id] && (this.containers[id].isConnected || document.contains(this.containers[id]))) {
      return this.containers[id];
    }
    if (this.containers[id]) return this.containers[id];

    // Check direct ID in light DOM
    let el = document.getElementById(id);
    if (el) return el;

    // Check flt-glass-pane shadowRoot explicitly
    const flt = document.querySelector('flt-glass-pane');
    if (flt && flt.shadowRoot) {
      const found = flt.shadowRoot.getElementById ? flt.shadowRoot.getElementById(id) : flt.shadowRoot.querySelector('#' + id);
      if (found) return found;
    }

    // Traverse all DOM and shadow roots
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
    return findInTree(document.body) || null;
  },

  // --- Client Lifecycle ---
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

  _renderLocalVideo: function(retries = 20) {
    if (!this.localVideoTrack) return;
    const el = this._findContainer("agora-local-video");
    if (el) {
      el.innerHTML = "";
      el.style.width = "100%";
      el.style.height = "100%";
      el.style.position = "relative";
      this.localVideoTrack.play(el, { fit: "cover" });
      console.log("[AgoraWeb] Local video mounted in container");
    } else if (retries > 0) {
      setTimeout(() => this._renderLocalVideo(retries - 1), 200);
    } else {
      console.warn("[AgoraWeb] Container #agora-local-video not found after retries");
    }
  },

  _renderRemoteVideo: function(user, retries = 20) {
    if (!user || !user.videoTrack) return;
    const el = this._findContainer("agora-remote-video");
    if (el) {
      el.innerHTML = "";
      el.style.width = "100%";
      el.style.height = "100%";
      el.style.position = "absolute";
      el.style.top = "0";
      el.style.left = "0";
      user.videoTrack.play(el, { fit: "cover" });
      console.log("[AgoraWeb] Remote video mounted in container for uid:", user.uid);
    } else if (retries > 0) {
      setTimeout(() => this._renderRemoteVideo(user, retries - 1), 200);
    } else {
      console.warn("[AgoraWeb] Container #agora-remote-video not found after retries for uid:", user.uid);
    }
  },

  leaveChannel: async function() {
    console.log("[AgoraWeb] Leaving channel...");
    this.stopRingtone();
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
