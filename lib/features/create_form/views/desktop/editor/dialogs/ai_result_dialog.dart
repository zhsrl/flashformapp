import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flashform_app/data/model/copywriting_response.dart';

class AiResultDialog extends StatefulWidget {
  final CopywritingResponse response;
  final String language;
  final Function(String) onSelected;

  const AiResultDialog({
    Key? key,
    required this.response,
    required this.language,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<AiResultDialog> createState() => _AiResultDialogState();
}

class _AiResultDialogState extends State<AiResultDialog> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final variants = [
      widget.response.primaryText,
      ...widget.response.alternatives,
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  '✨ AI варианты',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: widget.language == 'kk'
                      ? 'Жабу'
                      : widget.language == 'ru'
                      ? 'Закрыть'
                      : 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Variants List
            ListView.separated(
              shrinkWrap: true,
              itemCount: variants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;
                return _VariantCard(
                  variant: variants[index],
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
            const SizedBox(height: 24),
            // Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FFButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  text: 'Отмена',
                ),
                const SizedBox(width: 12),
                FFButton(
                  onPressed: () {
                    widget.onSelected(variants[_selectedIndex]);
                    Navigator.pop(context);
                  },
                  text: 'Выбрать',
                  secondTheme: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantCard extends StatefulWidget {
  final String variant;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantCard({
    required this.variant,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_VariantCard> createState() => _VariantCardState();
}

class _VariantCardState extends State<_VariantCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? Theme.of(context).primaryColor
                  : (_isHovered
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                        : Colors.grey[300]!),
              width: widget.isSelected ? 2 : 1,
            ),
            color: widget.isSelected
                ? AppTheme.secondary
                : (_isHovered ? AppTheme.secondary : Colors.transparent),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400]!,
                    width: widget.isSelected ? 2 : 1,
                  ),
                  color: widget.isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
                child: widget.isSelected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: isDark ? Colors.black : Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.variant,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
