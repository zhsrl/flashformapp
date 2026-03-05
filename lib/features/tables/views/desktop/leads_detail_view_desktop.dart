import 'package:data_table_2/data_table_2.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/core/utils/utils.dart';
import 'package:flashform_app/data/controller/export_controller.dart';
import 'package:flashform_app/data/controller/leads_controller.dart';
import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/data/repository/leads_repository.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadsDetailViewDesktop extends ConsumerStatefulWidget {
  const LeadsDetailViewDesktop({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  ConsumerState<LeadsDetailViewDesktop> createState() =>
      _LeadsDetailViewDesktopState();
}

enum DateFilterType { all, today, custom }

class _LeadsDetailViewDesktopState
    extends ConsumerState<LeadsDetailViewDesktop> {
  // Filter states
  DateFilterType _dateFilter = DateFilterType.all;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final leadsState = ref.watch(leadsControllerProvider(widget.formId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: HomeAppBar(
        isBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Заявки (${leadsState.totalCount})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      // Date filter
                      _buildFilterChip(
                        label: _getDateFilterLabel(),
                        icon: Icons.calendar_today,
                        onTap: () => _showDateFilterMenu(context),
                      ),
                      // Location filter
                      _buildFilterChip(
                        label: _getSelectedLocationLabel(leadsState),
                        icon: Icons.location_on,
                        onTap: () => _showLocationFilterMenu(
                          context,
                          leadsState,
                        ),
                      ),
                      FFButton(
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
                        isLoading: ref.read(exportProvider).isLoading,
                        text: 'Экспорт',
                        marginBottom: 0,
                      ),
                      // Clear filters button
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
                ],
              ),
            ),

            Expanded(
              child: leadsState.isLoading && leadsState.leads.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : leadsState.leads.isEmpty
                  ? const Center(
                      child: Text('Нет заявок'),
                    )
                  : Builder(
                      builder: (context) {
                        final answerKeys = _getAnswerKeys(leadsState.leads);

                        return Column(
                          children: [
                            Expanded(
                              child: DataTable2(
                                columnSpacing: 10,
                                horizontalMargin: 20,
                                fixedTopRows: 1,
                                dataRowHeight: 150,

                                showCheckboxColumn: false,
                                clipBehavior: Clip.antiAliasWithSaveLayer,

                                headingRowColor: WidgetStatePropertyAll(
                                  AppTheme.tertiary,
                                ),
                                isHorizontalScrollBarVisible: true,
                                isVerticalScrollBarVisible: true,
                                columns: _buildColumns(answerKeys),
                                rows: leadsState.leads
                                    .map(
                                      (lead) => DataRow(
                                        onSelectChanged: (_) =>
                                            _showLeadDetails(context, lead),
                                        cells: _buildCells(
                                          context,
                                          lead,
                                          answerKeys,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Страница ${leadsState.currentPage + 1} из ${leadsState.totalPages > 0 ? leadsState.totalPages : 1}',
                                  ),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.secondary,
                                          textStyle: TextStyle(
                                            color: AppTheme.primary,
                                          ),
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
                                          textStyle: TextStyle(
                                            color: AppTheme.primary,
                                          ),
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
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Set<String> _getAnswerKeys(List<Lead> leads) {
    final answerKeys = <String>{};
    for (final lead in leads) {
      if (lead.answers != null) {
        answerKeys.addAll(lead.answers!.keys);
      }
    }
    return answerKeys;
  }

  List<DataColumn> _buildColumns(Set<String> answerKeys) {
    final columns = <DataColumn>[
      // const DataColumn(label: Text('ID заявки')),
      const DataColumn2(
        label: Text('Дата создания'),
      ),
    ];

    columns.add(const DataColumn(label: Text('Данные')));
    columns.add(const DataColumn(label: Text('UTM данные')));
    // Add location column
    columns.add(const DataColumn(label: Text('Локация')));

    return columns;
  }

  List<DataCell> _buildCells(
    BuildContext context,
    Lead lead,
    Set<String> answerKeys,
  ) {
    final cells = <DataCell>[
      DataCell(
        Text(
          lead.createdAt != null
              ? '${lead.createdAt?.toLocal()}'.split('.')[0]
              : 'N/A',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ];

    cells.add(
      DataCell(
        Column(
          mainAxisSize: MainAxisSize.min,
          children:
              lead.answers?.entries.map<Widget>((element) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${element.key}: ',
                        style: TextStyle(color: Colors.black.withAlpha(100)),
                      ),
                      Expanded(
                        child: Text(
                          '${element.value}',

                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [],
        ),
      ),
    );

    cells.add(
      DataCell(
        Column(
          mainAxisSize: MainAxisSize.min,
          children:
              lead.utmData?.entries.map<Widget>((element) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Row(
                    children: [
                      Text(
                        '${element.key}: ',
                        style: TextStyle(color: Colors.black.withAlpha(100)),
                      ),
                      Expanded(
                        child: Text(
                          '${element.value}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList() ??
              [],
        ),
      ),
    );

    // Add location cell
    cells.add(
      DataCell(
        Text(
          _getLocationString(lead.geoData),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );

    return cells;
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

  // Helper methods
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
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.secondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20, color: AppTheme.secondary),
          ],
        ),
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

  void _showLeadDetails(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => LeadDetailsDialog(lead: lead),
    );
  }
}

class LeadDetailsDialog extends StatelessWidget {
  const LeadDetailsDialog({
    super.key,
    required this.lead,
  });

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.background,
      content: SizedBox(
        width: context.isMobile ? context.screenWidth : 600,
        height: 600,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text('Заявка #${lead.id?.substring(0, 8)}'),
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  'Основная информация',
                  [
                    _buildInfoRow(
                      context,
                      'ID заявки',
                      lead.id ?? 'N/A',
                    ),
                    _buildInfoRow(
                      context,
                      'ID формы',
                      lead.formId ?? 'N/A',
                    ),
                    _buildInfoRow(
                      context,
                      'Дата создания',
                      lead.createdAt != null
                          ? '${lead.createdAt?.toLocal()}'.split('.')[0]
                          : 'N/A',
                    ),
                  ],
                ),
                if (lead.answers != null && lead.answers!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    'Ответы (${lead.answers!.length})',
                    lead.answers!.entries
                        .map(
                          (entry) => _buildInfoRow(
                            context,
                            entry.key,
                            '${entry.value}',
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (lead.utmData != null && lead.utmData!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    'UTM данные',
                    lead.utmData!.entries
                        .map(
                          (entry) => _buildInfoRow(
                            context,
                            entry.key,
                            '${entry.value}',
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (lead.geoData != null && lead.geoData!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    'Геоданные',
                    lead.geoData!.entries
                        .map(
                          (entry) => _buildInfoRow(
                            context,
                            entry.key,
                            '${entry.value}',
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '$label:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (!context.isMobile)
                if (label == 'Телефон')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      await openMessenger('https://wa.me/$value');
                    },
                    label: Text(
                      'Написать на WhatsApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                    icon: Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
