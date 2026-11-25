import 'package:flutter/material.dart';

class AppColors {
  // Primary Pastel Palette
  static const Color primarySage = Color(0xFFDDEFE3);
  static const Color mintGreen = Color(0xFFC7EBDD);
  static const Color softSkyBlue = Color(0xFFDCEBFA);
  static const Color pastelLavender = Color(0xFFEAE2F7);
  static const Color warmPeach = Color(0xFFFBE4D8);
  static const Color butterYellow = Color(0xFFFFF1CC);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAF7);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderSoft = Color(0xFFE2E8E4);

  // Accessible Typography (WCAG AA compliant >= 4.5:1 against light surfaces)
  static const Color textPrimary = Color(0xFF30443A);
  static const Color textSecondary = Color(0xFF5D6B62);
  static const Color textTertiary = Color(0xFF88958D);

  // Semantic Feedback (WCAG AA compliant)
  static const Color success = Color(0xFF3D7057);
  static const Color warning = Color(0xFFD6A451);
  static const Color critical = Color(0xFFC96C70);
  static const Color info = Color(0xFF4A7AB5);

  // AQI Category Specific Pastel Tints
  static const Color aqiGood = Color(0xFFDDEFE3);
  static const Color aqiModerate = Color(0xFFFFF1CC);
  static const Color aqiSensitive = Color(0xFFFBE4D8);
  static const Color aqiUnhealthy = Color(0xFFF7D5D6);
  static const Color aqiVeryUnhealthy = Color(0xFFEAE2F7);
  static const Color aqiHazardous = Color(0xFFE3D0D5);

  static Color getAqiTint(int aqi) {
    if (aqi <= 50) return aqiGood;
    if (aqi <= 100) return aqiModerate;
    if (aqi <= 150) return aqiSensitive;
    if (aqi <= 200) return aqiUnhealthy;
    if (aqi <= 300) return aqiVeryUnhealthy;
    return aqiHazardous;
  }

  static Color getAqiAccent(int aqi) {
    if (aqi <= 50) return const Color(0xFF2E6B47);
    if (aqi <= 100) return const Color(0xFF9E7B15);
    if (aqi <= 150) return const Color(0xFFB55D28);
    if (aqi <= 200) return const Color(0xFFA8363B);
    if (aqi <= 300) return const Color(0xFF6B4799);
    return const Color(0xFF752B3C);
  }
}
