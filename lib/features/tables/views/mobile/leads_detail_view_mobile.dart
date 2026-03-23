import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/utils.dart';
import 'package:flashform_app/data/controller/export_controller.dart';
import 'package:flashform_app/data/controller/leads_controller.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/data/repository/leads_repository.dart';
import 'package:flashform_app/features/tables/views/desktop/leads_detail_view_desktop.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LeadsDetailViewMobile extends ConsumerStatefulWidget {
  const LeadsDetailViewMobile({
    super.key,
    required this.formId,
  });

  final String formId;
  @override
  ConsumerState<LeadsDetailViewMobile> createState() =>
      _LeadsDetailViewMobileState();
}

class _LeadsDetailViewMobileState extends ConsumerState<LeadsDetailViewMobile> {
  DateFilterType _dateFilter = DateFilterType.all;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final leadsState = ref.watch(leadsControllerProvider(widget.formId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/tables');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('Заявки (${leadsState.totalCount})'),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          if (leadsState.leads.isNotEmpty)
            Consumer(
              builder: (context, value, child) {
                final usageAsync = ref.watch(planUsageProvider);
                return usageAsync.when(
                  data: (usage) {
                    if (usage.canExport) {
                      return IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          await ref
                              .read(leadsRepoProvider)
                              .exportDataCSV(
                                widget.formId,
                                dateFrom: leadsState.dateFrom,
                                dateTo: leadsState.dateTo,
                                city: leadsState.selectedCity,
                                country: leadsState.selectedCountry,
                              );
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                  error: (er, st) {
                    return SizedBox();
                  },
                  loading: () => SizedBox(),
                );
              },
            ),
        ],
      ),
      body: leadsState.isLoading && leadsState.leads.isEmpty
          ? Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppTheme.secondary,
                size: 30,
              ),
            )
          : leadsState.leads.isEmpty
          ? const Center(
              child: Text('Нет заявок'),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          label: _getDateFilterLabel(),
                          icon: Icons.calendar_today,
                          onTap: () => _showDateFilterMenu(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterChip(
                          label: _getSelectedLocationLabel(leadsState),
                          icon: Icons.location_on,
                          onTap: () => _showLocationFilterMenu(
                            context,
                            leadsState,
                          ),
                        ),
                      ),
                      if (_dateFilter != DateFilterType.all ||
                          leadsState.selectedCity != null ||
                          leadsState.selectedCountry != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Сбросить фильтры',
                          onPressed: () {
                            setState(() {
                              _dateFilter = DateFilterType.all;
                              _selectedDate = null;
                            });
                            ref
                                .read(
                                  leadsControllerProvider(
                                    widget.formId,
                                  ).notifier,
                                )
                                .clearFilters();
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: leadsState.leads.length,
                    itemBuilder: (context, index) {
                      final lead = leadsState.leads[index];
                      return LeadCard(
                        lead: lead,
                        onTap: () {
                          _showLeadDetails(context, lead);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Страница ${leadsState.currentPage + 1} из ${leadsState.totalPages > 0 ? leadsState.totalPages : 1}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondary,
                            ),
                            onPressed: leadsState.currentPage > 0
                                ? () {
                                    ref
                                        .read(
                                          leadsControllerProvider(
                                            widget.formId,
                                          ).notifier,
                                        )
                                        .previousPage();
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Назад'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondary,
                            ),
                            onPressed:
                                leadsState.currentPage <
                                    leadsState.totalPages - 1
                                ? () {
                                    ref
                                        .read(
                                          leadsControllerProvider(
                                            widget.formId,
                                          ).notifier,
                                        )
                                        .nextPage();
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Вперед'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showDateFilterMenu(
    BuildContext context,
  ) {
    showMenu<DateFilterType>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        100,
        200,
        0,
      ),
      items: [
        const PopupMenuItem(
          value: DateFilterType.all,
          child: Text('Все даты'),
        ),
        const PopupMenuItem(
          value: DateFilterType.today,
          child: Text('Только сегодня'),
        ),
        const PopupMenuItem(
          value: DateFilterType.custom,
          child: Text('Выбрать дату...'),
        ),
      ],
    ).then((value) {
      if (!mounted) return;

      if (value != null) {
        if (value == DateFilterType.custom) {
          _selectCustomDate(context);
        } else if (value == DateFilterType.today) {
          setState(() {
            _dateFilter = value;
            _selectedDate = null;
          });
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart.add(const Duration(days: 1));
          ref
              .read(leadsControllerProvider(widget.formId).notifier)
              .setDateFilter(dateFrom: todayStart, dateTo: todayEnd);
        } else {
          setState(() {
            _dateFilter = value;
            _selectedDate = null;
          });
          ref
              .read(leadsControllerProvider(widget.formId).notifier)
              .setDateFilter(clearDates: true);
        }
      }
    });
  }

  void _showLocationFilterMenu(
    BuildContext context,
    LeadsPaginationState state,
  ) {
    showMenu<Map<String, String>?>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 300,
        100,
        100,
        0,
      ),
      items: [
        const PopupMenuItem(
          value: null,
          child: Text('Все локации'),
        ),
        ...state.availableLocations.map((location) {
          final city = location['city'] ?? '';
          final country = location['country'] ?? '';
          final label = [city, country].where((s) => s.isNotEmpty).join(', ');

          return PopupMenuItem(
            value: location,
            child: Text(label.isNotEmpty ? label : '-'),
          );
        }),
      ],
    ).then((value) {
      if (!mounted) return;

      if (value == null) {
        ref
            .read(leadsControllerProvider(widget.formId).notifier)
            .setLocationFilter(clear: true);
      } else {
        ref
            .read(leadsControllerProvider(widget.formId).notifier)
            .setLocationFilter(
              city: value['city'],
              country: value['country'],
            );
      }
    });
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() {
        _dateFilter = DateFilterType.custom;
        _selectedDate = picked;
      });

      final dateStart = DateTime(picked.year, picked.month, picked.day);
      final dateEnd = dateStart.add(const Duration(days: 1));

      ref
          .read(leadsControllerProvider(widget.formId).notifier)
          .setDateFilter(dateFrom: dateStart, dateTo: dateEnd);
    }
  }

  String _getLocationString(Map<String, dynamic>? geoData) {
    if (geoData == null || geoData.isEmpty) {
      return '-';
    }

    final city = geoData['city'] ?? '';
    final country = geoData['country'] ?? '';
    final latitude = geoData['latitude'];
    final longitude = geoData['longitude'];

    final parts = <String>[];
    if (city.toString().isNotEmpty) parts.add(city.toString());
    if (country.toString().isNotEmpty) parts.add(country.toString());
    if (latitude != null && longitude != null) {
      parts.add('($latitude, $longitude)');
    }

    return parts.isNotEmpty ? parts.join(', ') : '-';
  }

  String _getSelectedLocationLabel(LeadsPaginationState state) {
    if (state.selectedCity != null || state.selectedCountry != null) {
      final parts = <String>[];
      if (state.selectedCity?.isNotEmpty ?? false) {
        parts.add(state.selectedCity!);
      }
      if (state.selectedCountry?.isNotEmpty ?? false) {
        parts.add(state.selectedCountry!);
      }
      return parts.join(', ');
    }
    return 'Все локации';
  }

  String _getDateFilterLabel() {
    switch (_dateFilter) {
      case DateFilterType.all:
        return 'Все даты';
      case DateFilterType.today:
        return 'Только сегодня';
      case DateFilterType.custom:
        if (_selectedDate != null) {
          return '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}';
        }
        return 'Выбрать дату';
    }
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: AppTheme.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showLeadDetails(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => LeadDetailsDialog(lead: lead),
    );
  }
}

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
  });

  final Lead lead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mainAnswer = _getMainAnswer();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mainAnswer.isNotEmpty
                            ? mainAnswer
                            : 'Заявка #${lead.id?.substring(0, 8) ?? 'N/A'}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lead.createdAt != null
                            ? '${lead.createdAt?.toLocal()}'.split('.')[0]
                            : 'N/A',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lead.answers != null && lead.answers!.isNotEmpty) ...[
              _buildInfoSection(
                context,
                'Ответы',
                lead.answers!,
              ),
              const SizedBox(height: 12),
            ],
            if (lead.geoData != null && lead.geoData!.isNotEmpty) ...[
              _buildLocationSection(context),
              const SizedBox(height: 12),
            ],
            if (lead.utmData != null && lead.utmData!.isNotEmpty)
              _buildUtmSection(context),
          ],
        ),
      ),
    );
  }

  String _getMainAnswer() {
    if (lead.answers == null || lead.answers!.isEmpty) {
      return '';
    }
    final firstKey = lead.answers!.keys.first;
    return lead.answers![firstKey]?.toString() ?? '';
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...data.entries.take(3).map((entry) {
          final isPhoneField =
              entry.key.toLowerCase().contains('телефон') ||
              entry.key.toLowerCase().contains('phone');
          final phoneValue = entry.value?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              '${entry.key}:',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              phoneValue,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isPhoneField && phoneValue.isNotEmpty)
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        elevation: 0,
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        await openMessenger('https://wa.me/$phoneValue');
                      },
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 14,
                      ),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        if (data.length > 3)
          Text(
            '+${data.length - 3} еще',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.secondary,
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final geoData = lead.geoData;
    final city = geoData?['city'] ?? '';
    final country = geoData?['country'] ?? '';
    final location = [
      city,
      country,
    ].where((s) => s.toString().isNotEmpty).join(', ');

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: AppTheme.secondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            location.isNotEmpty ? location : '-',
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUtmSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UTM данные',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...lead.utmData!.entries.take(2).map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '${entry.key}:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${entry.value}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
