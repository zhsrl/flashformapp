import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final formServiceProvider = Provider<FormService>(
  (ref) =>
      FormService(ref.watch(formRepoProvider), ref.watch(supabaseAuthProvider)),
);

class FormService {
  FormService(
    this._repository,
    this._supabase,
  );

  final FormRepository _repository;
  final Supabase _supabase;

  Future<FormModel> createNewForm(String name) async {
    final client = _supabase.client;
    String slug = _generateSlug(name);

    final user = client.auth.currentUser;

    if (user == null) throw Exception('User is null');

    final data = {
      'user_id': user.id,
      'name': name,
      'slug': slug,
      'title': 'Untitled',
    };
    final response = await _repository.createNewForm(data);

    return response;
  }

  String _generateSlug(String title) {
    // Простая логика транслитерации или очистки для URL
    return 'form${DateTime.now().millisecondsSinceEpoch}';
  }
}
