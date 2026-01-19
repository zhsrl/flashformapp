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

  // CREATE NEW USER BY ONE-TIME-PASSWORD (OTP)
  // First step. Send code to email
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
      throw Exception(e);
    } catch (e) {
      throw Exception(e);
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
}
