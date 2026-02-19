import 'package:flashform_app/data/model/payment.dart';
import 'package:flashform_app/data/model/subscription.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, SupabaseClient, AuthException;

final subscriptionRepoProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepository(ref.watch(supabaseAuthProvider)),
);

class SubscriptionRepository {
  SubscriptionRepository(this._supabase);

  final Supabase _supabase;

  SupabaseClient get _client => _supabase.client;

  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('User not logged in');
    return userId;
  }

  // Получить текущую активную подписку
  Future<Subscription?> getActiveSubscription() async {
    final response = await _client
        .from('subscriptions')
        .select()
        .eq('user_id', _currentUserId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Subscription.fromJson(response);
  }

  // История подписок
  Future<List<Subscription>> getSubscriptionHistory() async {
    final response = await _client
        .from('subscriptions')
        .select()
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false);

    return response.map((json) => Subscription.fromJson(json)).toList();
  }

  // История платежей
  Future<List<Payment>> getPaymentHistory() async {
    final response = await _client
        .from('payments')
        .select()
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false);

    return response.map((json) => Payment.fromJson(json)).toList();
  }

  // Создать подписку (вызывается после успешной оплаты)
  Future<Subscription> createSubscription({
    required SubscriptionPlan plan,
    required DateTime expiresAt,
    bool autoRenew = true,
  }) async {
    final userId = _currentUserId;

    // Деактивируем старую подписку
    await _client
        .from('subscriptions')
        .update({'status': 'cancelled'})
        .eq('user_id', userId)
        .eq('status', 'active');

    // Создаём новую
    final response = await _client
        .from('subscriptions')
        .insert({
          'user_id': userId,
          'plan': plan.name,
          'status': 'active',
          'auto_renew': autoRenew,
          'started_at': DateTime.now().toIso8601String(),
          'expires_at': expiresAt.toIso8601String(),
        })
        .select()
        .single();

    // Обновляем план в таблице users
    await _client.from('users').update({
      'plan': plan.name,
      'plan_expires_at': expiresAt.toIso8601String(),
    }).eq('id', userId);

    return Subscription.fromJson(response);
  }

  // Отменить автопродление
  Future<void> cancelAutoRenew() async {
    await _client
        .from('subscriptions')
        .update({'auto_renew': false})
        .eq('user_id', _currentUserId)
        .eq('status', 'active');
  }

  // Создать запись об оплате (pending) - до перехода на платёжный шлюз
  Future<Payment> createPendingPayment({
    required String subscriptionId,
    required double amount,
    required PaymentProvider provider,
  }) async {
    final response = await _client
        .from('payments')
        .insert({
          'user_id': _currentUserId,
          'subscription_id': subscriptionId,
          'amount': amount,
          'currency': 'KZT',
          'status': 'pending',
          'provider': provider.name,
        })
        .select()
        .single();

    return Payment.fromJson(response);
  }
}
