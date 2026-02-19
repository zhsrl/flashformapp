import 'package:flashform_app/data/model/subscription_plan.dart';

class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.plan = SubscriptionPlan.spark,
    this.planExpiresAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final SubscriptionPlan plan;
  final DateTime? planExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPlanActive =>
      plan.isFree || (planExpiresAt != null && DateTime.now().isBefore(planExpiresAt!));

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      plan: json['plan'] != null
          ? SubscriptionPlan.fromString(json['plan'] as String)
          : SubscriptionPlan.spark,
      planExpiresAt: json['plan_expires_at'] != null
          ? DateTime.parse(json['plan_expires_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'plan': plan.name,
    'plan_expires_at': planExpiresAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? email,
    String? name,
    SubscriptionPlan? plan,
    DateTime? planExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        plan: plan ?? this.plan,
        planExpiresAt: planExpiresAt ?? this.planExpiresAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          plan == other.plan &&
          planExpiresAt == other.planExpiresAt &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      plan.hashCode ^
      planExpiresAt.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
