import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/model/form_model.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({
    super.key,
    this.fields,
    this.formKey,
    this.formTitleController,
    this.subtitleController,
    this.titleController,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.onThemeChanged,
    this.formTheme = 'light',
    this.actionType = 'button-url',
    this.buttonColor,
    this.onButtonColorChanged,
    this.successTextFieldFocusNode,
    this.formButtonColor,
    this.onFormButtonColorChanged,
    this.formButtonTextController,
    this.heroImageUrl,
    this.onHeroImageChanged,
    this.buttonTextController,
    this.successTextController,
    this.focusNode,
  });

  final List<FormFields>? fields;
  final GlobalKey<FormState>? formKey;
  final String formTheme;
  final String? heroImageUrl;
  final String? actionType;
  final Color? buttonColor;
  final Color? formButtonColor;
  final ValueChanged<Color>? onButtonColorChanged;
  final ValueChanged<Color>? onFormButtonColorChanged;
  final ValueChanged<String?>? onHeroImageChanged;
  final ValueChanged<String?> onThemeChanged;
  final TextEditingController? titleController;
  final double titleFontSize;
  final FocusNode? successTextFieldFocusNode;
  final TextEditingController? subtitleController;
  final double subtitleFontSize;
  final TextEditingController? formTitleController;

  // success text options
  final TextEditingController? successTextController;
  final FocusNode? focusNode;

  final TextEditingController? buttonTextController;
  final TextEditingController? formButtonTextController;

  @override
  State<PreviewView> createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  int _tabIndex = 0;

  @override
  void didUpdateWidget(covariant PreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fields != widget.fields ||
        oldWidget.actionType != widget.actionType) {
      setState(() {});
    }
  }

  Widget _buildMainContent() {
    TextEditingController titleController = widget.titleController!;
    TextEditingController subtitleController = widget.subtitleController!;
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),

      curve: Curves.linearToEaseOut,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.formTheme == 'light'
            ? Color(0xFFF1F2F7)
            : Color(0xFF0f0d12),

        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1,
          color: AppTheme.border,
        ),
      ),
      width: _tabIndex == 1 ? context.screenWidth : 350,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              // HERO IMAGE
              widget.heroImageUrl != null
                  ? Container(
                      clipBehavior: Clip.hardEdge,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Image.network(
                        widget.heroImageUrl!,
                        width: 318,
                        height: 318,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        color: widget.formTheme == 'light'
                            ? AppTheme.border
                            : AppTheme.fourty,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: HeroIcon(
                          HeroIcons.photo,
                          size: 50,
                          color: Colors.black.withAlpha(
                            50,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TITLE
                    ListenableBuilder(
                      listenable: widget.titleController!,
                      builder: (context, Widget? child) {
                        return Text(
                          titleController.text,
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            height: 1.2,
                            fontSize: widget.titleFontSize,
                            color: widget.formTheme == 'light'
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    // SUBTITLE
                    ListenableBuilder(
                      listenable: widget.subtitleController!,
                      builder: (context, Widget? child) {
                        return Text(
                          subtitleController.text,
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            height: 1.2,
                            fontSize: widget.subtitleFontSize,
                            color: widget.formTheme == 'light'
                                ? Colors.black
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildWidgetByActionType(),
                    _buildFlashformBrandingWidget(),
                  ],
                ),
              ),
            ],
          ),
          ListenableBuilder(
            listenable: widget.focusNode!,
            builder: (context, child) {
              return ListenableBuilder(
                listenable: widget.successTextController!,
                builder: (context, child2) {
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: 100),
                    opacity: widget.focusNode!.hasFocus ? 1 : 0,
                    child: Container(
                      width: _tabIndex == 0 ? 350 : context.screenWidth,
                      height: context.screenHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black.withAlpha(100),
                      ),

                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: widget.formTheme == 'light'
                                ? Colors.white
                                : AppTheme.secondary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HeroIcon(
                                HeroIcons.checkCircle,
                                style: HeroIconStyle.solid,
                                color: Colors.green,
                                size: 100,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: 300,
                                child: Text(
                                  widget.successTextController?.text ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: widget.formTheme == 'light'
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
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetByActionType() {
    if (widget.actionType == 'button-url') {
      return SizedBox(
        width: context.screenWidth,
        height: 60,

        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: widget.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
          ),
          child: ListenableBuilder(
            listenable: widget.buttonTextController!,
            builder:
                (
                  context,
                  Widget? child,
                ) {
                  return Text(
                    widget.buttonTextController!.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
          ),
        ),
      );
    } else if (widget.actionType == 'form') {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.formTheme == 'light' ? Colors.white : Color(0xFF252429),
          borderRadius: BorderRadius.circular(40),
          border: BoxBorder.all(
            width: 1,
            color: widget.formTheme == 'light'
                ? Color(0xFFDDDDDD)
                : Color(0xFF414046),
          ),
        ),
        child: Column(
          children: [
            ListenableBuilder(
              listenable: widget.formTitleController!,
              builder:
                  (
                    context,
                    child,
                  ) {
                    return SizedBox(
                      width: 270,
                      child: Text(
                        widget.formTitleController?.text ?? 'Заголовок формы',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: widget.formTheme == 'light'
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    );
                  },
            ),
            const SizedBox(
              height: 16,
            ),
            ListView.builder(
              itemCount: widget.fields?.length ?? 0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final field = widget.fields?[index];

                return FFTextField(
                  height: 2.0,
                  prefixIcon: HeroIcon(
                    field!.type == 'phone'
                        ? HeroIcons.phone
                        : field.type == 'name'
                        ? HeroIcons.user
                        : HeroIcons.envelope,
                  ),
                  hintText: field.label,
                );
              },
            ),
            const SizedBox(
              height: 8,
            ),

            SizedBox(
              width: context.screenWidth,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: widget.formButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
                child: ListenableBuilder(
                  listenable: widget.formButtonTextController!,
                  builder:
                      (
                        context,
                        Widget? child,
                      ) {
                        return Text(
                          widget.formButtonTextController!.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }

  _buildFlashformBrandingWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 16),

      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Made on',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.formTheme == 'light'
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            SvgPicture.asset(
              widget.formTheme == 'light'
                  ? 'images/logo-light.svg'
                  : 'images/logo-dark.svg',
              width: 100,
            ),
          ],
        ),
      ),
    );
  }

  String? getYouTubeEmbedUrl(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );

    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final videoId = match.group(1);
      return 'https://www.youtube.com/embed/$videoId';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _tabIndex,
      length: 2,
      child: SizedBox(
        width: _tabIndex == 0 ? 350 : 500,

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.fourty,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,

                  fontFamily: 'GoogleSans',
                ),

                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.secondary.withAlpha(50),
                onTap: (index) {
                  setState(() {
                    _tabIndex = index;
                    debugPrint('Tab index: $_tabIndex');
                  });
                },

                indicator: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(15),
                ),
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
            ),

            // Tab bar
            const SizedBox(
              height: 16,
            ),

            // Main content
            _buildMainContent(),
          ],
        ),
      ),
    );
  }
}
