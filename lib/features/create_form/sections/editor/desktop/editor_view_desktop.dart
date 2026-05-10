import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/views/editor_branding_view.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/views/editor_content_view.dart';
import 'package:flashform_app/features/create_form/sections/editor/desktop/views/editor_settings_view.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

var editorTabIndexProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

class EditorView extends ConsumerStatefulWidget {
  const EditorView({
    super.key,
    required this.onChanged,
    required this.focusNode,
  });

  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  ConsumerState<EditorView> createState() => _SettingsPanelViewState();
}

class _SettingsPanelViewState extends ConsumerState<EditorView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ScrollController _mainScrollController;
  late final ScrollController _brandingScrollController;
  late final ScrollController _blocksScrollController;
  late final ScrollController _settingsScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: ref.read(editorTabIndexProvider),
    );
    _mainScrollController = ScrollController();
    _brandingScrollController = ScrollController();
    _blocksScrollController = ScrollController();
    _settingsScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainScrollController.dispose();
    _brandingScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Подписываемся на стейт
    final formState = ref.watch(createFormProvider);
    final currentFormId = ref.watch(currentFormIdProvider);
    final controller = ref.read(createFormProvider.notifier);
    final uiControllers = ref.watch(formUIControllersProvider);
    final selectedIndex = ref.watch(editorTabIndexProvider);

    ref.listen<int>(editorTabIndexProvider, (prev, next) {
      if (next != _tabController.index) {
        _tabController.animateTo(next);
      }
    });

    return SizedBox(
      width: !context.isMobile ? 400 : null,
      child: Column(
        children: [
          if (!context.isMobile)
            FFTabBar(
              tabs: [
                Text(
                  'Главный',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Брендинг',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   'Блоки',
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                Text(
                  'Настройки',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              controller: _tabController,
              onTap: (index) {
                ref.read(editorTabIndexProvider.notifier).state = index;
              },
            ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  SingleChildScrollView(
                    key: const PageStorageKey('main-scroll'),
                    controller: _mainScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: EditorContentView(
                      controller: controller,
                      focusNode: widget.focusNode,
                      formState: formState,
                      onChanged: widget.onChanged,

                      uiControllers: uiControllers,
                    ),
                  ),
                  SingleChildScrollView(
                    key: const PageStorageKey('branding-scroll'),
                    controller: _brandingScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: EditorBrandingView(
                      formState: formState,
                      controller: controller,
                    ),
                  ),
                  // SingleChildScrollView(
                  //   key: const PageStorageKey('blocks-scroll'),
                  //   controller: _blocksScrollController,
                  //   physics: const AlwaysScrollableScrollPhysics(),
                  //   child: Center(
                  //     child: Text('Blocks'),
                  //   ),
                  // ),
                  SingleChildScrollView(
                    key: const PageStorageKey('settings-scroll'),
                    controller: _settingsScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: EditorSettingsView(formId: currentFormId),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
