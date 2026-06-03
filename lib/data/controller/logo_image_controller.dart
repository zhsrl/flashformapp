import 'dart:typed_data';

import 'package:flashform_app/core/utils/logger.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/data/repository/storage_repository.dart';
import 'package:flashform_app/data/service/image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// class ImageUploadState {
//   final bool isLoading;
//   final String? imageUrl;
//   final double? uploadProgress;
//   final String? errorMessage;
//   final Uint8List? localImageBytes; // Для предпросмотра до загрузки

//   ImageUploadState({
//     this.isLoading = false,
//     this.imageUrl,
//     this.uploadProgress,
//     this.errorMessage,
//     this.localImageBytes,
//   });

//   ImageUploadState copyWith({
//     bool? isLoading,
//     String? imageUrl,
//     double? uploadProgress,
//     String? errorMessage,
//     Uint8List? localImageBytes,
//   }) {
//     return ImageUploadState(
//       isLoading: isLoading ?? this.isLoading,
//       imageUrl: imageUrl ?? this.imageUrl,
//       uploadProgress: uploadProgress ?? this.uploadProgress,
//       errorMessage: errorMessage ?? this.errorMessage,
//       localImageBytes: localImageBytes ?? this.localImageBytes,
//     );
//   }
// }

final logoImageControllerProvider =
    StateNotifierProvider.autoDispose<LogoImageController, ImageUploadState>(
      (ref) {
        return LogoImageController(
          ref.watch(storageRepoProvider),
          ref.watch(formRepoProvider),
          ref.watch(imageServiceProvider),
        );
      },
    );

class LogoImageController extends StateNotifier<ImageUploadState> {
  LogoImageController(
    this._storageRepository,
    this._formRepository,
    this._service,
  ) : super(ImageUploadState());

  final StorageRepository _storageRepository;
  final FormRepository _formRepository;
  final ImageService _service;

  void reset() {
    state = ImageUploadState(
      imageUrl: null,
      localImageBytes: null,
      isLoading: false,
    );
  }

  void resetPickedImage() {
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

      if (compressedBytes == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }

      final sizeInMB = _service.getImageSizeInMB(compressedBytes);
      logger.d('Compressed logo size: ${sizeInMB.toStringAsFixed(2)} MB');

      state = state.copyWith(
        isLoading: false,
        localImageBytes: compressedBytes,
      );

      return compressedBytes;
    } catch (e) {
      throw Exception(e);
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
        state = state.copyWith(isLoading: false);
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

      return imageUrl;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        uploadProgress: null,
        localImageBytes: null,
      );

      throw Exception('Upload logo exception: $e');
    }
  }

  Future<void> deleteImage(
    String imageUrl,
    String? id,
  ) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _storageRepository.deleteImage(imageUrl);

      await _formRepository.updateForm({
        "id": id,
        "branding": {"logo": null},
      });

      state = state.copyWith(
        isLoading: false,
        imageUrl: null,
        localImageBytes: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}
