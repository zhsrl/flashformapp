import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
      (ref) => AuthController(ref.watch(authRepoProvider)),
    );

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> signUpWithOtp(String email) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signUpWithOTP(email));
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.signUpWithEmailAndPassword(email, password, name),
    );
  }

  Future<void> verifyOtp(String email, String code) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.verifyOtp(email, code));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signOut());
  }
}
