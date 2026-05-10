import 'package:http/http.dart' as http;
import 'dart:convert';

class XPaymentService {
  final String baseUrl =
      'https://editor.fform.me/api/payments'; // ← Меняем на свой маршрут

  // Создать платеж
  Future<Map<String, dynamic>> createPayment({
    required String payerPhone,
    required int amount,
    required String merchantOrderId,
    String comment = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl'), // ← Теперь вызываем свой backend
      headers: {
        'Content-Type': 'application/json',
        // ← API ключ больше не нужен здесь!
      },
      body: jsonEncode({
        'payer_phone': payerPhone,
        'amount': amount,
        'merchant_order_id': merchantOrderId,
        'comment': comment,
        'currency': 'KZT',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment: ${response.body}');
    }
  }

  // Получить статус платежа
  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment: ${response.body}');
    }
  }

  // Создать QR ссылку
  Future<String> createQrLink({
    required int amount,
    required String merchantOrderId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/link'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'merchant_order_id': merchantOrderId,
        'device_interface': 'Pos',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['qr_token'];
    } else {
      throw Exception('Failed to create QR link: ${response.body}');
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
