import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashform_app/data/controller/ai_copywriter_controller.dart';

class AiFormGeneratorDialog extends ConsumerStatefulWidget {
  final String language; // 'kk', 'ru', 'en'
  final Function(Map<String, dynamic>) onFormGenerated;

  const AiFormGeneratorDialog({
    Key? key,
    required this.language,
    required this.onFormGenerated,
  }) : super(key: key);

  @override
  ConsumerState<AiFormGeneratorDialog> createState() =>
      _AiFormGeneratorDialogState();
}

class _AiFormGeneratorDialogState extends ConsumerState<AiFormGeneratorDialog> {
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateForm() async {
    if (_descriptionController.text.isEmpty) {
      setState(() => _error = _getErrorMessage('empty_description'));
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final controller = ref.read(aiCopywriterControllerProvider).value;
      if (controller == null) {
        throw Exception('AI Controller not initialized');
      }

      final formData = await controller.generateFormStructure(
        description: _descriptionController.text,
        language: widget.language,
      );

      widget.onFormGenerated(formData);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = _getErrorMessage('generation_failed');
        _isLoading = false;
      });
    }
  }

  String _getErrorMessage(String type) {
    switch (widget.language) {
      case 'kk':
        return type == 'empty_description'
            ? 'Өтінеме сипаттамасын енгізіңіз'
            : 'Форма құрылымын құру сәтсіз болды';
      case 'ru':
        return type == 'empty_description'
            ? 'Пожалуйста, введите описание формы'
            : 'Не удалось создать структуру формы';
      case 'en':
        return type == 'empty_description'
            ? 'Please enter a form description'
            : 'Failed to generate form structure';
      default:
        return 'Error';
    }
  }

  String _getTitle() {
    switch (widget.language) {
      case 'kk':
        return '✨ AI Форма Құрылымы';
      case 'ru':
        return '✨ AI Структура Формы';
      case 'en':
        return '✨ AI Form Structure';
      default:
        return '✨ AI Form Generator';
    }
  }

  String _getDescription() {
    switch (widget.language) {
      case 'kk':
        return 'Өтінеме сипаттамасын енгізіңіз, ал AI оңтайландырылған форма құрылымын құрайды.';
      case 'ru':
        return 'Введите описание формы, и AI создаст оптимизированную структуру.';
      case 'en':
        return 'Describe your form, and AI will create an optimized structure.';
      default:
        return 'Enter form description';
    }
  }

  String _getHint() {
    switch (widget.language) {
      case 'kk':
        return 'Мысалы: "Вебинар үшін тіркеу өтінемесі контакт ақпаратын сұраса..."';
      case 'ru':
        return 'Пример: "Форма регистрации на вебинар со сбором контактов..."';
      case 'en':
        return 'Example: "Registration form for webinar collecting contact details..."';
      default:
        return 'Enter description...';
    }
  }

  String _getGenerateButtonText() {
    switch (widget.language) {
      case 'kk':
        return _isLoading ? 'Құрылып жатыр...' : 'Форма құру';
      case 'ru':
        return _isLoading ? 'Создаю...' : 'Создать форму';
      case 'en':
        return _isLoading ? 'Generating...' : 'Generate Form';
      default:
        return 'Generate';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              _getTitle(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _getDescription(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Input Field
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: _getHint(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              enabled: !_isLoading,
            ),

            // Error Message
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(
                    widget.language == 'kk'
                        ? 'Бас тарту'
                        : widget.language == 'ru'
                            ? 'Отмена'
                            : 'Cancel',
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _generateForm,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : Text(_getGenerateButtonText()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
