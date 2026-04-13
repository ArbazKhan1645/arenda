import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Primary Teal ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color primarySurface = Color(0xFFF0FDFA);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF1F5F9);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color star = Color(0xFFFFB800);

  // ── Overlay ────────────────────────────────────────────────────────────────
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x33000000);

  // ── Shimmer ────────────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);

  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF1E293B);
}
