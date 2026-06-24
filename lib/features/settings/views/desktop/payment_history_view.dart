import 'package:easy_localization/easy_localization.dart';
import 'package:flashform_app/core/app_theme.dart';
import 'package:flashform_app/data/controller/payment_controller.dart';
import 'package:flashform_app/data/model/payment.dart';
import 'package:flashform_app/data/model/subscription.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/features/settings/views/desktop/settings_view_desktop.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PaymentHistoryView extends StatefulWidget {
  const PaymentHistoryView({super.key});

  @override
  State<PaymentHistoryView> createState() => _PaymentHistoryViewState();
}

class _PaymentHistoryViewState extends State<PaymentHistoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: .all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .center,
              children: [
                Text(
                  'История платежей',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Scaffold.of(context).closeEndDrawer();
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),

            Consumer(
              builder: (context, ref, child) {
                final paymentsFuture = ref.watch(allPaymentsControllerProvider);

                return paymentsFuture.when(
                  data: (payments) {
                    if (payments!.isEmpty) {
                      return Center(
                        child: Text('Нет транзакции'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        return PaymentItem(payment: payments[index]);
                      },
                    );
                  },
                  error: (er, st) {
                    return Center(
                      child: Column(
                        children: [
                          Text('Ошибка при загрузке транзакции'),
                          FFButton(onPressed: () {}, text: 'Повторить'),
                        ],
                      ),
                    );
                  },
                  loading: () => Center(
                    child: FFLoading(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentItem extends StatelessWidget {
  const PaymentItem({super.key, required this.payment});

  final Payment payment;

  Widget planIcon() {
    switch (payment.plan) {
      case 'go':
        return HeroIcon(
          HeroIcons.fire,
          style: HeroIconStyle.solid,
          color: AppTheme.secondary,
        );
      case 'pro':
        return HeroIcon(
          HeroIcons.bolt,
          style: HeroIconStyle.solid,
          color: AppTheme.secondary,
        );

      default:
        return HeroIcon(
          HeroIcons.cubeTransparent,
          style: HeroIconStyle.solid,
          color: AppTheme.secondary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'hh:mm dd.MM.yyyy',
    ).format(payment.paidAt ?? .now());
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(20),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,

            crossAxisAlignment: .center,
            children: [
              Container(
                padding: .all(8),
                margin: .only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: planIcon(),
              ),

              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    'Тариф ${payment.plan}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${payment.amount} KZT'),
                ],
              ),
            ],
          ),
          Text(
            formattedDate,
            style: TextStyle(color: Colors.black.withAlpha(100)),
          ),
        ],
      ),
    );
  }
}
