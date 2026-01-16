import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref.watch(authRepoProvider)),
);

class AuthController extends StateNotifier<bool> {
  AuthController(this._repository) : super(false);
  final AuthRepository _repository;

  Future<void> signIn(String email, String password) async {
    state = true;
    try {
      await _repository.signInWithEmailAndPassword(email, password);
    } finally {
      state = false;
    }
  }

  Future<void> signUpWithOtp(String email) async {
    state = true;
    try {
      await _repository.signUpWithOTP(email);
    } finally {
      state = false;
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    state = true;
    try {
      await _repository.signUpWithEmailAndPassword(email, password, name);
    } finally {
      state = false;
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    state = true;
    try {
      await _repository.verifyOtp(email, code);
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    state = true;
    try {
      await _repository.signOut();
    } finally {
      state = false;
    }
  }
}
