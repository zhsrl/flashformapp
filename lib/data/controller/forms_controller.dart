import 'dart:async';

import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/data/repository/storage_repository.dart';
import 'package:flashform_app/data/service/form_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formControllerProvider =
    AsyncNotifierProvider.autoDispose<FormController, List<FormModel>>(
      FormController.new,
    );

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
    // state = AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final repository = ref.read(formRepoProvider);

        await repository.publishForm(data);

        return repository.getAllForms();
      },
    );
  }

  Future<void> unpublishForm(String formId) async {
    // state = AsyncLoading();

    state = await AsyncValue.guard(
      () async {
        final repository = ref.read(formRepoProvider);

        await repository.unpublishForm(formId);

        return repository.getAllForms();
      },
    );
  }

  Future<void> updateFormName(
    String name,
    String id,
  ) async {
    // state = AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        final repository = ref.read(formRepoProvider);

        await repository.updateFormName(name, id);

        return repository.getAllForms();
      },
    );
  }

  Future<void> updateFormSlug(
    String newSlug,
    String id,
  ) async {
    state = await AsyncValue.guard(() async {
      final repository = ref.read(formRepoProvider);
      await repository.updateFormSlug(id, newSlug);

      return repository.getAllForms();
    });
  }

  Future<void> deleteForm(String formId, {String? imageUrl}) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(
      () async {
        try {
          // Если есть фото — удаляем из Storage
          if (imageUrl != null && imageUrl.isNotEmpty) {
            debugPrint('🗑️ Deleting image: $imageUrl');
            final storageRepo = ref.read(storageRepoProvider);
            await storageRepo.deleteImage(imageUrl);
            debugPrint('✅ Image deleted successfully');
          }

          debugPrint('🗑️ Deleting form: $formId');
          final repository = ref.read(formRepoProvider);
          await repository.deleteForm(formId);
          debugPrint('✅ Form deleted successfully');

          return repository.getAllForms();
        } catch (e) {
          debugPrint('❌ Error deleting form: $e');
          rethrow;
        }
      },
    );
  }
}
