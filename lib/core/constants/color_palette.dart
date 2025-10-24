import 'package:flutter/material.dart';

class ColorPalette {
  const ColorPalette._();
  static const Color primary = Color(0xFF346FEF);
  static const Color primaryLight = Color(0xFF4F86FB);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF505050);
  static const Color sheetBackground = Colors.white;
  static const Color pageBackground = Colors.white;
  static const Color iconGray = Color(0xFF808488);
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight],
  );
  static const Gradient skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F8FF), Color(0xFFFFFFFF)],
  );
}