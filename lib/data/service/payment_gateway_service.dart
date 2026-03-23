import 'dart:async';

import 'package:flashform_app/data/model/payment.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentGatewayServiceProvider = Provider<PaymentGatewayService>(
  (ref) => const MockPaymentGatewayService(),
);

enum CheckoutStatus {
  success,
  cancelled,
  failed,
}

class CheckoutResult {
  const CheckoutResult({
    required this.status,
    this.providerTxId,
    this.message,
  });

  final CheckoutStatus status;
  final String? providerTxId;
  final String? message;
}

abstract class PaymentGatewayService {
  Future<CheckoutResult> startCheckout({
    required Payment payment,
    required SubscriptionPlan plan,
    required PaymentProvider provider,
  });
}

class MockPaymentGatewayService implements PaymentGatewayService {
  const MockPaymentGatewayService({
    this.simulateSuccess = true,
    this.delay = const Duration(milliseconds: 1200),
  });

  final bool simulateSuccess;
  final Duration delay;

  @override
  Future<CheckoutResult> startCheckout({
    required Payment payment,
    required SubscriptionPlan plan,
    required PaymentProvider provider,
  }) async {
    await Future<void>.delayed(delay);

    if (!simulateSuccess) {
      return CheckoutResult(
        status: CheckoutStatus.failed,
        message: 'payment.test_declined'.tr(),
      );
    }

    return CheckoutResult(
      status: CheckoutStatus.success,
      providerTxId:
          'mock-${provider.name}-${plan.name}-${DateTime.now().millisecondsSinceEpoch}',
      message: 'payment.test_confirmed'.tr(),
    );
  }
}
