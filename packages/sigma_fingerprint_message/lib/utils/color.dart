import 'package:flutter/material.dart';

Color parseColor(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor'; // Add opacity if not present
  }
  return Color(int.parse(hexColor, radix: 16));
}

Color smParseColor(String hexColor, [Color fallback = Colors.white]) {
  try {
    String hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
  } catch (_) {}
  return fallback;
}