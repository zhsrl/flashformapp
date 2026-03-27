import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class FFBottomItem {
  FFBottomItem({
    this.icon = HeroIcons.archiveBox,

    this.title = 'Item',
  });
  HeroIcons icon;
  String title;
}

class FFBottomNavBar extends StatefulWidget {
  const FFBottomNavBar({
    super.key,
    required this.onCreateForm,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final VoidCallback? onCreateForm;

  final int selectedIndex;
  final Function(int index) onItemTapped;

  @override
  State<FFBottomNavBar> createState() => _FFBottomNavBarState();
}

class _FFBottomNavBarState extends State<FFBottomNavBar> {
  int? _hoveredIndex;

  List<FFBottomItem> get _items => [
    FFBottomItem(icon: HeroIcons.inbox, title: 'nav-bar.forms'.tr()),
    FFBottomItem(icon: HeroIcons.squares2x2, title: 'nav-bar.leads'.tr()),
    FFBottomItem(icon: HeroIcons.cog6Tooth, title: 'nav-bar.settings'.tr()),
  ];

  Widget _buildNavigationItem(
    FFBottomItem item,
    int index, {
    bool selected = false,

    ValueChanged<int>? onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HeroIcon(
              item.icon,
              color: selected ? AppTheme.primary : Colors.white.withAlpha(100),
              style: selected ? HeroIconStyle.solid : HeroIconStyle.outline,
            ),

            Text(
              item.title,
              style: TextStyle(
                color: selected
                    ? AppTheme.primary
                    : Colors.white.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: .min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(500),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FFButton(
                  onPressed: widget.onCreateForm,

                  text: 'button.new-form-create'.tr(),
                  secondTheme: true,
                  marginBottom: 0,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _items.length,
                    (index) => MouseRegion(
                      onEnter: (event) {
                        setState(() {
                          _hoveredIndex = index;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          _hoveredIndex = null;
                        });
                      },
                      child: AnimatedScale(
                        scale: _hoveredIndex == index ? 1.1 : 1,
                        duration: Duration(milliseconds: 100),
                        child: _buildNavigationItem(
                          _items[index],
                          index,
                          selected: widget.selectedIndex == index,
                          onTap: widget.onItemTapped,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
