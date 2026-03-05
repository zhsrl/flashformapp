import 'dart:async';

import 'package:flashform_app/data/controller/forms_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/repository/leads_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanUsage {
  const PlanUsage({
    required this.plan,
    required this.formsUsed,
    required this.leadsUsed,
  });

  final SubscriptionPlan plan;
  final int formsUsed;
  final int leadsUsed;

  // Лимиты из плана
  int get formsLimit => plan.formsLimit;
  int? get leadsLimit => plan.leadsPerMonthLimit;

  // Превышен ли лимит форм
  bool get isFormsLimitReached => formsUsed >= formsLimit;

  // Превышен ли лимит лидов (null = безлимит у Pro)
  bool get isLeadsLimitReached =>
      leadsLimit != null && leadsUsed >= leadsLimit!;

  // Доступен ли экспорт
  bool get canExport => plan.hasExport;

  // Можно ли убрать брендинг
  bool get canRemoveBranding => plan.canRemoveBranding;

  // Прогресс форм (0.0 — 1.0)
  double get formsProgress => (formsUsed / formsLimit).clamp(0.0, 1.0);

  // Прогресс лидов (0.0 — 1.0), null если безлимит
  double? get leadsProgress =>
      leadsLimit != null ? (leadsUsed / leadsLimit!).clamp(0.0, 1.0) : null;
}

final planUsageProvider = AsyncNotifierProvider<PlanUsageController, PlanUsage>(
  PlanUsageController.new,
);

class PlanUsageController extends AsyncNotifier<PlanUsage> {
  @override
  FutureOr<PlanUsage> build() async {
    return _load();
  }

  Future<PlanUsage> _load() async {
    final user = ref.watch(userControllerProvider).user;
    final formsAsync = ref.watch(formControllerProvider);
    final leadsRepo = ref.read(leadsRepoProvider);

    final plan = user?.plan ?? SubscriptionPlan.spark;
    final formsUsed = formsAsync.value?.length ?? 0;
    final leadsUsed = await leadsRepo.getMonthlyLeadsCount();

    return PlanUsage(
      plan: plan,
      formsUsed: formsUsed,
      leadsUsed: leadsUsed,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
