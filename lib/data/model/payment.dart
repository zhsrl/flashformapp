enum PaymentStatus { pending, completed, failed }

enum PaymentProvider { tiptop, epay }

class Payment {
  const Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    this.subscriptionId,
    this.provider,
    this.providerTxId,
    this.paidAt,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String? subscriptionId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentProvider? provider;
  final String? providerTxId;
  final DateTime? paidAt;
  final DateTime? createdAt;

  bool get isCompleted => status == PaymentStatus.completed;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subscriptionId: json['subscription_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KZT',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      provider: json['provider'] != null
          ? PaymentProvider.values.firstWhere(
              (e) => e.name == json['provider'],
              orElse: () => PaymentProvider.tiptop,
            )
          : null,
      providerTxId: json['provider_tx_id'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'subscription_id': subscriptionId,
        'amount': amount,
        'currency': currency,
        'status': status.name,
        'provider': provider?.name,
        'provider_tx_id': providerTxId,
        'paid_at': paidAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };
}
