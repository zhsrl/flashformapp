import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/editor_content_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/editor_integration_view.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  int _tabIndex = 0;
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Подписываемся на стейт
    final formState = ref.watch(createFormProvider);
    final currentFormId = ref.watch(currentFormIdProvider);
    final controller = ref.read(createFormProvider.notifier);
    final uiControllers = ref.watch(formUIControllersProvider);

    return SizedBox(
      width: 350,
      child: Column(
        children: [
          FFTabBar(
            tabs: [
              Text('Контент'),
              // Text('Footer'),
              Text('Интеграция'),
            ],
            controller: _tabController,
            onTap: (index) {
              setState(() {
                _tabIndex = index;
              });
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
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 350,
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _tabIndex == 0
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,

                      // Вкладка "Контент"
                      firstChild: EditorContentView(
                        controller: controller,
                        focusNode: widget.focusNode,
                        formState: formState,
                        onChanged: widget.onChanged,
                        ref: ref,
                        uiControllers: uiControllers,
                      ),

                      secondChild: EditorIntergrationView(
                        formId: currentFormId,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
