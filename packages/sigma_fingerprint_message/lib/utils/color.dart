import 'package:flutter/material.dart';

Color parseColor(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor'; // Add opacity if not present
  }
  return Color(int.parse(hexColor, radix: 16));
}
