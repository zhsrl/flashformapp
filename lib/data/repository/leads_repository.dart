import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final leadsRepoProvider = Provider<LeadsRepository>(
  (ref) => LeadsRepository(ref.watch(supabaseAuthProvider)),
);

class LeadsRepository {
  LeadsRepository(this._supabase);

  final Supabase _supabase;
  static const int pageSize = 20;

  SupabaseClient get _client => _supabase.client;
  User? get _currentUser => _client.auth.currentUser;

  Future<List<Lead>> getLeadsByFormId(
    String formId, {
    required int offset,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('leads')
        .select()
        .eq('form_id', formId)
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((json) => Lead.fromJson(json)).toList();
  }

  Future<int> getLeadsCount(String formId) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('leads')
        .select('*')
        .eq('form_id', formId)
        .count(CountOption.exact);

    return response.count;
  }
}
