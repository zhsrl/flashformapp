import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:flashform_app/data/controller/payment_controller.dart';
import 'package:flashform_app/data/controller/user_controller.dart';
import 'package:flashform_app/data/model/subscription_plan.dart';
import 'package:flashform_app/data/repository/auth_repository.dart';
import 'package:flashform_app/features/widgets/ff_button.dart';
import 'package:flashform_app/features/widgets/ff_textfield.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  final String planId;

  final int amount;
  final String planName;

  const PaymentDialog({
    required this.planId,
    required this.amount,
    required this.planName,
  });

  @override
  ConsumerState<PaymentDialog> createState() => _PaymentDialogState();
}

enum PaymentDialogStatus { entry, waiting, success, timeout }

class _PaymentDialogState extends ConsumerState<PaymentDialog> {
  late TextEditingController _phoneController;
  bool _isLoading = false;
  PaymentDialogStatus _status = PaymentDialogStatus.entry;
  bool _hasBaseline = false;
  SubscriptionPlan? _initialPlan;
  DateTime? _initialPlanExpiresAt;
  SubscriptionPlan? _updatedPlan;
  DateTime? _updatedPlanExpiresAt;
  StreamSubscription<List<Map<String, dynamic>>>? _userStreamSub;
  Timer? _timeoutTimer;
  String? _waitingError;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _userStreamSub?.cancel();
    _timeoutTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _startWaitingForPayment() {
    final userId = ref.read(currentUserIdProvider);
    _hasBaseline = false;
    _initialPlan = null;
    _initialPlanExpiresAt = null;
    _updatedPlan = null;
    _updatedPlanExpiresAt = null;

    if (userId == null) {
      setState(() {
        _status = PaymentDialogStatus.timeout;
        _waitingError = 'Пользователь не найден';
      });
      return;
    }

    setState(() {
      _status = PaymentDialogStatus.waiting;
      _waitingError = null;
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 90), () {
      if (!mounted || _status != PaymentDialogStatus.waiting) return;
      setState(() {
        _status = PaymentDialogStatus.timeout;
      });
    });

    _userStreamSub?.cancel();
    _userStreamSub = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .listen((rows) {
          if (!mounted || rows.isEmpty) return;

          final row = rows.first;
          final planValue = row['plan']?.toString();
          final expiresValue = row['plan_expires_at'];

          final plan = planValue != null
              ? SubscriptionPlan.fromString(planValue)
              : null;

          DateTime? expiresAt;
          if (expiresValue != null && expiresValue.toString().isNotEmpty) {
            expiresAt = DateTime.tryParse(expiresValue.toString())?.toLocal();
          }

          if (!_hasBaseline) {
            _initialPlan = plan;
            _initialPlanExpiresAt = expiresAt;
            _hasBaseline = true;
            return;
          }

          final planChanged = plan != null && plan != _initialPlan;
          final expiresChanged =
              expiresAt != null && !_sameDate(expiresAt, _initialPlanExpiresAt);

          if (!planChanged && !expiresChanged) return;

          _timeoutTimer?.cancel();
          _userStreamSub?.cancel();

          setState(() {
            _status = PaymentDialogStatus.success;
            _updatedPlan = plan ?? _initialPlan;
            _updatedPlanExpiresAt = expiresAt ?? _initialPlanExpiresAt;
          });

          ref.read(userControllerProvider.notifier).loadProfile();
        });
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.isAtSameMomentAs(b);
  }

  Future<void> _processPayment() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите номер телефона')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentId = await ref
          .read(paymentControllerProvider.notifier)
          .initiatePayment(
            phoneNumber: phone,
            amount: widget.amount,
            planId: widget.planId,
          );

      if (!mounted) return;

      if (paymentId != null && paymentId.isNotEmpty) {
        if (!mounted) return;
        _startWaitingForPayment();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Ошибка: Не удалось получить ID платежа'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Ошибка платежа: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('Payment dialog error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('dd.MM.yyyy').format(value);
  }

  Widget _buildContent() {
    if (_status == PaymentDialogStatus.entry) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FFTextField(
            controller: _phoneController,
            hintText: '+77001234567',
            prefixIcon: HeroIcon(HeroIcons.phone),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withAlpha(50)),
            ),
            child: Row(
              children: [
                HeroIcon(
                  HeroIcons.informationCircle,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Счет будет отправлен на приложение Kaspi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_status == PaymentDialogStatus.waiting) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(height: 8),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Ожидается оплата',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'После оплаты статус обновится автоматически',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_status == PaymentDialogStatus.timeout) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          HeroIcon(
            HeroIcons.exclamationTriangle,
            size: 40,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          const Text(
            'Оплата не подтверждена',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _waitingError ?? 'Обновите страницу',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final planName = _updatedPlan?.displayName ?? widget.planName;
    final expiresAt = _formatDate(_updatedPlanExpiresAt);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            HeroIcon(
              HeroIcons.checkCircle,
              size: 22,
              color: Colors.green,
            ),
            SizedBox(width: 8),
            Text(
              'Подписка активирована',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Тариф: $planName'),
        const SizedBox(height: 6),
        Text('Действует до: $expiresAt'),
        const SizedBox(height: 16),
        const Text(
          'Обновите страницу',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Оплата подписки',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 400,
        child: _buildContent(),
      ),
      actions: [
        if (_status == PaymentDialogStatus.entry) ...[
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),

            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          FFButton(
            onPressed: _isLoading ? null : _processPayment,
            isLoading: _isLoading,
            text: 'Оплатить',
            marginBottom: 0,
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Закрыть',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }
}
