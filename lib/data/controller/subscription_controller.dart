import 'package:flashform_app/data/model/payment.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/subscription.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/repository/subscription_repository.dart';
import 'package:flashform_app/data/service/payment_gateway_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/legacy.dart';

typedef PostPaymentSync = Future<void> Function();

class SubscriptionControllerState {
  const SubscriptionControllerState({
    this.activeSubscription,
    this.selectedPlan,
    this.pendingPayment,
    this.isLoading = false,
    this.isActionInProgress = false,
    this.error,
    this.lastSuccessMessage,
  });

  final Subscription? activeSubscription;
  final SubscriptionPlan? selectedPlan;
  final Payment? pendingPayment;
  final bool isLoading;
  final bool isActionInProgress;
  final String? error;
  final String? lastSuccessMessage;

  bool get hasActiveSubscription => activeSubscription != null;

  SubscriptionControllerState copyWith({
    Subscription? activeSubscription,
    SubscriptionPlan? selectedPlan,
    Payment? pendingPayment,
    bool? isLoading,
    bool? isActionInProgress,
    String? error,
    String? lastSuccessMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
    bool clearPendingPayment = false,
  }) {
    return SubscriptionControllerState(
      activeSubscription: activeSubscription ?? this.activeSubscription,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      pendingPayment: clearPendingPayment
          ? null
          : (pendingPayment ?? this.pendingPayment),
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      error: clearError ? null : (error ?? this.error),
      lastSuccessMessage: clearSuccessMessage
          ? null
          : (lastSuccessMessage ?? this.lastSuccessMessage),
    );
  }
}

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionControllerState>(
      (ref) => SubscriptionController(
        ref.watch(subscriptionRepoProvider),
        ref.watch(paymentGatewayServiceProvider),
        onPostPaymentSync: () async {
          await ref.read(userControllerProvider.notifier).loadProfile();
          await ref.read(planUsageProvider.notifier).refresh();
        },
      ),
    );

class SubscriptionController
    extends StateNotifier<SubscriptionControllerState> {
  SubscriptionController(
    this._repository,
    this._paymentGatewayService, {
    required PostPaymentSync onPostPaymentSync,
  }) : _onPostPaymentSync = onPostPaymentSync,
       super(const SubscriptionControllerState());

  final SubscriptionRepository _repository;
  final PaymentGatewayService _paymentGatewayService;
  final PostPaymentSync _onPostPaymentSync;

  Future<void> _runPostPaymentSync() async {
    await loadActiveSubscription();
    await _onPostPaymentSync();
  }

  Future<void> loadActiveSubscription() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      final subscription = await _repository.getActiveSubscription();
      state = state.copyWith(
        activeSubscription: subscription,
        selectedPlan: subscription?.plan,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(
      selectedPlan: plan,
      clearError: true,
      clearSuccessMessage: true,
    );
  }

  Future<Payment?> startPendingPayment({
    required double amount,
    required PaymentProvider provider,
  }) async {
    state = state.copyWith(
      isActionInProgress: true,
      clearError: true,
      clearSuccessMessage: true,
      clearPendingPayment: true,
    );

    try {
      final payment = await _repository.createPendingPayment(
        subscriptionId: state.activeSubscription?.id,
        amount: amount,
        provider: provider,
      );

      state = state.copyWith(
        pendingPayment: payment,
        isActionInProgress: false,
        lastSuccessMessage: 'subscription.payment_pending'.tr(),
      );

      return payment;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<bool> subscribeToPlan({
    required SubscriptionPlan plan,
    PaymentProvider provider = PaymentProvider.tiptop,
  }) async {
    selectPlan(plan);

    if (plan.isFree) {
      state = state.copyWith(
        lastSuccessMessage: 'subscription.free_plan_no_payment'.tr(
          namedArgs: {'plan': plan.displayName},
        ),
      );
      return true;
    }

    state = state.copyWith(
      isActionInProgress: true,
      clearError: true,
      clearSuccessMessage: true,
      clearPendingPayment: true,
    );

    Payment? payment;

    try {
      payment = await _repository.createPendingPayment(
        subscriptionId: state.activeSubscription?.id,
        amount: plan.amountKzt.toDouble(),
        provider: provider,
      );

      final checkoutResult = await _paymentGatewayService.startCheckout(
        payment: payment,
        plan: plan,
        provider: provider,
      );

      if (checkoutResult.status != CheckoutStatus.success) {
        await _repository.markPaymentFailed(
          paymentId: payment.id,
          providerTxId: checkoutResult.providerTxId,
        );

        state = state.copyWith(
          pendingPayment: payment,
          isActionInProgress: false,
          error:
              checkoutResult.message ??
              'subscription.payment_not_confirmed'.tr(),
        );
        return false;
      }

      await _repository.markPaymentCompleted(
        paymentId: payment.id,
        providerTxId: checkoutResult.providerTxId,
      );

      final subscription = await _repository.createSubscription(
        plan: plan,
        expiresAt: DateTime.now().add(
          Duration(days: plan.billingPeriodDays),
        ),
      );

      await _runPostPaymentSync();

      state = state.copyWith(
        pendingPayment: payment,
        activeSubscription: subscription,
        isActionInProgress: false,
        lastSuccessMessage:
            checkoutResult.message ??
            'subscription.activated_plan'.tr(
              namedArgs: {'plan': plan.displayName},
            ),
      );
      return true;
    } catch (e) {
      if (payment != null) {
        await _repository.markPaymentFailed(paymentId: payment.id);
      }

      state = state.copyWith(
        pendingPayment: payment,
        isActionInProgress: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<Subscription?> activateSelectedPlan({
    required DateTime expiresAt,
    bool autoRenew = true,
  }) async {
    final selectedPlan = state.selectedPlan;
    if (selectedPlan == null) {
      state = state.copyWith(error: 'subscription.plan_not_selected'.tr());
      return null;
    }

    state = state.copyWith(
      isActionInProgress: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      final subscription = await _repository.createSubscription(
        plan: selectedPlan,
        expiresAt: expiresAt,
        autoRenew: autoRenew,
      );

      await _runPostPaymentSync();

      state = state.copyWith(
        activeSubscription: subscription,
        isActionInProgress: false,
        lastSuccessMessage: 'subscription.activated'.tr(),
      );

      return subscription;
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<void> cancelAutoRenew() async {
    state = state.copyWith(
      isActionInProgress: true,
      clearError: true,
      clearSuccessMessage: true,
    );

    try {
      await _repository.cancelAutoRenew();
      await loadActiveSubscription();
      state = state.copyWith(
        isActionInProgress: false,
        lastSuccessMessage: 'subscription.auto_renew_disabled'.tr(),
      );
    } catch (e) {
      state = state.copyWith(
        isActionInProgress: false,
        error: e.toString(),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearSuccessMessage: true,
    );
  }
}
