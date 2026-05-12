import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

class PaymentService {
  // Измените на URL вашего API проекта на Vercel
  final String baseUrl = 'https://flashformpayment.vercel.app/api/payment';

  // Создать платеж
  Future<String?> createPayment({
    required String payerPhone,
    required int amount,
    required String merchantOrderId,
    required String userId,
    required String planId,
    String comment = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payer_phone': payerPhone,
          'amount': amount,
          'merchant_order_id': merchantOrderId,
          'comment': comment,
          'currency': 'KZT',
          'user_id': userId,
          'plan_id': planId,
        }),
      );

      print('🔍 API Response status: ${response.statusCode}');
      print('🔍 API Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Пытаемся получить payment_id из разных возможных полей
        final paymentId =
            data['payment_id'] ??
            data['id'] ??
            data['paymentId'] ??
            data['result'];

        if (paymentId == null) {
          print('❌ No payment ID found in response: $data');
          throw Exception('Payment ID not found in response');
        }

        print('✅ Payment ID extracted: $paymentId');
        return paymentId.toString();
      } else {
        throw Exception(
          'Failed to create payment: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error creating payment: $e');
      rethrow;
    }
  }

  // Получить статус платежа
  Future<String> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?paymentId=$paymentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'pending';
      } else {
        throw Exception('Failed to get payment status: ${response.body}');
      }
    } catch (e) {
      print('Error getting payment status: $e');
      return 'unknown';
    }
  }

  // Создать QR ссылку
  Future<String?> createQrLink({
    required int amount,
    required String merchantOrderId,
    required String planId,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'merchant_order_id': merchantOrderId,
          'device_interface': 'Pos',
          'plan_id': planId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final qrToken =
            data['qr_token'] ??
            data['qrToken'] ??
            data['token'] ??
            (data['data'] is Map<String, dynamic>
                ? data['data']['qr_token'] ?? data['data']['qrToken']
                : null);

        if (qrToken == null || qrToken.toString().isEmpty) {
          throw Exception('QR token not found in response');
        }

        return qrToken.toString();
      } else {
        throw Exception(
          'Failed to create QR link: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating QR link: $e');
      return null;
    }
  }

  // Отменить платеж
  Future<void> cancelPayment(String paymentId, String reason) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$paymentId/cancel'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel payment: ${response.body}');
    }
  }

  // Сделать возврат
  Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    required int amount,
    required String reason,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$paymentId/refund'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to refund payment: ${response.body}');
    }
  }
}
