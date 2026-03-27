import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/mixins/form_loader_mixin.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/editor_integration_view.dart';
import 'package:flashform_app/features/create_form/views/desktop/editor/views/telegram_integration_settings_view.dart';
import 'package:flashform_app/features/create_form/views/mobile/editor/editor_view_mobile.dart';
import 'package:flashform_app/features/create_form/views/mobile/preview/preview_view_mobile.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateFormMobileView extends ConsumerStatefulWidget {
  const CreateFormMobileView({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<CreateFormMobileView> createState() =>
      _CreateFormMobileViewState();
}

class _CreateFormMobileViewState extends ConsumerState<CreateFormMobileView>
    with SingleTickerProviderStateMixin, FormLoaderMixin {
  bool _isloadingInitialData = true;
  bool isFormNameChange = false;
  bool isCopy = false;

  final FocusNode _focusNode = FocusNode();
  int _tabIndex = 0;

  final TextEditingController _formNameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadFormData(
      widget.formId,
      ref,

      () => mounted,
      () {
        if (!mounted) return;

        setState(() {
          _isloadingInitialData = false;
        });
      },
    );
  }

  Future<void> _updateFormName(String name) async {
    final formControllerNotifier = ref.read(formControllerProvider.notifier);
    final createFormControllerNotifier = ref.read(createFormProvider.notifier);
    await formControllerNotifier.updateFormName(name, widget.formId);

    ref.invalidate(formControllerProvider);
    createFormControllerNotifier.updateFormName(name);
    if (!mounted) return;
    setState(() {
      isFormNameChange = false;
    });
  }

  Future<void> _openURL(String url) async {
    Uri uri = Uri.parse(url);

    await launchUrl(uri);
  }

  Future<void> _onPublishTap() async {
    // Просто вызываем умный метод контроллера
    final success = await ref
        .read(createFormProvider.notifier)
        .publishForm(widget.formId);

    if (!mounted) return;

    if (success) {
      // Если успех — показываем диалог (он никуда не делся!)
      _showLinkDialog(widget.formId);
    } else {
      showSnackbar(
        context,
        type: SnackbarType.error,
        message: 'mobile.publish_error'.tr(),
      );
    }
  }

  Future<void> _showLinkDialog(
    String formId,
  ) async {
    showDialog(
      context: context,

      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final formStatusAsync = ref.watch(formStatusProvider(formId));
            final formSlug = ref.watch(currentFormSlugProvider(formId));

            ref.invalidate(formStatusProvider);

            return AlertDialog(
              backgroundColor: AppTheme.background,
              titlePadding: EdgeInsets.zero,
              title: Container(
                width: 350,
                height: 50,

                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      20,
                    ),
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo-dark.svg',
                    width: 100,
                  ),
                ),
              ),

              content: formStatusAsync.when(
                data: (isActive) {
                  return isActive
                      ? SizedBox(
                          width: 350,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'mobile.page_published'.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  // color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              if (context.isDesktop || context.isTablet)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'https://fform.me/${formSlug.value ?? ''}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        // color: AppTheme.primary,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 8,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        final url =
                                            'https://fform.me/${formSlug.value ?? ''}';
                                        Clipboard.setData(
                                          ClipboardData(text: url),
                                        ).then((_) {
                                          if (!context.mounted) return;
                                          showSnackbar(
                                            context,
                                            type: SnackbarType.info,
                                            message: 'mobile.link_copied'.tr(),
                                          );
                                        });
                                      },
                                      child: HeroIcon(
                                        HeroIcons.documentDuplicate,
                                      ),
                                    ),
                                  ],
                                ),
                              if (context.isMobile)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'https://fform.me',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.tertiary,
                                      ),
                                    ),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '/${formSlug.value ?? ''}',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                            // color: AppTheme.primary,
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 8,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            final url =
                                                'https://fform.me/${formSlug.value ?? ''}';
                                            Clipboard.setData(
                                              ClipboardData(text: url),
                                            ).then((_) {
                                              if (!context.mounted) return;
                                              showSnackbar(
                                                context,
                                                type: SnackbarType.info,
                                                message: 'mobile.link_copied'
                                                    .tr(),
                                              );
                                            });
                                          },
                                          child: HeroIcon(
                                            HeroIcons.documentDuplicate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                height: 16,
                              ),
                              FFButton(
                                onPressed: () async {
                                  await _openURL(
                                    'https://fform.me/${formSlug.value ?? ''}',
                                  );
                                },
                                text: 'common.open'.tr(),
                                secondTheme: true,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  final formController = ref.read(
                                    formControllerProvider.notifier,
                                  );

                                  await formController
                                      .unpublishForm(formId)
                                      .then((_) {
                                        ref.invalidate(formStatusProvider);
                                        ref.invalidate(formControllerProvider);
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      });
                                },
                                icon: HeroIcon(HeroIcons.linkSlash),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.secondary,
                                  iconColor: AppTheme.secondary.withAlpha(100),
                                ),
                                label: Text(
                                  'mobile.or_disable_page'.tr(),
                                  style: TextStyle(
                                    color: AppTheme.secondary.withAlpha(100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 350,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'mobile.page_not_published'.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                },
                error: (er, st) {
                  return Center(
                    child: Text(er.toString()),
                  );
                },
                loading: () => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: LoadingAnimationWidget.waveDots(
                        color: AppTheme.secondary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: Text('mobile.unsaved_changes_title'.tr()),
        content: Text(
          'mobile.unsaved_changes_content'.tr(),
        ),
        actions: [
          FFButton(
            onPressed: () => Navigator.pop(context),
            text: 'common.cancel'.tr(),
          ),
          FFButton(
            onPressed: () {
              Navigator.pop(context);
              _discardChanges();
            },
            text: 'mobile.exit_without_saving'.tr(),
          ),
          FFButton(
            secondTheme: true,
            onPressed: () async {
              Navigator.pop(context);
              await _publishAndLeave();
            },
            text: 'common.publish'.tr(),
          ),
        ],
      ),
    );
  }

  void _showUpdateFormNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: Text('mobile.edit_form_name'.tr()),
        content: FFTextField(
          controller: _formNameController,
          hintText: 'mobile.new_form_name'.tr(),
        ),
        actions: [
          FFButton(
            onPressed: () => Navigator.pop(context),
            text: 'common.cancel'.tr(),
          ),

          FFButton(
            secondTheme: true,
            onPressed: () async {
              String name = _formNameController.text;

              if (name.isEmpty || name == '') return;

              await _updateFormName(name);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            text: 'common.save'.tr(),
          ),
        ],
      ),
    );
  }

  Future<void> _publishAndLeave() async {
    _onPublishTap();

    if (!mounted) return;
    context.pop();

    showSnackbar(
      context,
      type: SnackbarType.error,
      message: 'mobile.error_saving_form'.tr(),
    );
  }

  void _discardChanges() {
    ref.read(createFormProvider.notifier).updateHasChanges(false);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/forms');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);
    ref.watch(formUIControllersProvider);
    return Scaffold(
      endDrawer: TelegramBotIntegrationSettingsView(),
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (formState.hasChanges) {
              _showUnsavedChangesDialog();
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/forms');
              }
            }
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        title: Row(
          children: [
            Text(formState.name ?? ''),
            const SizedBox(
              width: 8,
            ),

            // Change Form name
            GestureDetector(
              onTap: () {
                _showUpdateFormNameDialog();
              },
              child: HeroIcon(
                HeroIcons.pencil,
                color: AppTheme.secondary.withAlpha(100),
                style: HeroIconStyle.solid,
                size: 15,
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 16,
        ),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: AppTheme.background,
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [
          IconButton.outlined(
            onPressed: () {
              _showLinkDialog(widget.formId);
            },
            icon: HeroIcon(HeroIcons.link),
          ),
          const SizedBox(
            width: 8,
          ),
          IconButton.filled(
            onPressed: () async {
              await _onPublishTap();
            },
            icon: HeroIcon(HeroIcons.arrowUpOnSquare),
          ),
        ],
      ),

      body: _isloadingInitialData
          ? Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppTheme.secondary,
                size: 40,
              ),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DefaultTabController(
                    length: 3,
                    child: FFTabBar(
                      onTap: (index) {
                        setState(() {
                          _tabIndex = index;
                        });
                      },
                      tabs: [
                        Text('mobile.tab_editor'.tr()),
                        Text('mobile.tab_preview'.tr()),
                        Text('mobile.tab_integrations'.tr()),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _tabIndex,
                      children: [
                        EditorViewMobile(
                          onChanged: ref
                              .read(createFormProvider.notifier)
                              .markAsChanged,
                          focusNode: _focusNode,
                        ),
                        PreviewViewMobile(focusNode: _focusNode),
                        EditorIntergrationView(
                          formId: widget.formId,
                        ),
                      ],
                    ),
                  ),

                  // Expanded(
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _formNameController.dispose();
    super.dispose();
  }
}
