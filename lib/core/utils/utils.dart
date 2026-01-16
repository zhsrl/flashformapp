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
