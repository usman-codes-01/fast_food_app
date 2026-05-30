import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color accent = Color(0xFFFFC107);

  static const Color bgLight = Color(0xFFF7F7F9);
  static const Color bgDark = Color(0xFF121212);

  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);

  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFEDEDED);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static const Color statusPending = Color(0xFF1976D2);
  static const Color statusCooking = Color(0xFFFB8C00);
  static const Color statusReady = Color(0xFF2E7D32);
  static const Color statusPickedUp = Color(0xFF616161);
  static const Color danger = Color(0xFFE53935);
}

class AppSizes {
  AppSizes._();

  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  static const double padSm = 8;
  static const double padMd = 16;
  static const double padLg = 24;
}

class AppStrings {
  AppStrings._();

  static const String appName = "Campus Bites";
  static const String adminEmail = "admin@canteen.com";

  static const List<String> categories = [
    "All",
    "Burgers",
    "Pizza",
    "Rice",
    "Drinks",
    "Snacks",
  ];
}
