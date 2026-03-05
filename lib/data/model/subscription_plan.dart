enum SubscriptionPlan {
  spark,
  go,
  pro;

  static SubscriptionPlan fromString(String value) {
    return SubscriptionPlan.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SubscriptionPlan.spark,
    );
  }

  bool get integrations => switch (this) {
    spark => false,
    go => true,
    pro => true,
  };

  // Лимит форм
  int get formsLimit => switch (this) {
    spark => 3,
    // go => 10,
    go => 6,
    pro => 80,
  };

  // Лимит лидов в месяц (null = безлимит)
  int? get leadsPerMonthLimit => switch (this) {
    spark => 100,
    go => 3000,
    pro => 10000,
  };

  // Доступ к интеграциям (Meta Pixel, Yandex Metrika)
  bool get hasIntegrations => true;

  // Экспорт таблицы в CSV
  bool get hasExport => switch (this) {
    spark => false,
    go => true,
    pro => true,
  };

  // Убрать логотип "Made on Flashform"
  bool get canRemoveBranding => switch (this) {
    spark => false,
    go => false,
    pro => true,
  };

  String get displayName => switch (this) {
    spark => 'Spark',
    go => 'Go',
    pro => 'Pro',
  };

  bool get isFree => this == spark;
  bool get isPaid => this != spark;
}
