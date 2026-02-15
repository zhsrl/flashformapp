import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/data/repository/leads_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class LeadsPaginationState {
  LeadsPaginationState({
    required this.leads,
    required this.totalCount,
    required this.offset,
    required this.isLoading,
  });

  final List<Lead> leads;
  final int totalCount;
  final int offset;
  final bool isLoading;

  bool get hasMore => offset + LeadsRepository.pageSize < totalCount;

  LeadsPaginationState copyWith({
    List<Lead>? leads,
    int? totalCount,
    int? offset,
    bool? isLoading,
  }) {
    return LeadsPaginationState(
      leads: leads ?? this.leads,
      totalCount: totalCount ?? this.totalCount,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final leadsControllerProvider =
    StateNotifierProvider.family<LeadsController, LeadsPaginationState, String>(
  (ref, formId) => LeadsController(
    ref.watch(leadsRepoProvider),
    formId,
  ),
);

class LeadsController extends StateNotifier<LeadsPaginationState> {
  LeadsController(this._repository, this._formId)
      : super(
          LeadsPaginationState(
            leads: [],
            totalCount: 0,
            offset: 0,
            isLoading: true,
          ),
        ) {
    _loadInitialLeads();
  }

  final LeadsRepository _repository;
  final String _formId;

  Future<void> _loadInitialLeads() async {
    try {
      final leads = await _repository.getLeadsByFormId(_formId, offset: 0);
      final totalCount = await _repository.getLeadsCount(_formId);

      state = state.copyWith(
        leads: leads,
        totalCount: totalCount,
        offset: 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final newLeads = await _repository.getLeadsByFormId(
        _formId,
        offset: state.offset + LeadsRepository.pageSize,
      );

      state = state.copyWith(
        leads: [...state.leads, ...newLeads],
        offset: state.offset + LeadsRepository.pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
