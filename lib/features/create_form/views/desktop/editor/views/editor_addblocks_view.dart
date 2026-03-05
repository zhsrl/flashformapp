import 'package:dashed_border/dashed_border.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class EditorAdditionalBlocksView extends StatefulWidget {
  const EditorAdditionalBlocksView({super.key});

  @override
  State<EditorAdditionalBlocksView> createState() =>
      _EditorAdditionalBlocksViewState();
}

class _EditorAdditionalBlocksViewState
    extends State<EditorAdditionalBlocksView> {
  List<String> additionalBlockTypes = [];
  Set<String> blocks = {};

  bool _isHover = false;
  bool _isFooterOpen = false;

  void showBlockSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Выберите тип блока',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Подвал'),
                leading: HeroIcon(
                  HeroIcons.viewColumns,
                  color: Colors.blue,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                onTap: () {
                  setState(() {
                    additionalBlockTypes.add('footer');
                  });
                  Navigator.of(context).pop();
                },
              ),

              ListTile(
                title: Text('Отзывы'),
                leading: HeroIcon(
                  HeroIcons.chatBubbleOvalLeft,
                  color: Colors.red,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text(
                  'Приемущества',
                ),
                leading: HeroIcon(
                  HeroIcons.chartBar,
                  color: Colors.green,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('FAQ'),
                leading: HeroIcon(
                  HeroIcons.questionMarkCircle,
                  color: Colors.deepPurpleAccent,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  HeroIcon(
                    HeroIcons.viewColumns,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text('Footer'),
                ],
              ),
              GestureDetector(
                onTap: () {
                  debugPrint('Footer opened: $_isFooterOpen');
                  setState(() {
                    _isFooterOpen = !_isFooterOpen;
                  });
                },
                child: HeroIcon(
                  _isFooterOpen ? HeroIcons.arrowDown : HeroIcons.arrowLeft,
                ),
              ),
            ],
          ),

          // Content
          AnimatedSwitcher(
            duration: Duration(
              milliseconds: 200,
            ),
            child: _isFooterOpen
                ? Column(
                    children: [],
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (additionalBlockTypes.isEmpty) {
      return MouseRegion(
        onEnter: (event) => setState(() {
          _isHover = true;
        }),
        onExit: (event) => setState(() {
          _isHover = false;
        }),
        child: GestureDetector(
          onTap: () {
            showBlockSelectDialog();
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: DashedBorder(
                color: _isHover ? Colors.transparent : Colors.grey,
              ),
              color: _isHover ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '+ Добавить блок',
                style: TextStyle(
                  color: _isHover ? AppTheme.secondary : Colors.grey,
                  fontWeight: _isHover ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: additionalBlockTypes.map((type) {
        switch (type) {
          case 'footer':
            return _buildFooter();
          default:
            return const SizedBox();
        }
      }).toList(),
    );
  }
}
