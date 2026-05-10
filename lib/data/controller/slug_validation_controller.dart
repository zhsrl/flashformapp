import 'dart:async';

import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final slugValidationProvider =
    AsyncNotifierProvider.autoDispose<SlugValidationController, bool?>(
      SlugValidationController.new,
    );

class SlugValidationController extends AsyncNotifier<bool?> {
  Timer? _debounceTimer;
  @override
  FutureOr<bool?> build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return null;
  }

  void onSlugChanged(String slug) {
    _debounceTimer?.cancel();

    if (slug.isEmpty) {
      state = AsyncData(null);
      return;
    }

    state = AsyncLoading();

    _debounceTimer = Timer(
      Duration(milliseconds: 500),
      () async {
        try {
          final repo = ref.read(formRepoProvider);

          final isAvailable = await repo.isSlugAvailable(slug);

          state = AsyncData(isAvailable);
        } catch (e, st) {
          state = AsyncError(e, st);
        }
      },
    );
  }
}
