import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/editor_content_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/editor_integration_view.dart';
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
  late final ScrollController _contentScrollController;
  late final ScrollController _integrationScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: ref.read(editorTabIndexProvider),
    );
    _contentScrollController = ScrollController();
    _integrationScrollController = ScrollController();
    // _tabController.addListener(() {
    //   ref.read(editorTabIndexProvider.notifier).state = _tabController.index;
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentScrollController.dispose();
    _integrationScrollController.dispose();

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
      width: 400,
      child: Column(
        children: [
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
              Text(
                'Блоки',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    key: const PageStorageKey('editor-content-scroll'),
                    controller: _contentScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: EditorContentView(
                      controller: controller,
                      focusNode: widget.focusNode,
                      formState: formState,
                      onChanged: widget.onChanged,
                      labelOnChanged: (value) {},
                      ref: ref,
                      uiControllers: uiControllers,
                    ),
                  ),
                  SingleChildScrollView(
                    key: const PageStorageKey('editor-blocks-scroll'),
                    controller: _contentScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Text('Branding'),
                    ),
                  ),
                  SingleChildScrollView(
                    key: const PageStorageKey('editor-blocks-scroll'),
                    controller: _contentScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Text('Blocks'),
                    ),
                  ),
                  SingleChildScrollView(
                    key: const PageStorageKey('editor-integration-scroll'),
                    controller: _integrationScrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: EditorIntergrationView(formId: currentFormId),
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
