enum SubscriptionPlan {
  spark,
  go,
  pro
  ;

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

  // Сумма для платежа в тенге (0 для бесплатного плана)
  int get amountKzt => switch (this) {
    spark => 0,
    go => 4990,
    pro => 13990,
  };

  // Текущий биллинговый период
  int get billingPeriodDays => switch (this) {
    spark => 0,
    go => 30,
    pro => 30,
  };

  // Лимит форм
  int get formsLimit => switch (this) {
    spark => 2,
    go => 10,
    pro => 1000,
  };

  // Лимит лидов в месяц (null = безлимит)
  int? get leadsPerMonthLimit => switch (this) {
    spark => 500,
    go => 3000,
    pro => null,
  };

  // Доступ к интеграциям
  bool get hasIntegrations => integrations;

  // Экспорт таблицы в CSV
  bool get hasExport => switch (this) {
    spark => false,
    go => true,
    pro => true,
  };

  // Доступ к футер
  bool get hasFooter => switch (this) {
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

  // Доступ к Яндекс Метрике
  bool get hasYaMetrikaIntegration => switch (this) {
    spark => false,
    go => true,
    pro => true,
  };

  // Доступ к Телеграм бот уведомления
  bool get hasTelegramBotIntegration => switch (this) {
    spark => false,
    go => false,
    pro => true,
  };

  String get displayPrice => switch (this) {
    spark => 'Бесплатно',
    go => '10\$ / 5.000 KZT / 850 RUB',
    pro => '29\$ / 14.000 KZT / 2.500 RUB',
  };

  List<String> get availableIntegrations => switch (this) {
    spark => ['Meta Pixel'],
    go => ['Meta Pixel', 'Яндекс Метрика', 'Telegram Bot для уведомления'],
    pro => ['Meta Pixel', 'Яндекс Метрика', 'Telegram Bot для уведомления'],
  };

  List<String> get featureList {
    final leadsLimit = leadsPerMonthLimit;

    return [
      '$formsLimit страниц',
      if (leadsLimit != null) '$leadsLimit лидов каждый месяц',
      if (hasExport) 'Экспорт данных в CSV',
      if (canRemoveBranding) 'Убрать логотип Made on Flashform',
    ];
  }

  String get displayName => switch (this) {
    spark => 'Spark',
    go => 'Go',
    pro => 'Pro',
  };

  bool get isFree => this == spark;
  bool get isPaid => this != spark;
}
