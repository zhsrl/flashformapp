import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/leads_controller.dart';
import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/features/home/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadsDetailViewDesktop extends ConsumerWidget {
  const LeadsDetailViewDesktop({
    super.key,
    required this.formId,
  });

  final String formId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsState = ref.watch(leadsControllerProvider(formId));

    return Scaffold(
      appBar: HomeAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заявки (${leadsState.totalCount})',
                  style: Theme.of(context).textTheme.headlineSmall,
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
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Builder(
                              builder: (context) {
                                final answerKeys = _getAnswerKeys(
                                  leadsState.leads,
                                );
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: context.screenWidth,
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20,
                                    columns: _buildColumns(answerKeys),
                                    rows: leadsState.leads
                                        .map(
                                          (lead) => DataRow(
                                            onSelectChanged: (_) {
                                              _showLeadDetails(context, lead);
                                            },
                                            cells: _buildCells(
                                              context,
                                              lead,
                                              answerKeys,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (leadsState.hasMore)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: ElevatedButton(
                                onPressed: leadsState.isLoading
                                    ? null
                                    : () {
                                        ref
                                            .read(
                                              leadsControllerProvider(
                                                formId,
                                              ).notifier,
                                            )
                                            .loadMore();
                                      },
                                child: leadsState.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Загрузить еще'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
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
      const DataColumn(label: Text('ID заявки')),
      const DataColumn(label: Text('Дата создания')),
    ];

    // Add answer columns sorted
    for (final key in answerKeys.toList()..sort()) {
      columns.add(
        DataColumn(label: Text(key, overflow: TextOverflow.ellipsis)),
      );
    }

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
          lead.id?.substring(0, 8) ?? 'N/A',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      DataCell(
        Text(
          lead.createdAt != null
              ? '${lead.createdAt?.toLocal()}'.split('.')[0]
              : 'N/A',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ];

    // Add answer cells in the same order as columns
    for (final key in answerKeys.toList()..sort()) {
      final value = lead.answers?[key]?.toString() ?? '-';
      cells.add(
        DataCell(
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }

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
    return Dialog(
      child: SizedBox(
        width: 600,
        height: 600,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Заявка #${lead.id?.substring(0, 8)}'),
            automaticallyImplyLeading: true,
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
                      'ID заявки:',
                      lead.id ?? 'N/A',
                    ),
                    _buildInfoRow(
                      context,
                      'ID формы:',
                      lead.formId ?? 'N/A',
                    ),
                    _buildInfoRow(
                      context,
                      'Дата создания:',
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
    );
  }
}
