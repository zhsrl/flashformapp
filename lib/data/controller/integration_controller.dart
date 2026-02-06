import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final metaPixelControllerProvider =
    StateNotifierProvider.autoDispose<MetaPixelController, AsyncValue<String>>((
      ref,
    ) {
      return MetaPixelController(ref);
    });

final yandexMetrikaControllerProvider =
    StateNotifierProvider.autoDispose<
      YandexMetrikaController,
      AsyncValue<String>
    >((ref) {
      return YandexMetrikaController(ref);
    });

class MetaPixelController extends StateNotifier<AsyncValue<String>> {
  MetaPixelController(this._ref) : super(const AsyncValue.data(''));

  final Ref _ref;

  Future<void> save(String formId, String pixelId) async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _ref.read(formRepoProvider).setMetaPixelId(formId, pixelId);

      return pixelId;
    });
  }

  Future<void> get(String formId) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await _ref.read(formRepoProvider).getMetaPixelId(formId);

      return response;
    });
  }
}

class YandexMetrikaController extends StateNotifier<AsyncValue<String>> {
  YandexMetrikaController(this._ref) : super(const AsyncValue.data(''));

  final Ref _ref;

  Future<void> save(String formId, String pixelId) async {
    state = AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _ref.read(formRepoProvider).setYandexMetrikaId(formId, pixelId);

      return pixelId;
    });
  }

  Future<String> get(String formId) async {
    state = AsyncLoading();
    final response = await _ref
        .read(formRepoProvider)
        .getYandexMetrikaId(formId);

    state = AsyncData(response);

    return response;
  }
}
