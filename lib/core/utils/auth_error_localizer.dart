import 'package:easy_localization/easy_localization.dart';

String localizeAuthError(Object error) {
  final raw = error.toString().replaceAll('Exception: ', '').trim();
  final code = raw.toLowerCase();

  final key = 'errors.$code';
  final localized = key.tr();
  if (localized != key) {
    return localized;
  }

  // Sometimes backend/client returns only HTTP status text with a code.
  final statusMatch = RegExp(r'\b\d{3}\b').firstMatch(code);
  if (statusMatch != null) {
    final statusKey = 'errors.${statusMatch.group(0)}';
    final statusLocalized = statusKey.tr();
    if (statusLocalized != statusKey) {
      return statusLocalized;
    }
  }

  return 'common.error_with_message'.tr(namedArgs: {'message': raw});
}
