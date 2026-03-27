import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseAuthProvider = Provider<Supabase>((ref) => Supabase.instance);
final authRepoProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseAuthProvider)),
);

class AuthRepository {
  AuthRepository(this._supabase);

  final Supabase _supabase;

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signUpWithOTP(String email) async {
    try {
      await _supabase.client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
    } on AuthException catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      await _supabase.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );
    } on AuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Second step. Verify account
  Future<void> verifyOtp(String email, String code) async {
    try {
      await _supabase.client.auth.verifyOTP(
        type: OtpType.email,
        email: email.trim(),
        token: code.trim(),
      );
    } on AuthException catch (e) {
      throw Exception(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? '${Uri.base.origin}/reset-password' : null,
      );
    } on AuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> setNewPassword(String newPassword) async {
    try {
      await _supabase.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.client.auth.signOut(
        scope: SignOutScope.local,
      );
    } on AuthException catch (e) {
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Verify old password by trying to sign in
      final currentUser = _supabase.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Get email from current user
      final email = currentUser.email;
      if (email == null) {
        throw Exception('User email not found');
      }

      // Verify old password
      try {
        await _supabase.client.auth.signInWithPassword(
          email: email,
          password: oldPassword,
        );
      } on AuthException {
        throw Exception('Неверный текущий пароль');
      }

      // Update password
      await _supabase.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Ошибка смены пароля: ${e.message}');
    }
  }
}
