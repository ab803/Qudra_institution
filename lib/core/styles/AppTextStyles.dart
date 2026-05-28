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

  // This pageTitle style is used for desktop page headers.
  static const TextStyle pageTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  // This pageTitleCompact style is used for tablet and dense dashboard headers.
  static const TextStyle pageTitleCompact = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    height: 1.12,
  );

  // This sectionTitle style is used for card sections and content groups.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // This cardTitle style is used for portal cards and management tiles.
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // This overline style is used for meta labels and compact headings.
  static const TextStyle overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
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

  // This pageDescription style is used for desktop intro text.
  static const TextStyle pageDescription = TextStyle(
    fontSize: 15,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // This body style is used for regular content text in shared widgets.
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // This bodyStrong style is used for emphasized body text.
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
    height: 1.45,
  );

  // This caption style is used for additional supportive text.
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
    height: 1.4,
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

  // This buttonCompact style is used for desktop action buttons.
  static const TextStyle buttonCompact = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
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
