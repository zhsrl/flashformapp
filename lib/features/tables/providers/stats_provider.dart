import 'package:flashform_app/data/model/form_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final statsProvider = FutureProvider.autoDispose<List<FormStats>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase.rpc(
      'get_dashboard_stats',
    ) as List<dynamic>;

    return response
        .map(
          (item) => FormStats.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  } catch (e) {
    rethrow;
  }
});
