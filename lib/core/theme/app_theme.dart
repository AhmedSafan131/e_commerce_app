import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF53B175); // Grocery Green
  static const Color darkText = Color(0xFF181725);
  static const Color greyText = Color(0xFF7C7C7C);
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0xFFE2E2E2);
  static const Color border = Color(0xFFE2E2E2);

  // Legacy mappings for compatibility
  static const Color black = darkText;
  static const Color white = background;
  static const Color lime = primary;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    background: AppColors.background,
    surface: AppColors.background,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onBackground: AppColors.darkText,
    onSurface: AppColors.darkText,
  ),
  fontFamily: 'Gilroy', // Use Gilroy or system default if unavailable
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      // For large headers
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
      fontSize: 26,
    ),
    headlineMedium: TextStyle(
      // For section titles
      fontWeight: FontWeight.w600,
      color: AppColors.darkText,
      fontSize: 24,
    ),
    titleLarge: TextStyle(
      // For page titles
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
      fontSize: 20,
    ),
    titleMedium: TextStyle(
      // For product titles
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      // Standard body text
      fontWeight: FontWeight.w500,
      color: AppColors.darkText,
      fontSize: 14,
    ),
    bodySmall: TextStyle(
      // Descriptions/Subtitles
      fontWeight: FontWeight.w500,
      color: AppColors.greyText,
      fontSize: 13,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Gilroy',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: AppColors.darkText,
    ),
    iconTheme: IconThemeData(color: AppColors.darkText),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF2F3F2),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
    ),
    prefixIconColor: AppColors.darkText,
    hintStyle: const TextStyle(color: AppColors.greyText, fontSize: 14, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 18),
    ),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.background,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.darkText,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 10,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primary),
    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.darkText),
  ),
);
