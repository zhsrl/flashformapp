import 'dart:math';

import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flutter/material.dart';
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
      'data': {
        'title': {
          'text': 'Заголовок',
          'font-size': 42,
        },
        'subtitle': {
          'text': 'Описание',
          'font-size': 24,
        },
        'content-type': 'image',
        'action-type': 'url',
        'button': {
          'color': 'd0f20b',
          'text': 'Кнопка',
          'url': '',
        },
        'success-text': '',
      },
      'is_active': false,
    };
    final response = await _repository.createNewForm(data);

    return response;
  }

  String _generateSlug(String title) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789';

    final Random random = Random.secure();
    return 'form-${String.fromCharCodes(
      Iterable.generate(
        5,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    )}';
  }

  String encodeBase62(int number) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789';
    if (number == 0) return chars[0];

    final base = chars.length;
    final buffer = StringBuffer();

    while (number > 0) {
      buffer.write(chars[number % base]);
      number ~/= base;
    }

    return buffer.toString().split('').reversed.join();
  }
}
