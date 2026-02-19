import 'package:flashform_app/data/model/user.dart';
import 'package:flashform_app/data/repository/user_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class UserControllerState {
  const UserControllerState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final User? user;
  final bool isLoading;
  final String? error;

  UserControllerState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserControllerState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final userControllerProvider =
    StateNotifierProvider<UserController, UserControllerState>(
  (ref) => UserController(ref.watch(userRepoProvider)),
);

class UserController extends StateNotifier<UserControllerState> {
  UserController(this._repository) : super(const UserControllerState());

  final UserRepository _repository;

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.getProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile({required String name}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.updateProfile(name: name);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}
