import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/logo_image_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class LogoImagePickerWidget extends ConsumerStatefulWidget {
  const LogoImagePickerWidget({
    super.key,
    this.imageUrl,
    this.onImageUpdated,
    this.onImageDeleted,
    this.folder,
  });

  final String? imageUrl;
  final ValueChanged<String>? onImageUpdated;
  final VoidCallback? onImageDeleted;
  final String? folder;

  @override
  ConsumerState<LogoImagePickerWidget> createState() =>
      _LogoImagePickerWidgetState();
}

class _LogoImagePickerWidgetState extends ConsumerState<LogoImagePickerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logoImageControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final logoState = ref.watch(logoImageControllerProvider);
    final notifier = ref.read(logoImageControllerProvider.notifier);
    final currentFormId = ref.read(currentFormIdProvider);

    final displayUrl = logoState.imageUrl ?? widget.imageUrl;
    final hasImage = displayUrl != null || logoState.localImageBytes != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppTheme.fourty,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border, width: 2),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildContent(displayUrl, logoState.localImageBytes),
              if (logoState.isLoading)
                _buildLoadingOverlay(logoState.uploadProgress),
              if (logoState.errorMessage != null)
                _buildErrorBadge(logoState.errorMessage!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FFButton(
                isLoading: logoState.isLoading,
                onPressed: () async {
                  final bytes = await notifier.pickImage();
                  if (bytes == null) return;

                  final imageUrl = await notifier.uploadImage(
                    folder: widget.folder,
                    bytes: bytes,
                  );

                  if (imageUrl != null) {
                    widget.onImageUpdated?.call(imageUrl);
                  }
                },
                text: hasImage ? 'Update logo' : 'Add logo',
                marginBottom: 0,
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 45,
                width: 80,
                child: IconButton.filled(
                  onPressed: logoState.isLoading
                      ? null
                      : () async {
                          await _handleDelete(
                            notifier,
                            displayUrl,
                            currentFormId,
                          );
                        },
                  style: IconButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(300),
                    ),
                  ),
                  icon: const HeroIcon(
                    HeroIcons.trash,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildContent(String? url, Uint8List? localBytes) {
    if (localBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(localBytes, fit: BoxFit.contain),
      );
    }
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(
            HeroIcons.photo,
            size: 48,
            color: AppTheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Logo not uploaded yet',
            style: TextStyle(
              color: AppTheme.secondary.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(double? progress) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            if (progress != null) ...[
              const SizedBox(height: 8),
              Text(
                '${progress.toInt()}%',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBadge(String error) {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          error,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    LogoImageController notifier,
    String? urlToDelete,
    String? id,
  ) async {
    if (urlToDelete == null) return;

    await notifier.deleteImage(urlToDelete, id);
    notifier.reset();
    widget.onImageDeleted?.call();
  }
}
