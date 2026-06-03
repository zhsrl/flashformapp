import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final googleSheetsRepoProvider = Provider<GoogleSheetsRepository>(
  (ref) => GoogleSheetsRepository(ref.watch(supabaseAuthProvider)),
);

class GoogleSheetsIntegration {
  GoogleSheetsIntegration({
    required this.formId,
    this.googleUserEmail,
    this.spreadsheetId,
    this.sheetName,
    required this.sendUtm,
  });

  final String formId;
  final String? googleUserEmail;
  final String? spreadsheetId;
  final String? sheetName;
  final bool sendUtm;

  factory GoogleSheetsIntegration.fromJson(Map<String, dynamic> json) {
    return GoogleSheetsIntegration(
      formId: json['form_id'] as String,
      googleUserEmail: json['google_user_email'] as String?,
      spreadsheetId: json['spreadsheet_id'] as String?,
      sheetName: json['sheet_name'] as String?,
      sendUtm: json['send_utm'] as bool? ?? false,
    );
  }
}

class GoogleSheetsCreateResult {
  GoogleSheetsCreateResult({
    required this.spreadsheetId,
    required this.sheetName,
  });

  final String spreadsheetId;
  final String sheetName;

  factory GoogleSheetsCreateResult.fromJson(Map<String, dynamic> json) {
    return GoogleSheetsCreateResult(
      spreadsheetId: json['spreadsheet_id'] as String,
      sheetName: json['sheet_name'] as String,
    );
  }
}

class GoogleSheetsRepository {
  GoogleSheetsRepository(this._supabase);

  final Supabase _supabase;

  SupabaseClient get _client => _supabase.client;

  Future<GoogleSheetsIntegration?> getIntegration(String formId) async {
    final response = await _client
        .from('google_sheets_integrations')
        .select(
          'form_id, google_user_email, spreadsheet_id, sheet_name, send_utm',
        )
        .eq('form_id', formId)
        .maybeSingle();

    if (response == null) return null;
    return GoogleSheetsIntegration.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<void> upsertSettings({
    required String formId,
    required String spreadsheetId,
    required String sheetName,
    required bool sendUtm,
  }) async {
    final existing = await _client
        .from('google_sheets_integrations')
        .select('id')
        .eq('form_id', formId)
        .maybeSingle();

    final payload = {
      'form_id': formId,
      'spreadsheet_id': spreadsheetId,
      'sheet_name': sheetName,
      'send_utm': sendUtm,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing == null) {
      await _client.from('google_sheets_integrations').insert(payload);
    } else {
      await _client
          .from('google_sheets_integrations')
          .update(payload)
          .eq('form_id', formId);
    }
  }

  Future<void> disconnect(String formId) async {
    await _client
        .from('google_sheets_integrations')
        .delete()
        .eq('form_id', formId);
  }

  Future<GoogleSheetsCreateResult> createSpreadsheet({
    required String formId,
    required String title,
    required String sheetName,
  }) async {
    final response = await _client.functions.invoke(
      'google_sheets_create',
      body: {
        'form_id': formId,
        'title': title,
        'sheet_name': sheetName,
      },
    );

    if (response.status >= 400) {
      throw Exception('Failed to create spreadsheet: ${response.data}');
    }

    return GoogleSheetsCreateResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
