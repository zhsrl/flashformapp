import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/data/model/form.dart';
import 'package:flashform_app/data/model/form_link.dart';
import 'package:flashform_app/data/repository/form_repository.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final allFormsProvider = FutureProvider.autoDispose<List<FormModel>>((
  ref,
) async {
  final formRepository = ref.watch(formRepoProvider);
  return await formRepository.getAllForms();
});

class BuildFooterBlock extends ConsumerStatefulWidget {
  const BuildFooterBlock({
    super.key,
    required this.uiControllers,
    required this.formState,
    required this.isAvailable,
  });

  final FormUIControllers uiControllers;
  final CreateFormState formState;
  final bool isAvailable;

  @override
  ConsumerState<BuildFooterBlock> createState() => _BuildFooterBlockState();
}

class _BuildFooterBlockState extends ConsumerState<BuildFooterBlock> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.formState.hasFooter;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.screenWidth,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(width: 1.5, color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'forms.footer_title'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (!widget.isAvailable)
                        Row(
                          children: [
                            HeroIcon(
                              HeroIcons.informationCircle,
                              size: 15,
                              color: Colors.deepOrangeAccent,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              'forms.available_go_pro'.tr(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (!widget.isAvailable)
                    SizedBox()
                  else
                    CupertinoSwitch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = !_isActive;
                          widget.uiControllers.updateHasFooter(_isActive);
                        });
                      },
                    ),
                ],
              ),
              if (_isActive)
                Container(
                  margin: EdgeInsets.only(top: 16),
                  width: context.screenWidth,
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => CopyFooterDialog(
                          uiControllers: widget.uiControllers,
                        ),
                      );
                    },
                    icon: HeroIcon(HeroIcons.documentDuplicate),
                    label: Text('forms.copy_from_another_form'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.border,
                      foregroundColor: AppTheme.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (_isActive)
          BuildFooterContent(
            uiControllers: widget.uiControllers,
            formState: widget.formState,
          ),
      ],
    );
  }
}

class BuildFooterContent extends StatefulWidget {
  const BuildFooterContent({
    super.key,
    required this.uiControllers,
    required this.formState,
  });

  final FormUIControllers uiControllers;
  final CreateFormState formState;

  @override
  State<BuildFooterContent> createState() => _BuildFooterContentState();
}

class _BuildFooterContentState extends State<BuildFooterContent> {
  bool legalSectionOpened = false;
  bool linksSectionOpened = false;

  late List<(TextEditingController label, TextEditingController url)>
  _linkControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeLinkControllers();
  }

  @override
  void dispose() {
    super.dispose();
    _disposeLinkControllers();
  }

  @override
  void didUpdateWidget(BuildFooterContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Пересинхронизируем контроллеры если footerLinks было изменено извне (не через ввод)
    if (oldWidget.formState.footerLinks.length !=
        widget.formState.footerLinks.length) {
      _disposeLinkControllers();
      _initializeLinkControllers();
    }
  }

  void _disposeLinkControllers() {
    for (var controllers in _linkControllers) {
      controllers.$1.dispose();
      controllers.$2.dispose();
    }
  }

  void _initializeLinkControllers() {
    _linkControllers = widget.formState.footerLinks
        .map(
          (link) => (
            TextEditingController(text: link.label),
            TextEditingController(text: link.url),
          ),
        )
        .toList();

    for (var controllers in _linkControllers) {
      controllers.$1.addListener(_updateFooterLinks);
      controllers.$2.addListener(_updateFooterLinks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLegalInfoSection(),
        _buildLinkSection(),
      ],
    );
  }

  Widget _buildLegalInfoSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          legalSectionOpened = !legalSectionOpened;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,

          border: Border.all(
            width: 1.5,
            color: Colors.transparent,
          ),
        ),

        padding: EdgeInsets.all(16),
        width: context.screenWidth,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'forms.legal_data_section'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      legalSectionOpened = !legalSectionOpened;
                    });
                  },
                  child: HeroIcon(
                    legalSectionOpened
                        ? HeroIcons.arrowDown
                        : HeroIcons.arrowLeft,
                    size: 20,
                  ),
                ),
              ],
            ),

            if (legalSectionOpened)
              Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  FFTextField(
                    hintText: 'forms.company_name'.tr(),
                    controller:
                        widget.uiControllers.footerCompanyNameController,
                  ),
                  FFTextField(
                    hintText: 'forms.iin'.tr(),
                    controller: widget.uiControllers.footerIdNumberController,
                  ),
                  FFTextField(
                    hintText: 'forms.address'.tr(),
                    controller: widget.uiControllers.footerAddressController,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          linksSectionOpened = !linksSectionOpened;
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          border: Border.all(width: 1.5, color: AppTheme.border),
        ),
        padding: EdgeInsets.all(16),
        width: context.screenWidth,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'forms.links_section'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      linksSectionOpened = !linksSectionOpened;
                    });
                  },
                  child: HeroIcon(
                    linksSectionOpened
                        ? HeroIcons.arrowDown
                        : HeroIcons.arrowLeft,
                    size: 20,
                  ),
                ),
              ],
            ),

            if (linksSectionOpened)
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    width: context.screenWidth,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          final labelController = TextEditingController();
                          final urlController = TextEditingController();

                          labelController.addListener(() {
                            _updateFooterLinks();
                          });
                          urlController.addListener(() {
                            _updateFooterLinks();
                          });

                          _linkControllers.add((
                            labelController,
                            urlController,
                          ));
                        });
                      },
                      icon: HeroIcon(HeroIcons.plus),
                      label: Text('common.add'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.border,
                        foregroundColor: AppTheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (_linkControllers.isNotEmpty)
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _linkControllers.length,
                      shrinkWrap: true,
                      // separatorBuilder: (context, index) =>
                      //     const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final controllers = _linkControllers[index];
                        return LinkItem(
                          key: ObjectKey(controllers),
                          labelController: controllers.$1,
                          urlController: controllers.$2,
                          onDelete: () {
                            setState(() {
                              _linkControllers.removeAt(index);
                              _updateFooterLinks();
                            });
                          },
                        );
                      },
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _updateFooterLinks() {
    final links = _linkControllers
        .map(
          (controllers) => FooterLink(
            label: controllers.$1.text,
            url: controllers.$2.text,
          ),
        )
        .toList();

    widget.uiControllers.updateFooterLinks(links);
  }
}

