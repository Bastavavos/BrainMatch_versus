import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF151D53);
  static const Color accent = Color(0xFFFAC710);
  static const Color background = Color(0xFFF1F6FD);
  static const Color light = Color(0xFFFDEEB7);
  static const Color secondaryAccent = Color(0xFF4353FF);
}

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.light,
    secondary: AppColors.accent,
    onSecondary: Colors.black,
    tertiary: AppColors.secondaryAccent,
    onTertiary: AppColors.light,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.secondaryAccent,
    ),
  ),
);
