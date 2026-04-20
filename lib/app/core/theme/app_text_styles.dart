import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _fontFamily = 'JosefinSans';

  // ── Display ─────────────────────────────────────────────
  static TextStyle get displayLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get displayMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  ).copyWith(color: AppColors.textPrimary);

  // ── Heading ─────────────────────────────────────────────
  static TextStyle get h1 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get h2 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.35,
    letterSpacing: -0.2,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get h3 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get h4 => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ).copyWith(color: AppColors.textPrimary);

  // ── Body ────────────────────────────────────────────────
  static TextStyle get bodyLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get bodyMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get bodySM => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ).copyWith(color: AppColors.textSecondary);

  static TextStyle get bodyXS => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ).copyWith(color: AppColors.textSecondary);

  // ── Label ───────────────────────────────────────────────
  static TextStyle get labelLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get labelMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get labelSM => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.3,
  ).copyWith(color: AppColors.textSecondary);

  // ── Button ──────────────────────────────────────────────
  static const TextStyle buttonLG = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonMD = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
  );

  // ── Price ───────────────────────────────────────────────
  static TextStyle get priceLG => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
  ).copyWith(color: AppColors.textPrimary);

  static TextStyle get priceMD => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
  ).copyWith(color: AppColors.textPrimary);

  // ── Caption / Misc ──────────────────────────────────────
  static TextStyle get caption => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
  ).copyWith(color: AppColors.textTertiary);

  static TextStyle get link => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    decoration: TextDecoration.underline,
  ).copyWith(color: AppColors.primary, decorationColor: AppColors.primary);
}
