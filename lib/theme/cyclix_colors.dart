import 'package:flutter/material.dart';

abstract final class CyclixColors {
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color accentGreen = Color(0xFF00C853);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color cardGrey = Color(0xFFF5F5F5);
  static const Color instructionGray = Color(0xFF757575);
  static const Color headerBorder = accentGreen;

  // Mapeo para compatibilidad con código existente si fuera necesario
  static const Color brandGreen = accentGreen;
  static const Color brandBlue = primaryBlue;
  static const Color scaffoldBackground = backgroundWhite;
}
