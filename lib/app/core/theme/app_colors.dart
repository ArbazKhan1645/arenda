import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Primary Red (Brand) ───────────────────────────────────────────────────
  static const Color primary     = Color(0xFFE9483D);
  static const Color primaryDark = Color(0xFFC73D34);
  static const Color primaryLight   = Color(0xFFFFD6D4);
  static const Color primarySurface = Color(0xFFFFF5F5);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color background      = Color(0xFFFFFFFF);
  static const Color surface         = Color(0xFFF2F2F1);
  static const Color surfaceVariant  = Color(0xFFEAEAE9);
  static const Color textPrimary     = Color(0xFF1E1E1C);
  static const Color textSecondary   = Color(0xFF6B6B68);
  static const Color textTertiary    = Color(0xFF9E9E9B);
  static const Color border          = Color(0xFFE0E0DF);
  static const Color divider         = Color(0xFFEAEAE9);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error        = Color(0xFFEF4444);
  static const Color errorLight   = Color(0xFFFEE2E2);
  static const Color success      = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color star         = Color(0xFFFFB800);

  // ── Overlay ────────────────────────────────────────────────────────────────
  static const Color overlay      = Color(0x80000000);
  static const Color overlayLight = Color(0x33000000);

  // ── Shimmer ────────────────────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFFE5E5E4);
  static const Color shimmerHighlight = Color(0xFFF2F2F1);

  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color darkBackground    = Color(0xFF1E1E1C);
  static const Color darkSurface       = Color(0xFF2A2A28);
  static const Color darkSurfaceVariant= Color(0xFF383836);
  static const Color darkTextPrimary   = Color(0xFFF2F2F1);
  static const Color darkTextSecondary = Color(0xFF9E9E9B);
  static const Color darkTextTertiary  = Color(0xFF6B6B68);
  static const Color darkBorder        = Color(0xFF3A3A38);
  static const Color darkDivider       = Color(0xFF2A2A28);
}
