import 'package:flashform_app/data/model/subscription_plan.dart';

enum SubscriptionStatus { active, expired, cancelled }

class Subscription {
  const Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.autoRenew,
    required this.startedAt,
    this.expiresAt,
    this.createdAt,
  });

  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final bool autoRenew;
  final DateTime startedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  bool get isActive => status == SubscriptionStatus.active;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      plan: SubscriptionPlan.fromString(json['plan'] as String),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      autoRenew: json['auto_renew'] as bool? ?? true,
      startedAt: DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'plan': plan.name,
        'status': status.name,
        'auto_renew': autoRenew,
        'started_at': startedAt.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
      };
}
