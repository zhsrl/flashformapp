import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

/// Виджет для выбора и загрузки изображения
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

  /// Текущий URL изображения (если есть)
  final String? imageUrl;

  /// Callback при успешной загрузке
  final Function(String imageUrl)? onImageUploaded;

  /// Callback при удалении изображения
  final VoidCallback? onImageDeleted;

  /// Папка в storage для загрузки
  final String? folder;

  /// Размеры виджета
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(imageControllerProvider);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.fourty,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: AppTheme.border,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Показываем изображение
          if (imageState.imageUrl != null || imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              child: Image.network(
                imageState.imageUrl ?? imageUrl!,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
            )
          // Показываем предпросмотр локального изображения
          else if (imageState.localImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius - 2),
              child: Image.memory(
                imageState.localImageBytes!,
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
            )
          // Показываем placeholder
          else
            _buildPlaceholder(),

          // Overlay для загрузки
          if (imageState.isLoading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(borderRadius - 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    if (imageState.uploadProgress != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${imageState.uploadProgress!.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Кнопки действий
          if (!imageState.isLoading)
            Positioned(
              bottom: 8,
              right: 8,
              child: Row(
                children: [
                  // Кнопка выбора/замены изображения
                  _ActionButton(
                    icon: imageState.imageUrl != null || imageUrl != null
                        ? HeroIcons.arrowPath
                        : HeroIcons.photo,
                    onTap: () async {
                      final hasExistingImage =
                          imageState.imageUrl != null || imageUrl != null;

                      if (hasExistingImage) {
                        // ЗАМЕНА: используем updateImage
                        final currentUrl = imageState.imageUrl ?? imageUrl;
                        final newImageUrl = await ref
                            .read(imageControllerProvider.notifier)
                            .updateImage(
                              oldImageUrl: currentUrl,
                              formId: ref.read(currentFormIdProvider),
                              folder: folder,
                              quality: 85,
                              maxWidth: 1920,
                              maxHeight: 1080,
                            );

                        if (newImageUrl != null && onImageUploaded != null) {
                          onImageUploaded!(newImageUrl);
                        }
                      } else {
                        // НОВОЕ: используем pickAndUploadImage
                        final newImageUrl = await ref
                            .read(imageControllerProvider.notifier)
                            .pickAndUploadImage(
                              folder: folder,
                              quality: 85,
                              maxWidth: 1920,
                              maxHeight: 1080,
                            );

                        if (newImageUrl != null && onImageUploaded != null) {
                          onImageUploaded!(newImageUrl);
                        }
                      }
                    },
                  ),

                  // Кнопка удаления (если есть изображение)
                  if (imageState.imageUrl != null || imageUrl != null) ...[
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: HeroIcons.trash,
                      color: Colors.red,
                      onTap: () async {
                        final urlToDelete = imageState.imageUrl ?? imageUrl!;

                        debugPrint('🗑 Удаление изображения: $urlToDelete');

                        try {
                          await ref
                              .read(imageControllerProvider.notifier)
                              .deleteImage(urlToDelete);

                          debugPrint('✅ Изображение удалено из Storage');

                          ref.read(imageControllerProvider.notifier).reset();
                          debugPrint('✅ Состояние контроллера очищено');

                          if (onImageDeleted != null) {
                            onImageDeleted!();
                            debugPrint(
                              '✅ Callback onImageDeleted вызван - _heroImageUrl = null',
                            );
                          } else {
                            debugPrint(
                              '⚠️ onImageDeleted == null - локальное состояние НЕ обновлено!',
                            );
                          }
                        } catch (e) {
                          debugPrint('❌ Ошибка при удалении: $e');

                          // Показываем ошибку пользователю
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ошибка при удалении: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

          // Показываем ошибку
          if (imageState.errorMessage != null)
            Positioned(
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
                  'Ошибка загрузки',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeroIcon(
            HeroIcons.photo,
            size: 48,
            color: AppTheme.secondary.withAlpha(50),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите изображение',
            style: TextStyle(
              color: AppTheme.secondary.withAlpha(50),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Кнопка действия для ImagePicker
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

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
        child: HeroIcon(
          icon,
          size: 20,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}
