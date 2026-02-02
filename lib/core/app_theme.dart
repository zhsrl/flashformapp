import 'package:flutter/material.dart';

class AppTheme {
  // static Color background = Color(0xFFF0F0F0);
  static Color background = Color(0xFFFFFFFF);
  static Color border = Color(0xFF000000).withAlpha(14);
  static Color tertiary = Color(0xFF000000).withAlpha(50);
  static Color primary = Color(0xFFd0f20b);
  // static Color primary = Color(0xFF2424ed);
  static Color secondary = Color(0xFF0b1a05);
  static const Color fourty = Color(0xFFf7f7f7);
}

extension HexColor on String {
  Color toColor() {
    final hexString = replaceAll('#', '');
    final buffer = StringBuffer();
    if (hexString.length == 6) {
      buffer.write('ff');
    }
    buffer.write(hexString);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ColorToHex on Color {
  String toHex() {
    // ignore: deprecated_member_use
    return '#${value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
