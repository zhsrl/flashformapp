import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final formRepoProvider = Provider<FormRepository>(
  (ref) => FormRepository(ref.watch(supabaseAuthProvider)),
);

final currentFormIdProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'Нужно обернуть виджет в ProviderScope и передать formId',
  );
});

final currentFormNameProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'Нужно обернуть виджет в ProviderScope и передать formName',
  );
});

final currentFormSlugProvider = FutureProvider.family<String, String>(
  (ref, id) async {
    final repository = ref.watch(formRepoProvider);
    return await repository.getFormSlug(id);
  },
);

final formStatusProvider = FutureProvider.family<bool, String>((ref, id) async {
  final repository = ref.watch(formRepoProvider);
  return await repository.checkFormStatus(id);
});

class FormRepository {
  FormRepository(this._supabase);

  final Supabase _supabase;

  // Helpers
  SupabaseClient get _client => _supabase.client;
  User? get _currentUser => _client.auth.currentUser;

  Future<FormModel> createNewForm(Map<String, dynamic> data) async {
    // try-catch не нужен: ошибка вернется в контроллер
    final response = await _client.from('forms').insert(data).select().single();

    debugPrint('Created Form: $response');
    return FormModel.fromJson(response);
  }

  Future<FormModel> updateForm(Map<String, dynamic> data) async {
    final id = data['id'];

    // Внимание: этот метод перезаписывает всё поле 'data'.
    // Убедись, что 'data' содержит полную модель формы, а не частичную.
    final response = await _client
        .from('forms')
        .update({'data': data})
        .eq('id', id)
        .select()
        .single();

    return FormModel.fromJson(response);
  }

  Future<void> updateFormName(String name, String formId) async {
    await _client.from('forms').update({'name': name}).eq('id', formId);
  }

  Future<void> publishForm(Map<String, dynamic> data) async {
    final id = data['id'];

    await _client
        .from('forms')
        .update({
          'is_active': true,
          'data': data,
        })
        .eq('id', id);
  }

  Future<void> unpublishForm(String formId) async {
    await _client.from('forms').update({'is_active': false}).eq('id', formId);
  }

  Future<bool> checkFormStatus(String formId) async {
    final response = await _client
        .from('forms')
        .select('is_active')
        .eq('id', formId)
        .single();

    return response['is_active'] as bool? ?? false;
  }

  Future<String> getFormSlug(String formId) async {
    final response = await _client
        .from('forms')
        .select('slug')
        .eq('id', formId)
        .single();

    return response['slug'] as String? ?? '';
  }

  Future<List<FormModel>> getAllForms() async {
    // Убран try-catch: throw Exception(e) скрывал реальную причину (сеть, права доступа)
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('forms')
        .select()
        .eq('user_id', _currentUser!.id)
        .order('created_at', ascending: false);

    return response.map((json) => FormModel.fromJson(json)).toList();
  }

  Future<FormModel> getSingleForm(String formId) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('forms')
        .select()
        .eq('id', formId)
        .single();

    return FormModel.fromJson(response);
  }

  Future<void> removeImageReference(String formId) async {
    // 1. Получаем текущие данные (Read)
    final response = await _client
        .from('forms')
        .select('data')
        .eq('id', formId)
        .single();

    if (response['data'] == null) return;

    // 2. Создаем изменяемую копию (Modify)
    final currentData = Map<String, dynamic>.from(response['data'] as Map);
    currentData['image'] = null; // Или remove('image')

    // 3. Обновляем (Write)
    await _client.from('forms').update({'data': currentData}).eq('id', formId);
  }

  Future<String> getMetaPixelId(String formId) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('forms')
        .select()
        .eq('id', formId)
        .single();

    return response['data']['settings']['meta-pixel-id'];
  }

  Future<String> getYandexMetrikaId(String formId) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('forms')
        .select()
        .eq('id', formId)
        .single();

    return response['data']['settings']['ya-metrika-id'];
  }

  /// Безопасное обновление Meta Pixel без потери других данных
  Future<void> setMetaPixelId(String formId, String pixelId) async {
    if (formId.isEmpty)
      return; // pixelId может быть пустым, если мы хотим стереть его

    await _updateSettingsField(formId, 'meta-pixel-id', pixelId);
  }

  /// Безопасное обновление Yandex Metrika без потери других данных
  Future<void> setYandexMetrikaId(String formId, String pixelId) async {
    if (formId.isEmpty) return;

    await _updateSettingsField(formId, 'ya-metrika-id', pixelId);
  }

  /// Приватный метод для безопасного слияния настроек (Deep Merge)
  Future<void> _updateSettingsField(
    String formId,
    String key,
    String value,
  ) async {
    // 1. Читаем текущие данные
    final response = await _client
        .from('forms')
        .select('data')
        .eq('id', formId)
        .single();

    final currentData = response['data'] != null
        ? Map<String, dynamic>.from(response['data'])
        : <String, dynamic>{};

    // 2. Инициализируем settings если их нет
    if (!currentData.containsKey('settings')) {
      currentData['settings'] = <String, dynamic>{};
    }

    // 3. Обновляем конкретный ключ
    currentData['settings'][key] = value;

    // 4. Записываем обратно полный объект
    await _client.from('forms').update({'data': currentData}).eq('id', formId);
  }
}
