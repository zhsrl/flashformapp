import 'dart:typed_data';

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
    StateNotifierProvider<ImageController, ImageUploadState>((ref) {
      return ImageController(
        ref.watch(storageRepoProvider),
        ref.watch(imageServiceProvider),
      );
    });

class ImageController extends StateNotifier<ImageUploadState> {
  ImageController(
    this._repository,
    this._service,
  ) : super(ImageUploadState());

  void reset() {
    debugPrint('🔄 [ImageController] Сброс состояния');

    state = ImageUploadState(
      imageUrl: null,
      localImageBytes: null,
      isLoading: false,
    );
  }

  final StorageRepository _repository;
  final ImageService _service;

  Future<String?> pickAndUploadImage({
    String? folder,
    int quality = 85,
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

      // If user cancel upload
      if (compressedBytes == null) {
        state = state.copyWith(
          isLoading: false,
        );

        return null;
      }

      // Показываем размер до и после сжатия (для отладки)
      final sizeInMB = _service.getImageSizeInMB(compressedBytes);
      debugPrint(
        'Размер сжатого изображения: ${sizeInMB.toStringAsFixed(2)} MB',
      );

      state = state.copyWith(
        localImageBytes: compressedBytes,
        uploadProgress: 50,
      );

      final imageUrl = await _repository.uploadImage(
        compressedBytes,
        folder: folder,
      );

      state = state.copyWith(
        isLoading: false,
        imageUrl: imageUrl,
        uploadProgress: 100,
      );

      return imageUrl;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        uploadProgress: null,
        localImageBytes: null,
      );

      throw Exception('Upload image exception: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _repository.deleteImage(
        imageUrl,
      );

      state = state.copyWith(
        isLoading: false,
        imageUrl: null,
        localImageBytes: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);

      throw Exception('Delete image exception: $e');
    }
  }

  Future<String?> updateImage({
    required String? oldImageUrl,
    required String formId,
    String? folder,
    int quality = 85,
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

      // If user cancel upload
      if (compressedBytes == null) {
        state = state.copyWith(
          isLoading: false,
        );

        return null;
      }

      state = state.copyWith(
        localImageBytes: compressedBytes,
        uploadProgress: 50,
      );

      final newImageUrl = await _repository.updateImage(
        oldImageUrl,
        formId,
        compressedBytes,

        folder: folder,
      );

      state = state.copyWith(
        isLoading: false,
        imageUrl: newImageUrl,
        uploadProgress: 100,
      );

      return newImageUrl;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        uploadProgress: null,
        localImageBytes: null,
      );

      throw Exception('Update image exception: $e');
    }
  }
}
