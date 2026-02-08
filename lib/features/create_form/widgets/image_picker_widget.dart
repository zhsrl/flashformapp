import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.imageUrl,
    this.onImageUpdated,
    this.onImageDeleted,
    this.folder,
    required this.formId,
  });

  final String? imageUrl;
  final Function(String)? onImageUpdated;
  final VoidCallback? onImageDeleted;
  final String? folder;
  final String formId;

  @override
  ConsumerState<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageState = ref.watch(imageControllerProvider);
    final formState = ref.watch(createFormProvider);
    final notifier = ref.read(imageControllerProvider.notifier);
    final createFormNotifier = ref.read(createFormProvider.notifier);

    final displayUrl = imageState.imageUrl ?? widget.imageUrl;
    final hasImage = displayUrl != null || imageState.localImageBytes != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppTheme.fourty,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border, width: 2),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildContent(displayUrl, imageState.localImageBytes),
              if (imageState.isLoading)
                _buildLoadingOverlay(imageState.uploadProgress),
              if (imageState.errorMessage != null)
                _buildErrorBadge(imageState.errorMessage!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FFButton(
                isLoading: imageState.isLoading,
                onPressed: () async {
                  await ref.read(imageControllerProvider.notifier).pickImage();
                  createFormNotifier.markAsChanged();
                },
                text: hasImage ? 'Обновить' : 'Добавить фото',
                marginBottom: 0,
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 45,
                width: 80,
                child: IconButton.filled(
                  onPressed: imageState.isLoading
                      ? null
                      : () => _handleDelete(
                          context,
                          notifier,
                          displayUrl,
                          createFormNotifier,
                          formState,
                        ),
                  style: IconButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.red,

                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(300),
                    ),
                  ),
                  icon: HeroIcon(
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

  Widget _buildContent(String? url, dynamic localBytes) {
    if (localBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(localBytes, fit: BoxFit.contain),
      );
    } else if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
            'Фото еще не загружено',
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
    BuildContext context,
    ImageController notifier,
    String? urlToDelete,
    CreateFormController createFormNotifier,
    CreateFormState
    createFormState, // <--- УБЕРИТЕ ЭТОТ АРГУМЕНТ, он путает вас
  ) async {
    if (urlToDelete == null) return;

    try {
      // 1. Удаляем из базы и хранилища
      await notifier.deleteImage(urlToDelete, formId: widget.formId);

      // 2. Обновляем стейт формы
      createFormNotifier.updateHeroImage(null);

      // 3. ПРОВЕРКА (ПРАВИЛЬНАЯ)
      // Читаем напрямую из ref, чтобы увидеть АКТУАЛЬНЫЕ данные
      final newState = ref.read(createFormProvider);
      debugPrint(
        'Hero image url (OLD variable): ${createFormState.heroImageUrl}',
      ); // Будет старый
      debugPrint(
        'Hero image url (NEW state): ${newState.heroImageUrl}',
      ); // Будет null

      notifier.reset();
      widget.onImageDeleted!.call();
    } catch (e) {
      // ...
    }
  }
}
