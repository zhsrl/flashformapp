import 'package:flashform_app/data/model/user.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, SupabaseClient, AuthException;

final userRepoProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(supabaseAuthProvider)),
);

class UserRepository {
  UserRepository(this._supabase);

  final Supabase _supabase;

  SupabaseClient get _client => _supabase.client;

  Future<User> getProfile() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw const AuthException('User not logged in');
    }

    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Ошибка загрузки профиля: $e');
    }
  }

  Future<User> updateProfile({required String name}) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('users')
        .update({'name': name})
        .eq('id', currentUser.id)
        .select()
        .single();

    return User.fromJson(response);
  }
}
