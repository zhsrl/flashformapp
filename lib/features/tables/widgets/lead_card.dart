import 'package:flashform_app/data/model/form_stats.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

enum LeadStatType { today, total }

class LeadCard extends StatefulWidget {
  const LeadCard({super.key, required this.stats, this.onTap});

  final FormStats stats;
  final VoidCallback? onTap;

  @override
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard> {
  bool _isHover = false;

  Widget _buildStatPreview({
    required LeadStatType type,
    required int value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type == LeadStatType.today ? 'Today' : 'Total',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          type == LeadStatType.today ? '+$value' : '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: type == LeadStatType.today ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHover ? 0.98 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                if (_isHover)
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Таблица для',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.stats.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildStatPreview(
                      type: LeadStatType.today,
                      value: widget.stats.todayLeads,
                    ),
                    const SizedBox(width: 24),
                    _buildStatPreview(
                      type: LeadStatType.total,
                      value: widget.stats.totalLeads,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
