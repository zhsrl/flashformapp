import 'package:flashform_app/data/model/payment.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final paymentsRepoProvider = Provider<PaymentsRepository>(
  (ref) => PaymentsRepository(ref.watch(supabaseAuthProvider)),
);

class PaymentsRepository {
  const PaymentsRepository(this._supabase);

  final Supabase _supabase;

  SupabaseClient get _client => _supabase.client;
  User? get _currentUser => _client.auth.currentUser;

  Future<List<Payment>?> getAllPayments() async {
    if (_currentUser == null) {
      throw AuthException('User not logged in');
    }

    final response = await _client
        .from('payments')
        .select(
          'id, user_id, subscription_id, amount, provider, status, paid_at, created_at, subscriptions(plan)',
        )
        .eq('user_id', _currentUser!.id)
        .order('created_at', ascending: false);

    return response.map((json) => Payment.fromJson(json)).toList();
  }
}
