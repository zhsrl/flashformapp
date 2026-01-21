import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final formRepoProvider = Provider<FormRepository>(
  (ref) => FormRepository(ref.watch(supabaseAuthProvider)),
);

class FormRepository {
  FormRepository(this._supabase);

  final Supabase _supabase;

  Future<FormModel> createNewForm(Map<String, dynamic> data) async {
    final supabaseClient = _supabase.client;
    final repsonse = await supabaseClient
        .from('forms')
        .insert(data)
        .select()
        .single();

    debugPrint('Result: $repsonse');
    return FormModel.fromJson(repsonse);
  }

  Future<FormModel> updateForm(Map<String, dynamic> data) async {
    final supabaseClient = _supabase.client;

    final id = data['id'];
    final repsonse = await supabaseClient
        .from('forms')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    debugPrint('Result: $repsonse');
    return FormModel.fromJson(repsonse);
  }

  Future<List<FormModel>> getAllForms() async {
    final supabaseAuth = _supabase.client.auth;
    try {
      if (supabaseAuth.currentUser == null) {
        throw Exception('User is null');
      }
      final response = await _supabase.client
          .from('forms')
          .select()
          .eq('user_id', supabaseAuth.currentUser!.id)
          .order('created_at', ascending: false);

      return response.map((json) => FormModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e);
    }
  }
}
