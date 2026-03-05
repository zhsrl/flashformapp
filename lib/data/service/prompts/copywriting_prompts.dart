/// Централизованное хранилище промптов для копирайтинга на разных языках
class CopywritingPrompts {
  /// Инструкции для генерации по типам контента
  static Map<String, Map<String, String>> get instructions => {
        'title': {
          'kk': '''Құрылымды сипаттайтын ұялы және тартымды заголовок жас.
- 5-10 сөз арасында болсын
- Пайдасын және құндылығын бей
- Қызығушылық пробуждай''',
          'ru': '''Создай короткий и привлекательный заголовок.
- Длина 5-10 слов
- Подчеркни выгоду и ценность
- Пробуди интерес и любопытство''',
          'en': '''Create a short, compelling title.
- 5-10 words
- Highlight benefit and value
- Trigger curiosity and interest''',
        },
        'description': {
          'kk': '''Толық сипаттама жас. Өндіктердің пайдасын, мәселесінің шешімін және құндылығын айт.
- 2-3 сөйлем
- Проблема → Шешім → Құндылық бар болсын
- Әрекетке итермелей''',
          'ru': '''Создай полное описание. Расскажи о преимуществах, решении проблемы и ценности.
- 2-3 предложения
- Структура: Проблема → Решение → Ценность
- Мотивируй к действию''',
          'en': '''Create a complete description highlighting benefits, problem solution, and value.
- 2-3 sentences
- Structure: Problem → Solution → Value
- Motivate to action''',
        },
        'button': {
          'kk': '''Әрекетке итермелейтін CTA батырмасы жас.
- 2-4 сөз
- Іс сөздерін қолдан: "Білу", "Жүктеу", "Сатуды құрау" және т.б.
- Жылдамдық және ынамдықты пробуждай''',
          'ru': '''Создай мотивирующую CTA кнопку.
- 2-4 слова
- Используй глаголы действия: "Узнать", "Скачать", "Начать продажи" и т.д.
- Вызови срочность и уверенность''',
          'en': '''Create a motivating CTA button.
- 2-4 words
- Use action verbs: "Learn", "Download", "Start Selling" etc.
- Create urgency and confidence''',
        },
        'success': {
          'kk': '''Нәтижесіз сөйлемін жас. Құрмет көрсет, құндылық айт, келесі қадамы айт.
- 1-2 сөйлем
- Кейде өнімге ұсыну жаса
- Шексіз ықпалды береді''',
          'ru': '''Создай благодарственное сообщение. Выражай признательность, подчеркни ценность, укажи следующий шаг.
- 1-2 предложения
- Иногда предложи дополнительный продукт
- Создай положительный опыт''',
          'en': '''Create a thank-you message. Express gratitude, highlight value, suggest next step.
- 1-2 sentences
- Sometimes offer additional product
- Create positive experience''',
        },
        'whatsapp': {
          'kk': '''WhatsApp автожауабын жас. Кісілік, ынамды, құрметті болсын.
- 1-2 сөйлем
- Тез жауап бер
- Байланыс сақта''',
          'ru': '''Создай автоответ в WhatsApp. Будь личным, надежным и уважительным.
- 1-2 предложения
- Отвечай быстро
- Поддерживай контакт''',
          'en': '''Create a WhatsApp auto-reply. Be personal, reliable, and respectful.
- 1-2 sentences
- Quick response
- Maintain contact''',
        },
        'redirect': {
          'kk': '''Перенаправлау беттеуіндіңі қош келсеңіз сообщение жас.
- 1 сөйлем
- Келесі қадамды айт
- Ынамды құру''',
          'ru': '''Создай приветственное сообщение для страницы перенаправления.
- 1 предложение
- Укажи следующий шаг
- Строй доверие''',
          'en': '''Create a welcome message for redirect page.
- 1 sentence
- Suggest next step
- Build trust''',
        },
      };

  /// Языковые названия
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'kk':
        return 'Kazakh (Қазақ)';
      case 'ru':
        return 'Russian (Русский)';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }

  /// Получи инструкцию для типа контента и языка
  static String getInstruction(String type, String language) {
    return instructions[type]?[language] ??
        instructions[type]?['en'] ??
        'Generate compelling copywriting text.';
  }

  /// Локализированное сообщение об ошибке
  static String getErrorMessage(String language) {
    switch (language) {
      case 'kk':
        return 'AI жауап алу сәтсіз болды. Қайта әрекет етіңіз.';
      case 'ru':
        return 'Не удалось получить ответ AI. Попробуйте снова.';
      case 'en':
        return 'Failed to get AI response. Try again.';
      default:
        return 'An error occurred';
    }
  }

  /// Локализированное сообщение загрузки
  static String getLoadingMessage(String language) {
    switch (language) {
      case 'kk':
        return 'AI копирайтер іс істеп жатыр...';
      case 'ru':
        return 'AI копирайтер работает...';
      case 'en':
        return 'AI copywriter is working...';
      default:
        return 'Loading...';
    }
  }
}
