import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  // Accent no longer used, kept for reference.
  static const Color lime = Color(0xFFC0FF00);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.white,
  primaryColor: AppColors.black,
  colorScheme: const ColorScheme.light(
    primary: AppColors.black,
    secondary: AppColors.black,
    background: AppColors.white,
    surface: AppColors.white,
    onPrimary: AppColors.black,
    onSecondary: AppColors.black,
    onBackground: AppColors.black,
    onSurface: AppColors.black,
  ),
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontWeight: FontWeight.w800,
      color: AppColors.black,
      letterSpacing: -1.0,
    ),
    headlineMedium: TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.black,
      letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w300,
      color: AppColors.black,
    ),
    bodySmall: TextStyle(
      fontWeight: FontWeight.w300,
      color: Colors.black54,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: AppColors.black,
    ),
    iconTheme: IconThemeData(color: AppColors.black),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF5F5F5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: AppColors.black, width: 1.5),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.black,
    unselectedItemColor: Colors.black54,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: false,
    showUnselectedLabels: false,
  ),
);

