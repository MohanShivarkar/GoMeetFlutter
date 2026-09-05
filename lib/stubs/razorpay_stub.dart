// lib/stubs/razorpay_stub.dart
//
// Web stub for razorpay_flutter.
// Selected by conditional import when dart.library.html is available.
// All payment operations are no-ops on web.

// ignore_for_file: avoid_classes_with_only_static_members

class Razorpay {
  static const String EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const String EVENT_PAYMENT_ERROR = 'payment.error';
  static const String EVENT_EXTERNAL_WALLET = 'payment.external_wallet';

  void open(Map<String, dynamic> options) {}
  void on(String event, Function handler) {}
  void clear() {}
}

class PaymentSuccessResponse {
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final Map<dynamic, dynamic>? data;
  PaymentSuccessResponse(this.paymentId, this.orderId, this.signature, [this.data]);
}

class PaymentFailureResponse {
  final int? code;
  final String? message;
  final Map<dynamic, dynamic>? error;
  PaymentFailureResponse(this.code, this.message, [this.error]);
}

class ExternalWalletResponse {
  final String? walletName;
  ExternalWalletResponse(this.walletName);
}
