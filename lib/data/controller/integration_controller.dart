import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final metaPixelControllerProvider =
    StateNotifierProvider<MetaPixelController, AsyncValue<String>>((
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

  Future<void> save(String formId) async {
    final formState = _ref.read(createFormProvider);

    if (formState.metaPixelId == '') {
      state = const AsyncValue.data('');
      return;
    }

    state = await AsyncValue.guard(() async {
      await _ref
          .read(formRepoProvider)
          .setMetaPixelId(formId, formState.metaPixelId);

      return formState.metaPixelId;
    });
  }

  Future<void> delete(String formId) async {
    final formState = _ref.read(createFormProvider);

    state = await AsyncValue.guard(() async {
      await _ref.read(formRepoProvider).deleteMetaPixelId(formId);

      return formState.metaPixelId;
    });
  }

  Future<String> get(String formId) async {
    state = AsyncLoading();
    final response = await _ref.read(formRepoProvider).getMetaPixelId(formId);

    state = AsyncData(response);

    return response;
  }
}

class YandexMetrikaController extends StateNotifier<AsyncValue<String>> {
  YandexMetrikaController(this._ref) : super(const AsyncValue.data(''));

  final Ref _ref;

  Future<void> save(String formId) async {
    final formState = _ref.read(createFormProvider);

    if (formState.metaPixelId == '') {
      state = const AsyncValue.data('');
      return;
    }

    state = await AsyncValue.guard(() async {
      await _ref
          .read(formRepoProvider)
          .setYandexMetrikaId(formId, formState.yandexMetrikaId);

      return formState.metaPixelId;
    });
  }

  Future<void> delete(String formId) async {
    final formState = _ref.read(createFormProvider);

    state = await AsyncValue.guard(() async {
      await _ref.read(formRepoProvider).deleteYandexMetrikaId(formId);

      return formState.metaPixelId;
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
