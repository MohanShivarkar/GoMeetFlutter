import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Wraps [child] and overlays a slim dismissable banner at the top of the
/// screen whenever network connectivity is lost.
///
/// In production, [connectivityStream] defaults to
/// [Connectivity.onConnectivityChanged]. Pass a custom stream in tests
/// to control connectivity state without calling the real plugin.
///
/// Designed to be placed at the outermost widget layer so it overlays
/// all screens in the app shell.
///
/// UI reference: docs/office/05-ui-designs/05-pwa-install.html (Panel B –
/// offline shell state). Brand colour: #FF4458 (rose). Banner is slim
/// (≈44 px), non-blocking, and dismissable by the user.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  /// Override the connectivity stream (for testing only).
  ///
  /// When omitted the widget listens to [Connectivity.onConnectivityChanged]
  /// and checks the current state with [Connectivity.checkConnectivity] on
  /// startup.
  final Stream<ConnectivityResult>? connectivityStream;

  const OfflineBanner({
    super.key,
    required this.child,
    this.connectivityStream,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  StreamSubscription<ConnectivityResult>? _subscription;

  Stream<ConnectivityResult> get _effectiveStream =>
      widget.connectivityStream ?? Connectivity().onConnectivityChanged;

  @override
  void initState() {
    super.initState();
    _subscription = _effectiveStream.listen(_handleConnectivity);

    // Check initial connectivity only when using the real plugin stream.
    // Injected test streams control the initial state themselves.
    if (widget.connectivityStream == null) {
      Connectivity().checkConnectivity().then((result) {
        if (mounted) _handleConnectivity(result);
      });
    }
  }

  void _handleConnectivity(ConnectivityResult result) {
    setState(() {
      _isOffline = result == ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _OfflineBannerStrip(
              onDismiss: () => setState(() => _isOffline = false),
            ),
          ),
      ],
    );
  }
}

/// The visible banner strip — rose branded, slim, dismissable.
class _OfflineBannerStrip extends StatelessWidget {
  final VoidCallback onDismiss;

  const _OfflineBannerStrip({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xFFFF4458),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'You are offline — connect to continue.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
