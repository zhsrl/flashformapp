enum SubscriptionPlan {
  trial,
  go,
  pro
  ;

  static SubscriptionPlan fromString(String value) {
    return SubscriptionPlan.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SubscriptionPlan.trial,
    );
  }

  bool get integrations => switch (this) {
    trial => false,
    go => true,
    pro => true,
  };

  // Сумма для платежа в тенге (0 для бесплатного плана)
  int get amountKzt => switch (this) {
    trial => 0,
    go => 1990,
    pro => 3990,
  };

  // Текущий биллинговый период
  int get billingPeriodDays => switch (this) {
    trial => 0,
    go => 30,
    pro => 30,
  };

  // Лимит форм
  int? get formsLimit => switch (this) {
    trial => 0,
    go => 15,
    pro => null,
  };

  // Лимит лидов в месяц (null = безлимит)
  int? get leadsPerMonthLimit => switch (this) {
    trial => 0,
    go => 5000,
    pro => null,
  };

  // Доступ к интеграциям
  bool get hasIntegrations => integrations;

  // Экспорт таблицы в CSV
  bool get hasExport => switch (this) {
    trial => false,
    go => true,
    pro => true,
  };

  // Доступ к футер
  bool get hasFooter => switch (this) {
    trial => false,
    go => true,
    pro => true,
  };
  // Убрать логотип "Made on Flashform"
  bool get canRemoveBranding => switch (this) {
    trial => false,
    go => false,
    pro => true,
  };

  bool get canChangeSlug => switch (this) {
    trial => false,
    go => false,
    pro => true,
  };

  // Доступ к Meta Pixel
  bool get hasMetaPixelIntegration => switch (this) {
    trial => false,
    go => true,
    pro => true,
  };
  // Доступ к Яндекс Метрике
  bool get hasYaMetrikaIntegration => switch (this) {
    trial => false,
    go => true,
    pro => true,
  };

  // Доступ к Телеграм бот уведомления
  bool get hasTelegramBotIntegration => switch (this) {
    trial => false,
    go => false,
    pro => true,
  };

  bool get hasGoogleSheetsIntegration => switch (this) {
    trial => false,
    go => false,
    pro => true,
  };

  String get displayPrice => switch (this) {
    trial => 'Бесплатно',
    go => '$amountKzt KZT',
    pro => '$amountKzt KZT',
  };

  List<String> get featureList {
    final leadsLimit = leadsPerMonthLimit;

    return [
      formsLimit != null
          ? '$formsLimit страниц'
          : 'Неограниченное количество страниц',
      leadsLimit != null
          ? '$leadsLimit лидов каждый месяц'
          : 'Неограниченное количество лидов',

      if (hasExport) 'Экспорт данных в CSV',
      if (canRemoveBranding) 'Убрать логотип Made on Flashform',
    ];
  }

  String get displayName => switch (this) {
    trial => 'Trial',
    go => 'Go',
    pro => 'Pro',
  };

  bool get isFree => this == trial;
  bool get isPaid => this != trial;
}
