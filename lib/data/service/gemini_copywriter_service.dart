import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flashform_app/data/model/copywriting_response.dart';

class GeminiCopywriterService {
  late final GenerativeModel _model;
  final String apiKey;

  GeminiCopywriterService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
    );
  }

  /// Генерирует копирайтинг для разных типов контента
  Future<CopywritingResponse> generateCopywriting({
    required String
    type, // 'title', 'description', 'button', 'success', 'whatsapp', 'redirect'
    required String language, // 'kk', 'ru', 'en'
    required String context,
    int numberOfVariants = 3,
  }) async {
    final prompt = _buildPrompt(
      type: type,
      language: language,
      context: context,
      numberOfVariants: numberOfVariants,
    );

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null) {
        throw Exception('Empty response from Gemini API');
      }

      final variants = _parseVariants(response.text!);

      return CopywritingResponse(
        primaryText: variants.isNotEmpty ? variants.first : response.text ?? '',
        alternatives: variants.length > 1 ? variants.sublist(1) : [],
        type: type,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Генерирует всю структуру формы по описанию
  Future<Map<String, dynamic>> generateFormStructure({
    required String description,
    required String language, // 'kk', 'ru', 'en'
  }) async {
    final prompt = _buildFormGenerationPrompt(
      description: description,
      language: language,
    );

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      if (response.text == null) {
        throw Exception('Empty response from Gemini API');
      }

      return _parseFormStructure(response.text!);
    } catch (e) {
      rethrow;
    }
  }

  String _buildPrompt({
    required String type,
    required String language,
    required String context,
    required int numberOfVariants,
  }) {
    final languageName = _getLanguageName(language);
    final instructions = _getCopywritingInstructions(type, language);

    return '''You are a professional copywriter specializing in high-converting marketing copy.

Language: $languageName
Type: $type
Context: $context

$instructions

Generate exactly $numberOfVariants variants of high-quality, compelling text.

Requirements:
- Each variant should be different in tone and approach
- Make it persuasive and conversion-focused
- Keep it concise and impactful
- Output ONLY the variants, one per line, numbered (1., 2., 3., etc.)
- Do NOT include explanations or extra text

${language == 'kk'
        ? 'Жауап қазақ тілінде беріңіз.'
        : language == 'ru'
        ? 'Ответ дайте на русском языке.'
        : 'Respond in English.'}
''';
  }

  String _buildFormGenerationPrompt({
    required String description,
    required String language,
  }) {
    final languageName = _getLanguageName(language);

    return '''You are an expert form builder and copywriter.

Language: $languageName
User Description: $description

Based on the user description, generate a complete form structure in JSON format with these fields:
{
  "title": "compelling form title",
  "subtitle": "brief description of what user will get",
  "fields": [
    {
      "type": "text|email|phone|number|textarea|select",
      "label": "field label",
      "placeholder": "placeholder text",
      "required": true|false
    }
  ],
  "button_text": "compelling CTA button text",
  "success_message": "thank you message after submission"
}

Requirements:
- Create a practical, conversion-optimized form
- Include 3-5 relevant fields based on the description
- All text should be persuasive and professional
- Output ONLY valid JSON, no explanations

${language == 'kk'
        ? 'Жауап қазақ тілінде беріңіз.'
        : language == 'ru'
        ? 'Ответ дайте на русском языке.'
        : 'Respond in English.'}
''';
  }

  String _getCopywritingInstructions(String type, String language) {
    switch (type) {
      case 'title':
        return language == 'kk'
            ? '''Құрылымды сипаттайтын ұялы және тартымды заголовок жас.
- 5-10 сөз арасында болсын
- Пайдасын және құндылығын бей
- Қызығушылық пробуждай'''
            : language == 'ru'
            ? '''Создай короткий и привлекательный заголовок.
- Длина 5-10 слов
- Подчеркни выгоду и ценность
- Пробуди интерес и любопытство'''
            : '''Create a short, compelling title.
- 5-10 words
- Highlight benefit and value
- Trigger curiosity and interest''';

      case 'description':
        return language == 'kk'
            ? '''Толық сипаттама жас. Өндіктердің пайдасын, мәселесінің шешімін және құндылығын айт.
- 2-3 сөйлем
- Проблема → Шешім → Құндылық бар болсын
- Әрекетке итермелей'''
            : language == 'ru'
            ? '''Создай полное описание. Расскажи о преимуществах, решении проблемы и ценности.
- 2-3 предложения
- Структура: Проблема → Решение → Ценность
- Мотивируй к действию'''
            : '''Create a complete description highlighting benefits, problem solution, and value.
- 2-3 sentences
- Structure: Problem → Solution → Value
- Motivate to action''';

      case 'button':
        return language == 'kk'
            ? '''Әрекетке итермелейтін CTA батырмасы жас.
- 2-4 сөз
- Іс сөздерін қолдан: "Білу", "Жүктеу", "Сатуды құрау" және т.б.
- Жылдамдық және ынамдықты пробуждай'''
            : language == 'ru'
            ? '''Создай мотивирующую CTA кнопку.
- 2-4 слова
- Используй глаголы действия: "Узнать", "Скачать", "Начать продажи" и т.д.
- Вызови срочность и уверенность'''
            : '''Create a motivating CTA button.
- 2-4 words
- Use action verbs: "Learn", "Download", "Start Selling" etc.
- Create urgency and confidence''';

      case 'success':
        return language == 'kk'
            ? '''Нәтижесіз сөйлемін жас. Құрмет көрсет, құндылық айт, келесі қадамы айт.
- 1-2 сөйлем
- Кейде өнімге ұсыну жаса
- Шексіз ықпалды береді'''
            : language == 'ru'
            ? '''Создай благодарственное сообщение. Выражай признательность, подчеркни ценность, укажи следующий шаг.
- 1-2 предложения
- Иногда предложи дополнительный продукт
- Создай положительный опыт'''
            : '''Create a thank-you message. Express gratitude, highlight value, suggest next step.
- 1-2 sentences
- Sometimes offer additional product
- Create positive experience''';

      case 'whatsapp':
        return language == 'kk'
            ? '''WhatsApp автожауабын жас. Кісілік, ынамды, құрметті болсын.
- 1-2 сөйлем
- Тез жауап бер
- Байланыс сақта'''
            : language == 'ru'
            ? '''Создай автоответ в WhatsApp. Будь личным, надежным и уважительным.
- 1-2 предложения
- Отвечай быстро
- Поддерживай контакт'''
            : '''Create a WhatsApp auto-reply. Be personal, reliable, and respectful.
- 1-2 sentences
- Quick response
- Maintain contact''';

      case 'redirect':
        return language == 'kk'
            ? '''Перенаправлау беттеуіндіңі қош келсеңіз сообщение жас.
- 1 сөйлем
- Келесі қадамды айт
- Ынамды құру'''
            : language == 'ru'
            ? '''Создай приветственное сообщение для страницы перенаправления.
- 1 предложение
- Укажи следующий шаг
- Строй доверие'''
            : '''Create a welcome message for redirect page.
- 1 sentence
- Suggest next step
- Build trust''';

      default:
        return 'Generate compelling copywriting text.';
    }
  }

  String _getLanguageName(String language) {
    switch (language) {
      case 'kk':
        return 'Kazakh (Қазақ)';
      case 'ru':
        return 'Russian (Русский)';
      case 'en':
        return 'English';
      default:
        return language;
    }
  }

  List<String> _parseVariants(String response) {
    return response
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !line.startsWith('**')) // Исключи markdown
        .toList();
  }

  Map<String, dynamic> _parseFormStructure(String response) {
    try {
      // Попробуй найти JSON в response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw Exception('No JSON found in response');
      }

      final jsonString = response.substring(jsonStart, jsonEnd + 1);

      // Простой парсинг JSON (можно использовать jsonDecode если нужно)
      // Здесь возвращаем строку, которую потом можно распарсить
      return {'raw': jsonString};
    } catch (e) {
      rethrow;
    }
  }
}
