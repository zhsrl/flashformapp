import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/createform_controller.dart';
import 'package:flashform_app/data/controller/image_controller.dart';
import 'package:flashform_app/data/model/create_form_state.dart';
import 'package:flashform_app/data/service/image_service.dart';
import 'package:flashform_app/features/widgets/ff_tabbar.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

class PreviewView extends ConsumerStatefulWidget {
  const PreviewView({
    super.key,
    required this.titleController,
    required this.subtitleController,
    required this.formTitleController,
    required this.buttonTextController,
    required this.formButtonTextController,
    required this.successTextController,
    required this.focusNode,
  });

  final TextEditingController titleController;
  final TextEditingController subtitleController;
  final TextEditingController formTitleController;
  final TextEditingController buttonTextController;
  final TextEditingController formButtonTextController;
  final TextEditingController successTextController;
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
    // 1. Подписываемся на стейт формы
    final formState = ref.watch(createFormProvider);
    final imageState = ref.watch(imageControllerProvider);

    return Expanded(
      child: Column(
        children: [
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
            child: SingleChildScrollView(
              child: _buildDeviceFrame(formState, imageState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceFrame(
    CreateFormState formState,
    ImageUploadState imageState,
  ) {
    final isDesktop = _tabIndex == 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linearToEaseOut,
      width: isDesktop ? context.screenWidth : 350, // Адаптивная ширина
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: formState.theme == 'light'
            ? const Color(0xFFF1F2F7)
            : const Color(0xFF0f0d12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: AppTheme.border),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // CONTENT LAYER
          Column(
            children: [
              // Hero Image
              _buildHeroImage(formState, imageState),
              const SizedBox(height: 8),

              SizedBox(
                width:
                    350, // Контент всегда ограничен шириной мобилки для читаемости
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    ListenableBuilder(
                      listenable: widget.titleController,
                      builder: (_, __) => Text(
                        widget.titleController.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.2,
                          fontSize: formState.titleFontSize, // Берем из стейта
                          color: formState.theme == 'light'
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    ListenableBuilder(
                      listenable: widget.subtitleController,
                      builder: (_, __) => Text(
                        widget.subtitleController.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.2,
                          fontSize:
                              formState.subtitleFontSize, // Берем из стейта
                          color: formState.theme == 'light'
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Widget (Button or Form)
                    _buildWidgetByActionType(formState),

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
                              listenable: widget.successTextController,
                              builder: (_, __) => Text(
                                widget.successTextController.text,
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
    );
  }

  Widget _buildHeroImage(
    CreateFormState formState,
    ImageUploadState imageState,
  ) {
    if (imageState.localImageBytes != null) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Image.memory(
          imageState.localImageBytes!,
          width: 318,
          height: 318,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(formState),
        ),
      );
    }
    if (formState.heroImageUrl != null) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Image.network(
          formState.heroImageUrl!,
          width: 318,
          height: 318,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(formState),
        ),
      );
    }

    return _buildPlaceholder(formState);
  }

  Widget _buildPlaceholder(CreateFormState formState) {
    return Container(
      width: 350,
      height: 350,
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

  Widget _buildWidgetByActionType(CreateFormState formState) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: formState.actionType == 'button-url'
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,

      // CASE 1: Button URL
      firstChild: SizedBox(
        width: context.screenWidth,
        height: 60,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: formState.buttonColor, // Из стейта
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: ListenableBuilder(
            listenable: widget.buttonTextController,
            builder: (_, __) => Text(
              widget.buttonTextController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),

      // CASE 2: Form Fields
      secondChild: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: formState.theme == 'light'
              ? Colors.white
              : const Color(0xFF252429),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            width: 1,
            color: formState.theme == 'light'
                ? const Color(0xFFDDDDDD)
                : const Color(0xFF414046),
          ),
        ),
        child: Column(
          children: [
            ListenableBuilder(
              listenable: widget.formTitleController,
              builder: (_, __) => SizedBox(
                width: 270,
                child: Text(
                  widget.formTitleController.text.isEmpty
                      ? 'Заголовок формы'
                      : widget.formTitleController.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: formState.theme == 'light'
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Список полей из стейта
            if (formState.fields.isNotEmpty)
              ListView.builder(
                itemCount: formState.fields.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final field = formState.fields[index];
                  return FFTextField(
                    height: 2.0,
                    prefixIcon: HeroIcon(
                      field.type == 'phone'
                          ? HeroIcons.phone
                          : field.type == 'email'
                          ? HeroIcons.envelope
                          : field.type == 'text'
                          ? HeroIcons.chatBubbleOvalLeftEllipsis
                          : HeroIcons.user,
                    ),
                    hintText: field.label,
                  );
                },
              ),

            SizedBox(
              width: context.screenWidth,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: formState.formButtonColor, // Из стейта
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: ListenableBuilder(
                  listenable: widget.formButtonTextController,
                  builder: (_, __) => Text(
                    widget.formButtonTextController.text,
                    style: const TextStyle(
                      color: Colors.white,
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
    );
  }

  Widget _buildFlashformBrandingWidget(CreateFormState formState) {
    return Container(
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
    );
  }
}
