import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final storageRepoProvider = Provider<StorageRepository>(
  (ref) => StorageRepository(),
);

class StorageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'form-images';

  Future<String> uploadImage(
    Uint8List imageBytes, {
    String? folder,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is null');
    }

    try {
      final String finalFileName =
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png';

      final String filePath = folder != null
          ? '${user.id}/$folder/$finalFileName'
          : '${user.id}/$finalFileName';

      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/jpeg',
            ),
          );

      final String publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      throw Exception('Exception upload image: ${e.message}');
    } catch (e) {
      throw Exception('Exception upload image: $e');
    }
  }

  Future<void> deleteImage(
    String imageUrl,
  ) async {
    try {
      debugPrint('Удаляем фото...');
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final Uri uri = Uri.parse(imageUrl);

      final segments = uri.pathSegments;
      final publicIndex = segments.indexOf('public');

      if (publicIndex == -1 || publicIndex >= segments.length - 1) {
        debugPrint('Неверный формат URL');
        throw Exception('Неверный формат URL изображения');
      }

      final bucketIndex = publicIndex + 1;
      final filePath = segments.sublist(bucketIndex + 1).join('/');

      debugPrint('🔍 Извлеченный путь к файлу: $filePath');

      await _supabase.storage.from(_bucketName).remove([filePath]);

      debugPrint('Удалили успешно...');
    } on StorageException catch (e) {
      throw Exception('Exception delete image: ${e.message}');
    } catch (e) {
      throw Exception('Exception delete image: $e');
    }
  }

  Future<void> ensureBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();

      final bucketExists = buckets.any((bucket) => bucket.name == _bucketName);

      if (!bucketExists) {
        await _supabase.storage.createBucket(
          _bucketName,
          const BucketOptions(
            public: true, // Публичный доступ к файлам
            fileSizeLimit: '3145728', // 3 MB лимит
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при проверке bucket: $e');
    }
  }
}
