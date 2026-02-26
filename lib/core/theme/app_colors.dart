import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primarios
  static const Color mintGreen = Color(0xFFA8E6CF);
  static const Color mintGreenLight = Color(0xFFD4F5E4);
  static const Color mintGreenDark = Color(0xFF7DD4AA);

  // Acento
  static const Color skyBlue = Color(0xFF88D8F7);
  static const Color skyBlueLight = Color(0xFFB8E8FA);
  static const Color skyBlueDark = Color(0xFF5BC4E8);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8FFFE);
  static const Color background = Color(0xFFF0FAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D3436);
  static const Color bodyText = Color(0xFF636E72);
  static const Color subtleText = Color(0xFFB2BEC3);
  static const Color divider = Color(0xFFE8F5EE);

  // Semánticos
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);
  static const Color success = Color(0xFF55EFC4);

  // Macronutrientes
  static const Color calorieColor = Color(0xFFFF7675);
  static const Color proteinColor = Color(0xFF74B9FF);
  static const Color carbColor = Color(0xFFFDCB6E);
  static const Color fatColor = Color(0xFFE17055);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [mintGreen, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0FAF5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
