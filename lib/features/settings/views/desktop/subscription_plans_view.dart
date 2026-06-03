import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/data/controller/plan_usage_controller.dart';
import 'package:flashform_app/data/controller/subscription_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/payment.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/features/settings/widgets/payment_dialog.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';

class SubscriptionPlansView extends ConsumerStatefulWidget {
  const SubscriptionPlansView({super.key});

  @override
  ConsumerState<SubscriptionPlansView> createState() =>
      _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends ConsumerState<SubscriptionPlansView> {
  final List<SubscriptionPlan> plans = [
    SubscriptionPlan.go,
    SubscriptionPlan.pro,
  ];
  late final ProviderSubscription<SubscriptionControllerState> _subListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(subscriptionControllerProvider.notifier)
          .loadActiveSubscription();
    });

    _subListener = ref.listenManual<SubscriptionControllerState>(
      subscriptionControllerProvider,
      (previous, next) {
        if (!mounted) return;

        if (next.error != null && next.error != previous?.error) {
          showSnackbar(
            context,
            type: SnackbarType.error,
            message: next.error!,
          );
        }

        if (next.lastSuccessMessage != null &&
            next.lastSuccessMessage != previous?.lastSuccessMessage) {
          showSnackbar(
            context,
            type: SnackbarType.success,
            message: next.lastSuccessMessage!,
          );
        }
      },
    );
  }

  Future<void> _handlePlanAction({
    required SubscriptionPlan plan,
    required SubscriptionPlan? currentPlan,
  }) async {
    if (currentPlan == plan) return;

    final subscriptionNotifier = ref.read(
      subscriptionControllerProvider.notifier,
    );

    final isSuccess = await subscriptionNotifier.subscribeToPlan(
      plan: plan,
      provider: PaymentProvider.tiptop,
    );

    if (!mounted || !isSuccess) return;
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final userState = ref.watch(userControllerProvider);
    final user = userState.user;
    final isTrialAvailable = user?.isTrialAvailable ?? false;

    final currentPlan =
        userState.user?.plan ?? subscriptionState.activeSubscription?.plan;
    final selectedPlan = subscriptionState.selectedPlan;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Тарифные планы',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Выберите оптимальный план для вашего бизнеса',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 1050;

                      if (isNarrow) {
                        return Column(
                          children: [
                            for (int i = 0; i < plans.length; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: i == plans.length - 1 ? 0 : 16,
                                ),
                                child: PlanCard(
                                  plan: plans[i],
                                  isCurrentPlan: plans[i] == currentPlan,
                                  isSelectedPlan: plans[i] == selectedPlan,
                                  isBusy: subscriptionState.isActionInProgress,
                                  isTrialAvailable: isTrialAvailable,
                                  onAction: () => _handlePlanAction(
                                    plan: plans[i],
                                    currentPlan: currentPlan,
                                  ),
                                  onActivateTrial: () async {
                                    final userNotifier = ref.read(
                                      userControllerProvider.notifier,
                                    );

                                    final updatedUser = await userNotifier
                                        .activateTrial();

                                    if (!mounted || updatedUser == null) {
                                      return;
                                    }

                                    await ref
                                        .read(planUsageProvider.notifier)
                                        .refresh();

                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < plans.length; i++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: i > 0 ? 18 : 0),
                                child: PlanCard(
                                  plan: plans[i],
                                  isCurrentPlan: plans[i] == currentPlan,
                                  isSelectedPlan: plans[i] == selectedPlan,
                                  isBusy: subscriptionState.isActionInProgress,
                                  isTrialAvailable: isTrialAvailable,
                                  onAction: () => _handlePlanAction(
                                    plan: plans[i],
                                    currentPlan: currentPlan,
                                  ),
                                  onActivateTrial: () async {
                                    final userNotifier = ref.read(
                                      userControllerProvider.notifier,
                                    );

                                    final updatedUser = await userNotifier
                                        .activateTrial();

                                    if (!mounted || updatedUser == null) {
                                      return;
                                    }

                                    await ref
                                        .read(planUsageProvider.notifier)
                                        .refresh();

                                    if (!mounted) return;
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: HeroIcon(
                HeroIcons.xMark,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subListener.close();
    super.dispose();
  }
}

class PlanCard extends StatefulWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isCurrentPlan,
    required this.isSelectedPlan,
    required this.isBusy,
    required this.isTrialAvailable,
    required this.onAction,
    required this.onActivateTrial,
  });

  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isSelectedPlan;
  final bool isBusy;
  final bool isTrialAvailable;
  final VoidCallback onAction;
  final VoidCallback onActivateTrial;

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  bool _isHovered = false;

  bool get _goPlan => widget.plan == SubscriptionPlan.go;

  HeroIcons get _planIcon => switch (widget.plan) {
    SubscriptionPlan.go => HeroIcons.fire,
    SubscriptionPlan.pro => HeroIcons.bolt,
    _ => HeroIcons.star,
  };

  String get _planSubtitle => switch (widget.plan) {
    SubscriptionPlan.go => 'Для масштабирования и роста',
    SubscriptionPlan.pro => 'Для команд и полного контроля',
    _ => 'Для старта и первых лидов',
  };

  String get _priceMain => switch (widget.plan) {
    SubscriptionPlan.go => widget.plan.amountKzt.toString(),
    SubscriptionPlan.pro => widget.plan.amountKzt.toString(),
    _ => '',
  };

  String get _priceSuffix => 'KZT/месяц';

  List<String> get _displayFeatures => [
    if (widget.plan == SubscriptionPlan.pro) 'Все возможности Go',
    ...widget.plan.featureList,
  ];

  Map<String, dynamic> get _displayIntegrations => {
    'Meta Pixel': 'assets/images/meta.svg',

    if (widget.plan == .pro || widget.plan == .go)
      'Яндекс Метрика': 'assets/images/metrika.svg',
    if (widget.plan == .pro) 'Google Sheets': 'assets/images/gsheets.svg',

    if (widget.plan == .pro)
      'Telegram бот для уведомления': 'assets/images/telegram.svg',
  };

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isCurrentPlan || widget.isSelectedPlan
        ? const Color(0xFFCCFF4D)
        : (_goPlan ? const Color(0xFF04191B) : const Color(0xFFE4E4E4));

    final topBackground = _goPlan ? const Color(0xFF04191B) : Colors.white;
    final titleColor = _goPlan ? Colors.white : const Color(0xFF121417);
    final subtitleColor = _goPlan
        ? Colors.white.withAlpha(190)
        : const Color(0xFF717680);
    final priceColor = _goPlan
        ? const Color(0xFFCCFF4D)
        : const Color(0xFF111827);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      transform: Matrix4.identity()
        ..translate(0.0, (_isHovered && !_goPlan) ? -5.0 : 0.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          decoration: BoxDecoration(
            color: _goPlan ? const Color(0xFF04191B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(width: 2, color: borderColor),
            boxShadow: [
              BoxShadow(
                color: (_isHovered || _goPlan)
                    ? const Color(0x2A111827)
                    : const Color(0x10111827),
                blurRadius: _goPlan ? 28 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 14),
                  decoration: BoxDecoration(
                    color: topBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          HeroIcon(
                            _planIcon,
                            color: _goPlan
                                ? const Color(0xFFCCFF4D)
                                : AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.plan.displayName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _planSubtitle,
                        style: TextStyle(fontSize: 14, color: subtitleColor),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _priceMain,
                            style: TextStyle(
                              fontSize: 44,
                              height: 0.95,
                              fontWeight: FontWeight.w800,
                              color: priceColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _priceSuffix,
                              style: TextStyle(
                                fontSize: 16,
                                color: _goPlan
                                    ? Colors.white.withAlpha(190)
                                    : const Color(0xFF525866),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: context.screenWidth,
                        child: FFButton(
                          isLoading: widget.isBusy && widget.isSelectedPlan,
                          onPressed: widget.isCurrentPlan
                              ? null
                              : () {
                                  if (_goPlan && widget.isTrialAvailable) {
                                    widget.onActivateTrial();
                                    return;
                                  }

                                  showDialog(
                                    context: context,
                                    builder: (context) => PaymentDialog(
                                      planId: widget.plan.name,
                                      amount: widget.plan.amountKzt,
                                      planName: widget.plan.displayName,
                                    ),
                                  );
                                },
                          secondTheme: _goPlan,
                          text: widget.isCurrentPlan
                              ? 'Текущий тариф'
                              : (_goPlan && widget.isTrialAvailable)
                              ? 'Активировать бесплатный период'
                              : 'Оформить план',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: widget.plan == .go
                        ? Colors.white.withAlpha(30)
                        : Color(0xFFF1F2F7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: _displayFeatures
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            margin: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _goPlan
                                        ? AppTheme.primary
                                        : AppTheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 13,
                                      color: _goPlan
                                          ? AppTheme.secondary
                                          : AppTheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      color: widget.plan == .go
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (_displayIntegrations.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    decoration: BoxDecoration(
                      color: widget.plan == .go
                          ? Colors.white.withAlpha(30)
                          : Color(0xFFF1F2F7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _displayIntegrations.length,
                      itemBuilder: (context, index) {
                        final integration = _displayIntegrations.entries
                            .toList()[index];
                        return Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          margin: EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                integration.value,
                                width: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  integration.key,
                                  style: TextStyle(
                                    color: widget.plan == .go
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Text(
                  //   'Интеграции: ${widget.plan.availableIntegrations.join(' • ')}',
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: _goPlan
                  //         ? Colors.white.withAlpha(180)
                  //         : Colors.grey[700],
                  //   ),
                  // ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
