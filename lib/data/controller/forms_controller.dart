import 'dart:async';

import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/data/service/form_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formControllerProvider =
    AsyncNotifierProvider<FormController, List<FormModel>>(FormController.new);

class FormController extends AsyncNotifier<List<FormModel>> {
  @override
  FutureOr<List<FormModel>> build() {
    final repository = ref.watch(formRepoProvider);
    return repository.getAllForms();
  }

  Future<FormModel> fetchForm(String formId) async {
    final repository = ref.watch(formRepoProvider);

    return await repository.getSingleForm(formId);
  }

  Future<String?> createNewForm(String name) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(formServiceProvider);

      final newForm = await service.createNewForm(name);

      final oldList = state.value ?? [];

      state = AsyncData([newForm, ...oldList]);

      return newForm.id;
    } catch (e, st) {
      state = AsyncError(e, st);

      return null;
    }
  }

  Future<void> publishForm(Map<String, dynamic> data) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final repository = ref.read(formRepoProvider);

        await repository.publishForm(data);

        return repository.getAllForms();
      },
    );
  }

  Future<void> saveForm(Map<String, dynamic> data) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final repository = ref.read(formRepoProvider);

        await repository.saveForm(data);

        return repository.getAllForms();
      },
    );
  }
}
