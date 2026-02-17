import 'dart:async';
import 'package:flashform_app/data/repository/leads_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Предполагается, что у вас есть провайдер для репозитория.
// final leadsRepositoryProvider = Provider<LeadsRepository>((ref) => LeadsRepository());

// 2. Правильное объявление AsyncNotifierProvider без family
final exportProvider = AsyncNotifierProvider<ExportController, void>(
  ExportController.new, // Используем tear-off конструктора
);

class ExportController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Изначальное состояние. Оставляем пустым, так как тип void.
  }

  Future<void> exportDataToCSV(String formId) async {
    // 3. Используем const
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // 4. Получаем доступ к репозиторию через ref.read
      final repository = ref.read(leadsRepoProvider);

      await repository.exportDataCSV(formId);
    });
  }
}
