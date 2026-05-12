import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/formui_controller.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/controller/logo_image_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

class PreviewView extends ConsumerStatefulWidget {
  const PreviewView({
    super.key,

    required this.focusNode,
  });

  final FocusNode focusNode;

  @override
  ConsumerState<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends ConsumerState<PreviewView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 1; // 0 = Mobile, 1 = Desktop

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormProvider);
    final imageState = ref.watch(imageControllerProvider);
    final logoImageState = ref.watch(logoImageControllerProvider);
    final uiControllers = ref.watch(formUIControllersProvider);

    return Expanded(
      child: Align(
        alignment: .center,
        child: Column(
          mainAxisSize: .min,
          children: [
            if (!context.isMobile)
              FFTabBar(
                width: 350,
                controller: _tabController,
                onTap: (index) => setState(() {
                  _tabIndex = index;
                }),
                isSecondTheme: true,
                tabs: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HeroIcon(HeroIcons.devicePhoneMobile),
                      const SizedBox(
                        width: 6,
                      ),
                      Text('Мобильный'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HeroIcon(HeroIcons.computerDesktop),
                      const SizedBox(
                        width: 6,
                      ),
                      Text('Десктоп'),
                    ],
                  ),
                ],
              ),
            const SizedBox(
              height: 16,
            ),
            // 3. Основной контент превью
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: _buildDeviceFrame(
                  formState,
                  imageState,
                  logoImageState,
                  uiControllers,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceFrame(
    CreateFormState formState,
    ImageUploadState imageState,
    ImageUploadState logoImageState,
    FormUIControllers uiControllers,
  ) {
    final isDesktop = _tabIndex == 1;
    final hasLogo =
        logoImageState.localImageBytes != null ||
        (formState.logo != null && formState.logo!.isNotEmpty) ||
        (logoImageState.imageUrl != null &&
            logoImageState.imageUrl!.isNotEmpty);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linearToEaseOut,
      width: isDesktop ? context.screenWidth : 350, // Адаптивная ширина
      height: context.screenHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: formState.theme == 'light'
            ? Colors.white
            : const Color(0xFF191D1F),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(width: 1, color: AppTheme.border),
      ),
      child: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // FIRST PAGE DETAILS
            Column(
              children: [
                Container(
                  width: 400,

                  decoration: BoxDecoration(
                    color: formState.theme == 'light'
                        ? Color(0xFFEFEFEF)
                        : Color(0xFF292D30),
                    borderRadius: BorderRadius.circular(40),
                  ),

                  padding: EdgeInsets.all(32),

                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: [
                      if (hasLogo || formState.hasBadge)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (hasLogo)
                              _buildLogoImage(formState, logoImageState),
                            if (formState.hasBadge)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    width: 1.5,
                                    color: formState.theme == 'light'
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                child: ListenableBuilder(
                                  listenable: uiControllers.badgeController,
                                  builder: (context, child) {
                                    return Text(
                                      uiControllers.badgeController.text,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: formState.theme == 'light'
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      if (hasLogo || formState.hasBadge)
                        const SizedBox(height: 16),

                      SizedBox(
                        width: 300,
                        child: ListenableBuilder(
                          listenable: uiControllers.titleController,
                          builder: (_, __) => Text(
                            uiControllers.titleController.text,
                            textAlign: TextAlign.start,

                            style: TextStyle(
                              height: 1.1,
                              letterSpacing: -0.5,
                              fontSize: 34,
                              color: formState.theme == 'light'
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      ListenableBuilder(
                        listenable: uiControllers.subtitleController,
                        builder: (_, __) => Text(
                          uiControllers.subtitleController.text,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            height: 1.2,
                            letterSpacing: -0.015,
                            fontSize: 16,
                            color: formState.theme == 'light'
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),

                      // FIRST BUTTON
                      Container(
                        width: isDesktop
                            ? context.screenWidth
                            : 350, // Адаптивная ширина
                        margin: EdgeInsets.only(
                          top: 32,
                        ),
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                formState.primaryColor, // Из стейта
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(500),
                            ),
                          ),
                          child: ListenableBuilder(
                            listenable: uiControllers.mainFirstButtonController,
                            builder: (_, __) => Text(
                              uiControllers.mainFirstButtonController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // SECOND BUTTON
                      if (formState.hasSecondButton)
                        Container(
                          width: isDesktop
                              ? context.screenWidth
                              : 350, // Адаптивная ширина
                          margin: EdgeInsets.only(
                            top: 8,
                          ),
                          height: 60,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              elevation: 0,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(500),
                                side: BorderSide(
                                  width: 2,
                                  color: formState.theme == 'dark'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            child: ListenableBuilder(
                              listenable:
                                  uiControllers.mainSecondButtonController,
                              builder: (_, __) => Text(
                                uiControllers.mainSecondButtonController.text,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // Hero Image
                _buildHeroImage(formState, imageState, _tabIndex),

                SizedBox(
                  width: _tabController.index == 0
                      ? 350
                      : 400, // Контент всегда ограничен шириной мобилки для читаемости
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Action Widget (Button or Form)
                      // _buildWidgetByActionType(formState, uiControllers),
                      // Footer
                      if (formState.hasFooter) _buildFooter(formState),
                      // Branding
                      _buildFlashformBrandingWidget(formState),
                    ],
                  ),
                ),
              ],
            ),

            // SUCCESS OVERLAY LAYER
            ListenableBuilder(
              listenable: widget.focusNode,
              builder: (context, child) {
                final hasFocus = widget.focusNode.hasFocus;
                return IgnorePointer(
                  ignoring: !hasFocus,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: hasFocus ? 1 : 0,
                    child: Container(
                      height: context.screenHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withAlpha(100),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          width: 300,
                          decoration: BoxDecoration(
                            color: formState.theme == 'light'
                                ? Colors.white
                                : AppTheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const HeroIcon(
                                HeroIcons.checkCircle,
                                style: HeroIconStyle.solid,
                                color: Colors.green,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              ListenableBuilder(
                                listenable: uiControllers.successTextController,
                                builder: (_, __) => Text(
                                  uiControllers.successTextController.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: formState.theme == 'light'
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(
    CreateFormState formState,
    ImageUploadState imageState,
    int index,
  ) {
    if (imageState.localImageBytes != null) {
      return Container(
        width: index == 0 ? 350 : 400,
        height: index == 0 ? 350 : 400,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
        child: Image.memory(
          imageState.localImageBytes!,

          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(formState, index),
        ),
      );
    }
    if (formState.heroImageUrl != null) {
      return Container(
        clipBehavior: Clip.hardEdge,
        width: index == 0 ? 350 : 400,
        height: index == 0 ? 350 : 400,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
        child: Image.network(
          formState.heroImageUrl!,

          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(formState, index),
        ),
      );
    }

    // return _buildPlaceholder(formState, index);
    return SizedBox();
  }

  Widget _buildLogoImage(
    CreateFormState formState,
    ImageUploadState logoImageState,
  ) {
    final localBytes = logoImageState.localImageBytes;
    final logoUrl = formState.logo ?? logoImageState.imageUrl;
    if (localBytes == null && (logoUrl == null || logoUrl.isEmpty)) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 32,
        maxWidth: 140,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: localBytes != null
            ? Image.memory(
                localBytes,
                fit: BoxFit.contain,
              )
            : Image.network(
                logoUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
      ),
    );
  }

  Widget _buildPlaceholder(
    CreateFormState formState,
    int index,
  ) {
    return Container(
      width: index == 0 ? 350 : 400,
      height: index == 0 ? 350 : 400,
      decoration: BoxDecoration(
        color: formState.theme == 'light' ? AppTheme.border : AppTheme.fourty,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: HeroIcon(
          HeroIcons.photo,
          size: 50,
          color: Colors.black.withAlpha(50),
        ),
      ),
    );
  }

  Widget _buildFooter(
    CreateFormState formState,
  ) {
    String companyName = formState.footerCompanyName ?? '';
    String idNumber = formState.footerIdNumber ?? '';
    String address = formState.footerAddress ?? '';
    final formStateWatch = ref.watch(createFormProvider);

    return Container(
      width: 350,
      margin: EdgeInsets.only(top: 16),
      // decoration: BoxDecoration(
      //   color: formState.theme == 'light'
      //       ? Colors.white
      //       : const Color.fromARGB(255, 32, 30, 36),
      //   borderRadius: BorderRadius.circular(20),
      // ),
      child: Column(
        children: [
          Divider(
            color: Color(0xFF6B7280),
            thickness: 0.2,
          ),
          if (formStateWatch.footerLinks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: formStateWatch.footerLinks
                      .map(
                        (link) => InkWell(
                          onTap: () {
                            // Открыть ссылку
                          },
                          child: Text(
                            link.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          const SizedBox(
            height: 8,
          ),
          ListenableBuilder(
            listenable: ref
                .watch(formUIControllersProvider)
                .footerCompanyNameController,
            builder: (context, child) {
              return ListenableBuilder(
                listenable: ref
                    .watch(formUIControllersProvider)
                    .footerIdNumberController,
                builder: (context, child) {
                  return ListenableBuilder(
                    listenable: ref
                        .watch(formUIControllersProvider)
                        .footerAddressController,
                    builder: (context, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$companyName\n ЖСН/ИИН $idNumber\n$address',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: formState.theme == 'light'
                                  ? Colors.black
                                  : Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildFlashformBrandingWidget(CreateFormState formState) {
  return Visibility(
    visible: formState.hasLabel,
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Made on',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: formState.theme == 'light' ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              formState.theme == 'light'
                  ? 'assets/images/logo-light.svg'
                  : 'assets/images/logo-dark.svg',
              width: 100,
            ),
          ],
        ),
      ),
    ),
  );
}
