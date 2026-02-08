import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuildThemeBlock extends ConsumerWidget {
  const BuildThemeBlock({
    super.key,
    required this.currentTheme,
    required this.controller,
    required this.onChanged,
  });

  final String currentTheme;
  final CreateFormController controller;
  final VoidCallback onChanged;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      width: context.screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: AppTheme.background,
        border: Border.all(width: 1.5, color: AppTheme.border),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите тему',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownMenu(
            width: 350,

            initialSelection: currentTheme,
            menuStyle: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(AppTheme.background),
              maximumSize: WidgetStatePropertyAll(Size.square(300)),
              minimumSize: WidgetStatePropertyAll(Size.square(200)),
            ),
            onSelected: (value) {
              if (value != null) controller.updateTheme(value);
              onChanged();
              ref.read(createFormProvider.notifier).markAsChanged();
            },
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.border),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'dark', label: 'Темная тема'),
              DropdownMenuEntry(value: 'light', label: 'Светлая тема'),
            ],
          ),
        ],
      ),
    );
  }
}
