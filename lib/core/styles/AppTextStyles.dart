import 'package:flutter/material.dart';
import 'AppColors.dart';

class AppTextStyles {
  // ───────── Titles ─────────
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle largeTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // ───────── Subtitles ─────────
  static TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary.withOpacity(0.8),
  );

  static TextStyle description = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary.withOpacity(0.7),
  );

  // ───────── Form Labels ─────────
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle hint = TextStyle(
    fontSize: 15,
    color: AppColors.textLight,
  );

  // ───────── Buttons ─────────
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // ───────── Links ─────────
  static const TextStyle link = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    fontSize: 16,
  );

  static const TextStyle underlineLink = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
    decoration: TextDecoration.underline,
  );
}