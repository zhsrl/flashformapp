import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final leadsRepoProvider = Provider<LeadsRepository>(
  (ref) => LeadsRepository(ref.watch(supabaseAuthProvider)),
);

class LeadsRepository {
  LeadsRepository(this._supabase);

  final Supabase _supabase;
  static const int pageSize = 20;

  SupabaseClient get _client => _supabase.client;
  User? get _currentUser => _client.auth.currentUser;

  Future<List<Lead>> getLeadsByFormId(
    String formId, {
    required int offset,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? city,
    String? country,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    var query = _client.from('leads').select().eq('form_id', formId);

    // Apply date filters
    if (dateFrom != null) {
      // Format: YYYY-MM-DD for date-only comparison
      final dateStr =
          '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';
      query = query.gte('created_at', dateStr);
    }
    if (dateTo != null) {
      final dateStr =
          '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';
      query = query.lt('created_at', dateStr);
    }

    // Apply location filters
    if (city != null) {
      query = query.filter('geo->>city', 'eq', city);
    }
    if (country != null) {
      query = query.filter('geo->>country', 'eq', country);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((json) => Lead.fromJson(json)).toList();
  }

  Future<int> getLeadsCount(
    String formId, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? city,
    String? country,
  }) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    var query = _client.from('leads').select('*').eq('form_id', formId);

    // Apply date filters
    if (dateFrom != null) {
      // Format: YYYY-MM-DD for date-only comparison
      final dateStr =
          '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';
      query = query.gte('created_at', dateStr);
    }
    if (dateTo != null) {
      final dateStr =
          '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';
      query = query.lt('created_at', dateStr);
    }

    // Apply location filters
    if (city != null) {
      query = query.filter('geo->>city', 'eq', city);
    }
    if (country != null) {
      query = query.filter('geo->>country', 'eq', country);
    }

    final response = await query.count(CountOption.exact);

    return response.count;
  }

  // Get unique locations for filter dropdown
  Future<List<Map<String, String>>> getUniqueLocations(String formId) async {
    if (_currentUser == null) {
      throw const AuthException('User not logged in');
    }

    final response = await _client
        .from('leads')
        .select('geo')
        .eq('form_id', formId)
        .not('geo', 'is', null);

    // Use Set of strings to track unique combinations
    final uniqueKeys = <String>{};
    final locations = <Map<String, String>>[];

    for (final item in response) {
      final geo = item['geo'] as Map<String, dynamic>?;
      if (geo != null) {
        final city = geo['city']?.toString() ?? '';
        final country = geo['country']?.toString() ?? '';

        if (city.isNotEmpty || country.isNotEmpty) {
          // Create unique key from city and country
          final key = '$city|$country';

          // Only add if not already in set
          if (!uniqueKeys.contains(key)) {
            uniqueKeys.add(key);
            locations.add({
              'city': city,
              'country': country,
            });
          }
        }
      }
    }

    return locations;
  }

  Future<void> exportDataCSV(
    String formId, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? city,
    String? country,
  }) async {
    debugPrint('Exporting data to CSV...');
    var query = _client
        .from('leads')
        .select('created_at, answers, utm_data, geo')
        .eq('form_id', formId);

    // Apply date filters
    if (dateFrom != null) {
      final dateStr =
          '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';
      query = query.gte('created_at', dateStr);
    }
    if (dateTo != null) {
      final dateStr =
          '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';
      query = query.lt('created_at', dateStr);
    }

    // Apply location filters
    if (city != null) {
      query = query.filter('geo->>city', 'eq', city);
    }
    if (country != null) {
      query = query.filter('geo->>country', 'eq', country);
    }

    final data = await query.order('created_at', ascending: false);

    if (data.isEmpty) {
      debugPrint('No data to export');
      return;
    }

    try {
      // Collect all unique keys from answers, utm_data, and geo
      final allAnswerKeys = <String>{};
      final allUtmKeys = <String>{};
      final allGeoKeys = <String>{};

      for (final row in data) {
        final answers = row['answers'] as Map<String, dynamic>?;
        if (answers != null) {
          allAnswerKeys.addAll(answers.keys);
        }

        final utmData = row['utm_data'] as Map<String, dynamic>?;
        if (utmData != null) {
          allUtmKeys.addAll(utmData.keys);
        }

        final geo = row['geo'] as Map<String, dynamic>?;
        if (geo != null) {
          allGeoKeys.addAll(geo.keys);
        }
      }

      // Build headers
      final headers = [
        'Дата создания',
        ...allAnswerKeys.map((key) => key),
        ...allUtmKeys.map((key) => key),
        ...allGeoKeys.map((key) => key),
      ];

      // Build CSV data
      final csvData = <List<dynamic>>[headers];

      for (final row in data) {
        final rowData = <dynamic>[];

        // Add created_at
        final createdAt =
            DateFormat(
                  'yyyy-MM-dd HH:mm',
                ).format(DateTime.parse(row['created_at']).toLocal())
                as String?;
        rowData.add(createdAt ?? '');

        // Add answer values (in same order as headers)
        final answers = row['answers'] as Map<String, dynamic>?;
        for (final key in allAnswerKeys) {
          rowData.add(answers?[key]?.toString() ?? '');
        }

        // Add UTM values
        final utmData = row['utm_data'] as Map<String, dynamic>?;
        for (final key in allUtmKeys) {
          rowData.add(utmData?[key]?.toString() ?? '');
        }

        // Add Geo values
        final geo = row['geo'] as Map<String, dynamic>?;
        for (final key in allGeoKeys) {
          rowData.add(geo?[key]?.toString() ?? '');
        }

        csvData.add(rowData);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Add BOM for UTF-8 encoding (for proper Excel display)
      final bom = [0xEF, 0xBB, 0xBF];
      final bytes = utf8.encode(csvString);
      final uint8list = Uint8List.fromList([...bom, ...bytes]);

      // Save file
      await FileSaver.instance.saveFile(
        name: 'leads_$formId',
        fileExtension: 'csv',
        mimeType: MimeType.csv,
        bytes: uint8list,
      );

      debugPrint('CSV export completed successfully');
    } catch (e) {
      debugPrint('Export error: $e');
      throw Exception('Ошибка экспорта: $e');
    }
  }
}
