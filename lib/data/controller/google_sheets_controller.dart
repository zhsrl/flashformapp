import 'package:flashform_app/data/repository/google_sheets_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final googleSheetsIntegrationProvider =
    FutureProvider.family<GoogleSheetsIntegration?, String>((
      ref,
      formId,
    ) async {
      final repo = ref.watch(googleSheetsRepoProvider);
      return repo.getIntegration(formId);
    });

final googleSheetsIntegrationControllerProvider =
    StateNotifierProvider<GoogleSheetsIntegrationController, AsyncValue<void>>((
      ref,
    ) {
      return GoogleSheetsIntegrationController(ref);
    });

class GoogleSheetsIntegrationController
    extends StateNotifier<AsyncValue<void>> {
  GoogleSheetsIntegrationController(this._ref)
    : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> saveSettings({
    required String formId,
    required String spreadsheetId,
    required String sheetName,
    required bool sendUtm,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref
          .read(googleSheetsRepoProvider)
          .upsertSettings(
            formId: formId,
            spreadsheetId: spreadsheetId,
            sheetName: sheetName,
            sendUtm: sendUtm,
          );
    });
  }

  Future<void> disconnect(String formId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ref.read(googleSheetsRepoProvider).disconnect(formId);
    });
  }

  Future<GoogleSheetsCreateResult> createSpreadsheet({
    required String formId,
    required String title,
    required String sheetName,
  }) async {
    state = const AsyncValue.loading();
    final result = await _ref
        .read(googleSheetsRepoProvider)
        .createSpreadsheet(
          formId: formId,
          title: title,
          sheetName: sheetName,
        );
    state = const AsyncValue.data(null);
    return result;
  }
}
