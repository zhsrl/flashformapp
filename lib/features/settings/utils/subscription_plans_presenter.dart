import 'package:flashform_app/core/utils/responsive_helper.dart';
import 'package:flashform_app/features/settings/views/desktop/subscription_plans_view.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showSubscriptionPlansPresenter(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: const SizedBox(
        width: 1200,
        height: 640,
        child: SubscriptionPlansView(),
      ),
    ),
  );
}

Future<void> showSubscriptionKaspiQR(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Center(child: Text('payment_page.title'.tr())),
        backgroundColor: Colors.white,
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .center,
            children: [
              Text('payment_page.scan_qr_or_pay'.tr()),

              const SizedBox(
                height: 32,
              ),
              Image.asset('assets/images/kaspiqr.png'),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: context.screenWidth,
                child: FFButton(
                  onPressed: () async {
                    Uri uri = Uri.parse('https://pay.kaspi.kz/pay/uwpxe4ko');

                    await launchUrl(uri);
                  },
                  text: 'payment_page.pay_plan'.tr(),
                  secondTheme: true,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'payment_page.send_receipt_hint'.tr(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: context.screenWidth,
                child: FFButton(
                  onPressed: () async {
                    Uri uri = Uri.parse('https://wa.me/77066215981');

                    await launchUrl(uri);
                  },
                  text: 'payment_page.send_receipt'.tr(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
