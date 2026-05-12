// Пример как использовать PaymentDialog в вашем коде
// Добавьте это в features/settings/views/desktop/settings_view_desktop.dart

import 'package:flashform_app/features/settings/widgets/payment_dialog.dart';
import 'package:flutter/material.dart';

// В любом месте где нужна оплата (например, нажатие на кнопку тарифа):

void _openPaymentDialog(
  String planId,
  int amount,
  String planName,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (context) => PaymentDialog(
      planId: planId,
      amount: amount,
      planName: planName,
    ),
  );
}

// Пример вызова:
// _openPaymentDialog('pro_plan', 9900, 'Pro Plan');

// Или если у вас уже есть кнопка оплаты:
// ElevatedButton(
//   onPressed: () => _openPaymentDialog('pro_plan', 9900, 'Pro Plan'),
//   child: Text('Купить Pro'),
// ),
