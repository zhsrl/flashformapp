import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashform_app/data/service/gemini_copywriter_service.dart';
import 'package:flashform_app/data/model/copywriting_response.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';

final aiCopywriterControllerProvider = FutureProvider<AiCopywriterController>((
  ref,
) async {
  // TODO: Позже перенести в Supabase Secrets
  const apiKey = 'AIzaSyCQQaNKM41cX8OC3kZpLyzXNDlTCfh72Cg';

  if (apiKey.isEmpty) {
    throw Exception('Gemini API key not configured');
  }

  final service = GeminiCopywriterService(apiKey: apiKey);
  return AiCopywriterController(service);
});

class AiCopywriterController {
  AiCopywriterController(this._service);

  final GeminiCopywriterService _service;

  // Кэш для результатов
  final Map<String, CopywritingResponse> _cache = {};

  /// Генерирует копирайтинг с кэшированием
  Future<CopywritingResponse> generateCopywriting({
    required String type,
    required String language,
    required String context,
    int numberOfVariants = 3,
  }) async {
    // Создаем ключ кэша
    final cacheKey = '$type|$language|$context';

    // Проверяем кэш
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _service.generateCopywriting(
        type: type,
        language: language,
        context: context,
        numberOfVariants: numberOfVariants,
      );

      // Сохраняем в кэш
      _cache[cacheKey] = response;

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Генерирует структуру формы по описанию
  Future<Map<String, dynamic>> generateFormStructure({
    required String description,
    required String language,
  }) async {
    try {
      return await _service.generateFormStructure(
        description: description,
        language: language,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Очищает кэш
  void clearCache() {
    _cache.clear();
  }

  /// Очищает кэш для конкретного ключа
  void clearCacheForType(String type) {
    _cache.removeWhere((key, _) => key.startsWith(type));
  }
}
