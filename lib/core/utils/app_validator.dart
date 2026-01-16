class AppValidators {
  // Валидация Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите Email';
    }
    // Простая регулярка для проверки формата email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Некорректный Email';
    }
    return null;
  }

  // Валидация Пароля (минимум 6 символов, требование Supabase)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 6) {
      return 'Минимум 6 символов';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    if (value.length < 2) {
      return 'Введите корректное имя';
    }
    return null;
  }

  // Валидация повтора пароля (для SignUp)
  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Повторите пароль';
    }
    if (value != originalPassword) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  // Валидация OTP (строго 6 цифр)
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите код';
    }
    if (value.length != 6) {
      return 'Код должен состоять из 6 цифр';
    }
    // Проверка, что только цифры
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Только цифры';
    }
    return null;
  }
}
