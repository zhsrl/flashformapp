import 'package:flashform_app/data/model/lead.dart';
import 'package:flashform_app/data/repository/leads_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class LeadsPaginationState {
  LeadsPaginationState({
    required this.leads,
    required this.totalCount,
    required this.currentPage,
    required this.isLoading,
    this.dateFrom,
    this.dateTo,
    this.selectedCity,
    this.selectedCountry,
    this.availableLocations = const [],
  });

  final List<Lead> leads;
  final int totalCount;
  final int currentPage;
  final bool isLoading;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? selectedCity;
  final String? selectedCountry;
  final List<Map<String, String>> availableLocations;

  int get totalPages =>
      totalCount > 0 ? ((totalCount - 1) ~/ LeadsRepository.pageSize) + 1 : 0;
  int get offset => currentPage * LeadsRepository.pageSize;

  LeadsPaginationState copyWith({
    List<Lead>? leads,
    int? totalCount,
    int? currentPage,
    bool? isLoading,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? selectedCity,
    String? selectedCountry,
    List<Map<String, String>>? availableLocations,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearCity = false,
    bool clearCountry = false,
  }) {
    return LeadsPaginationState(
      leads: leads ?? this.leads,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      selectedCity: clearCity ? null : (selectedCity ?? this.selectedCity),
      selectedCountry: clearCountry
          ? null
          : (selectedCountry ?? this.selectedCountry),
      availableLocations: availableLocations ?? this.availableLocations,
    );
  }
}

final leadsControllerProvider = StateNotifierProvider.family
    .autoDispose<LeadsController, LeadsPaginationState, String>(
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
          currentPage: 0,
          isLoading: true,
        ),
      ) {
    _init();
  }

  final LeadsRepository _repository;
  final String _formId;

  Future<void> _init() async {
    await _loadLocations();
    await _loadLeads();
  }

  Future<void> _loadLocations() async {
    try {
      final locations = await _repository.getUniqueLocations(_formId);
      state = state.copyWith(availableLocations: locations);
    } catch (e) {
      // Failed to load locations, continue anyway
    }
  }

  Future<void> _loadLeads() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load count with filters
      final totalCount = await _repository.getLeadsCount(
        _formId,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        city: state.selectedCity,
        country: state.selectedCountry,
      );

      // Load current page with filters
      final leads = await _repository.getLeadsByFormId(
        _formId,
        offset: state.offset,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        city: state.selectedCity,
        country: state.selectedCountry,
      );

      state = state.copyWith(
        leads: leads,
        totalCount: totalCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // Navigate to specific page
  Future<void> goToPage(int page) async {
    if (page < 0 || page >= state.totalPages || page == state.currentPage) {
      return;
    }

    state = state.copyWith(currentPage: page);
    await _loadLeads();
  }

  // Navigate to next page
  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages - 1) {
      await goToPage(state.currentPage + 1);
    }
  }

  // Navigate to previous page
  Future<void> previousPage() async {
    if (state.currentPage > 0) {
      await goToPage(state.currentPage - 1);
    }
  }

  // Set date filter
  Future<void> setDateFilter({
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDates = false,
  }) async {
    state = state.copyWith(
      dateFrom: dateFrom,
      dateTo: dateTo,
      currentPage: 0,
      clearDateFrom: clearDates,
      clearDateTo: clearDates,
    );
    await _loadLeads();
  }

  // Set location filter
  Future<void> setLocationFilter({
    String? city,
    String? country,
    bool clear = false,
  }) async {
    state = state.copyWith(
      selectedCity: city,
      selectedCountry: country,
      currentPage: 0,
      clearCity: clear,
      clearCountry: clear,
    );
    await _loadLeads();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    state = state.copyWith(
      currentPage: 0,
      clearDateFrom: true,
      clearDateTo: true,
      clearCity: true,
      clearCountry: true,
    );
    await _loadLeads();
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadLocations();
    await _loadLeads();
  }
}
