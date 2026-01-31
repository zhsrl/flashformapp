import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/create_form_page.dart'; // Import for currentFormIdProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class ImagePickerWidget extends ConsumerWidget {
  const ImagePickerWidget({
    super.key,
    this.imageUrl,
    this.onImageUploaded,
    this.onImageDeleted,
    this.folder,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = 12,
  });

  final String? imageUrl;
  final ValueChanged<String>? onImageUploaded;
  final VoidCallback? onImageDeleted;
  final String? folder;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // В идеале ImageController должен возвращать AsyncValue или сложный стейт
    final imageState = ref.watch(imageControllerProvider);
    final formId = ref.watch(currentFormIdProvider);
    final notifier = ref.read(imageControllerProvider.notifier);

    final displayUrl = imageState.imageUrl ?? imageUrl;
    final hasImage = displayUrl != null || imageState.localImageBytes != null;

    // Слушаем ошибки контроллера (если реализовано через StateNotifier)
    // ref.listen(imageControllerProvider, (previous, next) { ... });

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.fourty,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.border, width: 2),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Content Layer
          _buildContent(displayUrl, imageState.localImageBytes),

          // 2. Loading Overlay
          if (imageState.isLoading)
            _buildLoadingOverlay(imageState.uploadProgress),

          // 3. Actions Layer
          if (!imageState.isLoading)
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: hasImage ? HeroIcons.arrowPath : HeroIcons.photo,
                    onTap: () => _handleUpload(notifier, displayUrl, formId),
                  ),
                  if (hasImage) ...[
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: HeroIcons.trash,
                      color: Colors.red,
                      onTap: () => _handleDelete(context, notifier, displayUrl),
                    ),
                  ],
                ],
              ),
            ),

          // 4. Error Layer (Опционально, лучше через SnackBar)
          if (imageState.errorMessage != null)
            _buildErrorBadge(imageState.errorMessage!),
        ],
      ),
    );
  }

  Widget _buildContent(String? url, dynamic localBytes) {
    if (localBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: Image.memory(localBytes, fit: BoxFit.cover),
      );
    }
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 2),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
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
            'Выберите изображение',
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
        borderRadius: BorderRadius.circular(borderRadius - 2),
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

  Future<void> _handleUpload(
    dynamic notifier,
    String? currentUrl,
    String formId,
  ) async {
    // Вся логика "if update else create" перенесена сюда или в контроллер
    // Для чистоты кода в виджете, вызываем унифицированный метод (предложение):
    /* await notifier.handleImagePick(
          currentUrl: currentUrl,
          formId: formId,
          folder: folder,
          onSuccess: onImageUploaded
       );
    */

    // Если оставляем логику здесь (как временное решение):
    String? newUrl;
    if (currentUrl != null) {
      newUrl = await notifier.updateImage(
        oldImageUrl: currentUrl,
        formId: formId,
        folder: folder,
        quality: 85,
      );
    } else {
      newUrl = await notifier.pickAndUploadImage(folder: folder, quality: 85);
    }

    if (newUrl != null && onImageUploaded != null) {
      onImageUploaded!(newUrl);
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    dynamic notifier,
    String? urlToDelete,
  ) async {
    if (urlToDelete == null) return;

    try {
      await notifier.deleteImage(urlToDelete);
      notifier.reset();
      onImageDeleted?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка удаления: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap, this.color});

  final HeroIcons icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? AppTheme.secondary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: HeroIcon(icon, size: 20, color: AppTheme.primary),
      ),
    );
  }
}
