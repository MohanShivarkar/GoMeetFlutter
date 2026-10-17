import 'package:flutter/material.dart';
import 'app_download_helper_stub.dart'
    if (dart.library.html) 'app_download_helper_web.dart';

class AppDownloadHelper {
  static void downloadApk({String url = '/app/lovecloud.apk', String filename = 'lovecloud.apk'}) {
    downloadApkImpl(url: url, filename: filename);
  }

  static void triggerPwaInstall() {
    triggerPwaInstallImpl();
  }

  static void showInstallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161224),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFFF9933), Color(0xFFFF4458)]),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.install_mobile_rounded, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                "Install LoveCloud App",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Install LoveCloud on your phone for full-screen mode, faster loading, and notifications:",
                style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 16),
              // Android Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.android_rounded, color: Color(0xFF4CAF50), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Android Phone",
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Option A: Tap 'Install Web App' below.\nOption B: In Chrome menu (⋮) tap 'Install app' or 'Add to Home screen'.",
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          triggerPwaInstall();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text("Install Web App Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // iOS Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.apple_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 8),
                        Text(
                          "iPhone (iOS)",
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "1. Open LoveCloud in Safari\n2. Tap the Share button (⍐) at bottom\n3. Tap 'Add to Home Screen' (⊞)\n4. Tap 'Add' in top right",
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
