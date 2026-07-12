import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografía de PromApp — Premium Dark Edition.
///
/// - **Space Grotesk** → títulos y números destacados (headings / display).
/// - **Inter**         → cuerpo, labels y textos secundarios.
class AppTypography {
  AppTypography._();

  static const String headingFont = 'SpaceGrotesk';
  static const String bodyFont = 'Inter';

  // --- Display / números grandes (ej: "5.9", "85%") ---
  static TextStyle get display => const TextStyle(
    fontFamily: headingFont,
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1,
  );

  // --- Títulos ---
  static TextStyle get h1 => const TextStyle(
    fontFamily: headingFont,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get h2 => const TextStyle(
    fontFamily: headingFont,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get h3 => const TextStyle(
    fontFamily: headingFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // --- Cuerpo (Inter) ---
  static TextStyle get body => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyBold => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySecondary => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --- Labels / caption ---
  static TextStyle get label => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static TextStyle get caption => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.2,
  );

  static TextStyle get captionUppercase => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 1.0,
  );

  // --- Botones ---
  static TextStyle get button => const TextStyle(
    fontFamily: bodyFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // --- Número grande de nota ---
  static TextStyle get notaGrande => const TextStyle(
    fontFamily: headingFont,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -2,
  );
}
