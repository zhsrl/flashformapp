import 'package:url_launcher/url_launcher.dart';

String countryCodeToEmoji(String countryCode) {
  String cc = countryCode.toUpperCase();

  final int firstLetter = cc.codeUnitAt(0) + 127397;
  final int secondLetter = cc.codeUnitAt(1) + 127397;

  return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
}

Future<void> openMessenger(String url) async {
  final Uri uri = Uri.parse(url);

  // Пытаемся открыть. Если не получится (нет приложения),
  // ссылка откроется в браузере (для https).
  if (!await launchUrl(
    uri,
    mode: LaunchMode
        .externalApplication, // <--- ВАЖНО: Открывает именно приложение
  )) {
    throw 'Не удалось открыть $url';
  }
}

String? handleAuthErrors(String errorCode, String lang) {
  // Приводим к нижнему регистру для надежности
  final normalizedKey = errorCode.toLowerCase();

  // Карта ошибок: Key -> { 'ru': ..., 'kk': ... }
  final Map<String, Map<String, String>> errorsMap = {
    // --- Основные ошибки входа ---
    'invalid_credentials': {
      'ru': 'Неверный логин или пароль',
      'kk': 'Логин немесе құпия сөз қате',
    },
    'invalid login credentials': {
      // Дублируем текст, если code придет null
      'ru': 'Неверный логин или пароль',
      'kk': 'Логин немесе құпия сөз қате',
    },

    // --- Регистрация ---
    'user_already_registered': {
      'ru': 'Пользователь с таким Email уже существует',
      'kk': 'Бұл Email тіркелген',
    },
    'anonymous_provider_disabled': {
      'ru': 'Анонимный вход отключен',
      'kk': 'Анонимді кіру өшірілген',
    },

    // --- Пароли ---
    'weak_password': {
      'ru': 'Пароль должен содержать минимум 6 символов',
      'kk': 'Құпия сөз кемінде 6 таңбадан тұруы керек',
    },
    'password should be at least 6 characters': {
      'ru': 'Пароль должен содержать минимум 6 символов',
      'kk': 'Құпия сөз кемінде 6 таңбадан тұруы керек',
    },

    // --- Подтверждения и токены ---
    'otp_expired': {
      'ru': 'Срок действия кода истек',
      'kk': 'Код мерзімі өтіп кетті',
    },
    'email_not_confirmed': {
      'ru': 'Email не подтвержден. Проверьте почту',
      'kk': 'Email расталмаған. Поштаны тексеріңіз',
    },

    // --- Лимиты ---
    'over_email_send_rate_limit': {
      'ru': 'Слишком много запросов. Подождите немного',
      'kk': 'Сұраныс тым көп. Біраз күте тұрыңыз',
    },
    '429': {
      // Иногда приходит просто статус код
      'ru': 'Слишком много попыток. Попробуйте позже',
      'kk': 'Әрекет тым көп. Кейінірек қайталаңыз',
    },
  };

  for (var entry in errorsMap.entries) {
    if (normalizedKey.contains(entry.key)) {
      return entry.value[lang];
    }
  }

  return null;
}
