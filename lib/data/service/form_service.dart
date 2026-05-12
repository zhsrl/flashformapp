import 'dart:math';

import 'package:flashform_app/data/model/form.dart';
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
      'data': {
        'form': {
          'title': 'Заголовок формы',
          'button': {
            'text': 'Оставить заявку',
            'color': 'FF2332db',
          },
          'fields': [],
          'success_text': '',
          'success_action': {
            'type': 'thx',
            'thx_title': null,
            'redirect_url': null,
            'thx_description': null,
            'whatsapp_number': null,
            'whatsapp_message': null,
          },
        },
        'main': {
          'image': null,
          'label': null,
          'title': 'Заголовок страницы',
          'subtitle': 'Описание страницы',
          'button_1': {
            'url': null,
            'text': 'Кнопка',
            'type': 'form',
            'anchor': null,
          },
          'button_2': {
            'url': null,
            'text': 'Кнопка 2',
            'type': 'anchor',
            'anchor': null,
            'enabled': false,
          },
        },
        'branding': {
          'theme': 'light',
          'primary_color': 'FF2332db',
          'logo': null,
        },
        'blocks': [],
        'footer': {
          'links': [],
          'enabled': false,
          'legal-info': {
            'address': null,
            'id-number': null,
            'company-name': null,
          },
        },
        'settings': {
          'integrations': {
            'meta_pixel_id': {
              'id': null,
              'enabled': false,
            },
            'ya_metrika_id': {
              'id': null,
              'enabled': false,
            },
            'telegram_bot': {
              'chat_id': null,
              'enabled': false,
            },
          },
          'is_branded': true,
        },
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
