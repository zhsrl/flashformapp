import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashform_app/data/service/payment_service.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final paymentControllerProvider =
    StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) {
      return PaymentController(ref.read(paymentServiceProvider));
    });

class PaymentController extends StateNotifier<AsyncValue<void>> {
  final PaymentService _paymentService;

  PaymentController(this._paymentService) : super(const AsyncValue.data(null));

  // Инициировать платеж
  Future<String?> initiatePayment({
    required String phoneNumber,
    required int amount,
    required String planId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final paymentId = await _paymentService.createPayment(
        payerPhone: phoneNumber,
        amount: amount,
        merchantOrderId: planId,
        userId: userId,
        planId: planId,
        comment: 'Plan upgrade: $planId',
      );

      if (paymentId != null) {
        print('💳 Payment created: $paymentId');
      } else {
        throw Exception('Payment ID is null - API error');
      }

      state = const AsyncValue.data(null);
      return paymentId;
    } catch (e, st) {
      print('❌ Payment error: $e');
      state = AsyncValue.error(e, st);
      rethrow; // Пробрасываем ошибку в UI
    }
  }
}
