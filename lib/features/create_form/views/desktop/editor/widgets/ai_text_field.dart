import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashform_app/data/controller/ai_copywriter_controller.dart';
import 'package:flashform_app/data/model/copywriting_response.dart';
import 'package:flashform_app/data/service/prompts/copywriting_prompts.dart';
import 'ai_trailing_button.dart';
import '../dialogs/ai_result_dialog.dart';

class AiTextField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String
  aiType; // 'title', 'description', 'button', 'success', 'whatsapp', 'redirect'
  final String language; // 'kk', 'ru', 'en'
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const AiTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.aiType,
    required this.language,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
  }) : super(key: key);

  @override
  ConsumerState<AiTextField> createState() => _AiTextFieldState();
}

class _AiTextFieldState extends ConsumerState<AiTextField> {
  bool _isLoading = false;
  String? _error;

  Future<void> _generateWithAI() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Используем ref.watch() вместо ref.read() для FutureProvider
      final asyncController = ref.read(aiCopywriterControllerProvider);

      // Ждём завершения асинхронной операции
      final controller = await asyncController.when(
        data: (c) => Future.value(c),
        loading: () => Future.error('AI controller loading...'),
        error: (err, stack) => Future.error(err),
      );

      final response = await controller.generateCopywriting(
        type: widget.aiType,
        language: widget.language,
        context: widget.controller.text.isNotEmpty
            ? widget.controller.text
            : _getDefaultContext(),
        numberOfVariants: 3,
      );

      if (mounted) {
        _showResultDialog(response);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = CopywritingPrompts.getErrorMessage(widget.language);
          _isLoading = false;
        });
        debugPrint('AI Copywriter Error: $e');
      }
    }
  }

  void _showResultDialog(CopywritingResponse response) {
    showDialog(
      context: context,
      builder: (context) => AiResultDialog(
        response: response,
        language: widget.language,
        onSelected: (text) {
          widget.controller.text = text;
          widget.onChanged?.call(text);
        },
      ),
    );
  }

  String _getDefaultContext() {
    switch (widget.aiType) {
      case 'title':
        return 'Форма для сбора контактов';
      case 'description':
        return 'Форма для сбора контактов и информации';
      case 'button':
        return 'Кнопка для отправки формы';
      case 'success':
        return 'Сообщение благодарности после отправки формы';
      case 'whatsapp':
        return 'Автоответ в WhatsApp для контактов';
      case 'redirect':
        return 'Сообщение на странице перенаправления';
      default:
        return 'Форма';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Text(
        //       widget.label,
        //       style: Theme.of(context).textTheme.labelMedium?.copyWith(
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(8),
            // ),

            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(8),
            //   borderSide: BorderSide(
            //     color: Theme.of(context).primaryColor,
            //     width: 2,
            //   ),
            // ),
            fillColor: AppTheme.fourty,
            filled: true,
            hintStyle: TextStyle(
              color: AppTheme.tertiary,
              fontWeight: FontWeight.w500,
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),

            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.border,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            // contentPadding: const EdgeInsets.all(12),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AiTrailingButton(
                isLoading: _isLoading,
                onPressed: _generateWithAI,
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[600],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
