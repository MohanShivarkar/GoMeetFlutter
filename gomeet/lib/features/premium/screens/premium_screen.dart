import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gomeet/features/premium/widgets/premium_web_notice_widget.dart';

// razorpay_flutter does not support web. The kIsWeb guard in build() ensures
// this code path is unreachable on web. If the package lacks a web stub and
// causes a dart2js compilation error, extract payment logic to:
//   lib/features/premium/payment/payment_service.dart  (conditional import shim)
//   lib/features/premium/payment/payment_service_mobile.dart  (razorpay)
//   lib/features/premium/payment/payment_service_web.dart  (no-op or future Razorpay web)
// Document this in p1-010 if it surfaces as a build error.

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  Widget build(BuildContext context) {
    // Razorpay payment flow is not available on web in v1.
    if (kIsWeb) {
      return const Scaffold(
        body: PremiumWebNoticeWidget(),
      );
    }

    // --- Existing mobile premium build logic follows unchanged ---
    // TODO: Implement mobile premium subscription flow with Razorpay
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoMeet Premium'),
      ),
      body: Center(
        child: Text(
          'Premium subscription page (mobile)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
