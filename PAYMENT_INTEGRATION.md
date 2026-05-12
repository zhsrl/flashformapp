## 🚀 Интеграция платежей Kaspi - MVP

### ✅ Что было реализовано:

1. **PaymentController** (`lib/data/controller/payment_controller.dart`)
   - Управление жизненным циклом платежа
   - Периодическая проверка статуса (каждые 3 сек)
   - Автоматическое обновление подписки в Supabase

2. **PaymentDialog** (`lib/features/settings/widgets/payment_dialog.dart`)
   - UI для ввода номера телефона
   - Отправка счета на Kaspi
   - Визуальная обратная связь

3. **Payment Service** (`lib/data/service/payment_service.dart`)
   - Создание платежей
   - Получение статуса платежей

4. **API Route** (`api/api/payments.ts`)
   - Backend прокси для безопасной работы с API

---

## 📋 TODO перед использованием:

### 1. Обновите базовый URL API

Откройте `lib/data/service/payment_service.dart` и измените:

```dart
final String baseUrl = 'https://flashform-api.vercel.app/api/payments';
```

На ваш реальный URL API проекта на Vercel.

### 2. Обновите переменные окружения на Vercel (API проект)

- Зайдите в Vercel Dashboard → Settings → Environment Variables
- Убедитесь что есть переменная `XPAY_API` с вашим API ключом

### 3. Создайте поле в таблице `users` (Supabase)

```sql
ALTER TABLE users ADD COLUMN subscription_plan TEXT;
ALTER TABLE users ADD COLUMN subscription_updated_at TIMESTAMP;
```

### 4. Используйте PaymentDialog в вашем коде

**Вариант 1: Простой вызов**

```dart
// В любом месте где нужна оплата
showDialog(
  context: context,
  builder: (context) => PaymentDialog(
    planId: 'pro_plan',
    amount: 9900,
    planName: 'Pro Plan',
  ),
);
```

**Вариант 2: Из кнопки тарифа**

```dart
ElevatedButton(
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(
        planId: 'premium_plan',
        amount: 29900,
        planName: 'Premium Plan',
      ),
    );
  },
  child: Text('Купить Premium'),
),
```

---

## 🔄 Поток работы:

1. Пользователь выбирает тариф и вводит номер телефона
2. Система создает платеж через API
3. Счет отправляется на приложение Kaspi.kz
4. Система каждые 3 секунды проверяет статус платежа
5. Когда платеж подтвержден (status = 'completed'):
   - Поле `subscription_plan` обновляется в БД
   - Диалог закрывается
   - Подписка активируется

---

## 📱 Статусы платежа:

- `pending` - Ожидание оплаты
- `completed` - ✅ Платеж успешен
- `failed` - ❌ Ошибка платежа
- `cancelled` - ❌ Отменено пользователем

---

## 🐛 Debug:

Если что-то не работает:

1. Откройте DevTools (F12)
2. Переходим в Console и проверяем ошибки
3. Проверьте Network запросы к вашему API
4. Убедитесь что переменные окружения установлены на Vercel

---

## 📝 Заметки:

- Polling (проверка каждые 3 сек) работает максимум 3 минуты
- Для production лучше использовать Webhooks вместо polling
- Номер телефона должен быть в формате +7XXXXXXXXXX

---

Готово к использованию! 🎉