class LinkItem extends StatefulWidget {
  const LinkItem({
    super.key,
    required this.labelController,
    required this.urlController,
    this.onDelete,
  });

  final TextEditingController labelController;
  final TextEditingController urlController;
  final VoidCallback? onDelete;

  @override
  State<LinkItem> createState() => _LinkItemState();
}

class _LinkItemState extends State<LinkItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FFTextField(
            hintText: 'forms.link_name'.tr(),
            controller: widget.labelController,
            enabled: true,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: FFTextField(
            hintText: 'forms.link_url'.tr(),
            prefixIcon: HeroIcon(HeroIcons.link),
            controller: widget.urlController,
            enabled: true,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        InkWell(
          onTap: widget.onDelete,
          child: HeroIcon(
            HeroIcons.xMark,
          ),
        ),
      ],
    );
  }
}

class CopyFooterDialog extends ConsumerStatefulWidget {
  const CopyFooterDialog({
    super.key,
    required this.uiControllers,
  });

  final FormUIControllers uiControllers;

  @override
  ConsumerState<CopyFooterDialog> createState() => _CopyFooterDialogState();
}

class _CopyFooterDialogState extends ConsumerState<CopyFooterDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('forms.choose_form'.tr()),
      backgroundColor: AppTheme.background,
      content: SizedBox(
        width: 400,
        height: 300,
        child: ref
            .watch(allFormsProvider)
            .when(
              data: (forms) {
                // Фильтруем только формы с footer
                final formsWithFooter = forms.where((form) {
                  final data = form.data;

                  return data?.containsKey('footer') == true;
                }).toList();

                if (formsWithFooter.isEmpty) {
                  return Center(
                    child: Text('forms.no_forms_with_footer'.tr()),
                  );
                }

                return ListView.separated(
                  itemCount: formsWithFooter.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 8,
                  ),
                  itemBuilder: (context, index) {
                    final form = formsWithFooter[index];
                    final footerCompany =
                        form.data?['footer']['legal-info']['company-name'];

                    final footerIdNumber =
                        form.data?['footer']['legal-info']['id-number'];

                    final footerAdress =
                        form.data?['footer']['legal-info']['address'];
                    final footerLinks = form.data?['footer']['links'];

                    return InkWell(
                      onTap: () {
                        _copyFooterData(form);
                        Navigator.pop(context);
                      },
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),

                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              form.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    'forms.legal_short'.tr(),
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        footerCompany,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        footerIdNumber,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        footerAdress,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (footerLinks.isNotEmpty) ...[
                              Divider(
                                thickness: 0.4,
                                height: 32,
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      'forms.links_short'.tr(),
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: ListView.separated(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final link =
                                            footerLinks[index]
                                                as Map<String, dynamic>;
                                        return Text(
                                          link
                                              .toString()
                                              .replaceAll('{', '')
                                              .replaceAll('}', ''),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            height: 4,
                                          ),
                                      itemCount: footerLinks.length,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                child: LoadingAnimationWidget.waveDots(
                  color: AppTheme.secondary,
                  size: 30,
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'common.error_with_message'.tr(
                    namedArgs: {'message': '$error'},
                  ),
                ),
              ),
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.secondary,
          ),
          child: Text('common.cancel'.tr()),
        ),
      ],
    );
  }

  void _copyFooterData(FormModel sourceForm) {
    final data = sourceForm.data;

    final sourceFooterLinks = (data?['footer']['links'] as List<dynamic>).map((
      link,
    ) {
      return FooterLink(
        label: link?.entries.first.key ?? '',
        url: link?.entries.first.value ?? '',
      );
    }).toList();
    const footerState = CreateFormState(
      hasFooter: true,
      footerCompanyName: '',
      footerIdNumber: '',
      footerAddress: '',
      footerLinks: [],
    );

    final copySourceFooter = footerState.copyWith(
      hasFooter: data?['footer']['enabled'] ?? false,
      footerCompanyName:
          data?['footer']['legal-info']['company-name'] as String?,
      footerIdNumber: data?['footer']['legal-info']['id-number'] as String?,
      footerAddress: data?['footer']['legal-info']['address'] as String?,
      footerLinks: sourceFooterLinks,
    );

    ref.read(createFormProvider.notifier).copyFooterFromForm(copySourceFooter);

    widget.uiControllers.updateFooterValues(
      footerCompanyName: copySourceFooter.footerCompanyName,
      footerIdNumber: copySourceFooter.footerIdNumber,
      footerAddress: copySourceFooter.footerAddress,
    );
  }
}
