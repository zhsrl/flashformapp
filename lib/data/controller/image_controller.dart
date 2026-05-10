import 'dart:typed_data';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/data/repository/storage_repository.dart';
import 'package:flashform_app/data/service/image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ImageUploadState {
  final bool isLoading;
  final String? imageUrl;
  final double? uploadProgress;
  final String? errorMessage;
  final Uint8List? localImageBytes; // Для предпросмотра до загрузки

  ImageUploadState({
    this.isLoading = false,
    this.imageUrl,
    this.uploadProgress,
    this.errorMessage,
    this.localImageBytes,
  });

  ImageUploadState copyWith({
    bool? isLoading,
    String? imageUrl,
    double? uploadProgress,
    String? errorMessage,
    Uint8List? localImageBytes,
  }) {
    return ImageUploadState(
      isLoading: isLoading ?? this.isLoading,
      imageUrl: imageUrl ?? this.imageUrl,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      localImageBytes: localImageBytes ?? this.localImageBytes,
    );
  }
}

final imageControllerProvider =
    StateNotifierProvider.autoDispose<ImageController, ImageUploadState>((ref) {
      return ImageController(
        ref.watch(storageRepoProvider),
        ref.watch(imageServiceProvider),
        ref.watch(formRepoProvider),
      );
    });

class ImageController extends StateNotifier<ImageUploadState> {
  ImageController(
    this._storageRepository,
    this._service,
    this._formRepository,
  ) : super(ImageUploadState());

  final StorageRepository _storageRepository;
  final ImageService _service;
  final FormRepository _formRepository;

  void reset() {
    debugPrint('🔄 [ImageController] Сброс состояния');

    state = ImageUploadState(
      imageUrl: null,
      localImageBytes: null,
      isLoading: false,
    );
  }

  void resetPickedImage() {
    debugPrint('🔄 [ImageController] Сброс состояния выбранное изображение');

    state = ImageUploadState(
      localImageBytes: null,
      isLoading: false,
    );
  }

  Future<Uint8List?> pickImage({
    int quality = 50,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        uploadProgress: 0,
      );

      final compressedBytes = await _service.pickAndCompressImage(
        quality: quality,
        maxImageHeight: maxHeight,
        maxImageWidth: maxWidth,
      );

      // User cancelled the picker
      if (compressedBytes == null) {
        state = state.copyWith(
          isLoading: false,
        );
        debugPrint('ℹ️ User cancelled image picker');
        return null;
      }

      final sizeInMB = _service.getImageSizeInMB(compressedBytes);
      debugPrint(
        'Размер сжатого изображения: ${sizeInMB.toStringAsFixed(2)} MB',
      );

      state = state.copyWith(
        isLoading: false,
        localImageBytes: compressedBytes,
      );

      return compressedBytes;
    } catch (e) {
      // Differentiate between error types
      String errorMessage;
      if (e.toString().contains('Permission')) {
        errorMessage = '❌ Permission denied: Need access to gallery/camera';
        debugPrint(errorMessage);
      } else if (e.toString().contains('compress')) {
        errorMessage = '❌ Image compression failed: ${e.toString()}';
        debugPrint(errorMessage);
      } else {
        errorMessage = '❌ Image pick error: ${e.toString()}';
        debugPrint(errorMessage);
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        localImageBytes: null,
      );

      rethrow;
    }
  }

  Future<String?> uploadImage({
    String? folder,
    Uint8List? bytes,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        uploadProgress: 0,
      );

      if (bytes == null) {
        state = state.copyWith(
          isLoading: false,
        );
        debugPrint('⚠️ Upload cancelled: No image bytes provided');
        return null;
      }

      final imageUrl = await _storageRepository.uploadImage(
        bytes,
        folder: folder,
      );

      state = state.copyWith(
        isLoading: false,
        imageUrl: imageUrl,
        uploadProgress: 100,
        localImageBytes: null,
      );

      debugPrint('✅ Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      // Differentiate between error types
      String errorMessage;
      if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage = '❌ Network error: Check your connection';
        debugPrint(errorMessage);
      } else if (e.toString().contains('Permission') ||
          e.toString().contains('permission')) {
        errorMessage = '❌ Permission denied: Cannot access storage';
        debugPrint(errorMessage);
      } else if (e.toString().contains('size') ||
          e.toString().contains('quota')) {
        errorMessage = '❌ Storage quota exceeded';
        debugPrint(errorMessage);
      } else {
        errorMessage = '❌ Upload failed: ${e.toString()}';
        debugPrint(errorMessage);
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
        uploadProgress: null,
        localImageBytes: null,
      );

      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl, {String? formId}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 1. Обновляем БД только если есть ID формы
      if (formId != null) {
        debugPrint('Удаляем ссылку из БД...');
        await _formRepository.removeImageReference(formId).then((v) {
          debugPrint('ссылка удалена');
        });
      }

      // 2. Удаляем файл из хранилища (выполняется всегда)
      debugPrint('Удаляем файл из Storage...');
      await _storageRepository.deleteImage(imageUrl);

      state = state.copyWith(
        isLoading: false,
        imageUrl: null,
        localImageBytes: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      // Лучше использовать rethrow, чтобы UI мог обработать ошибку (показать снекбар)
      rethrow;
    }
  }
}
