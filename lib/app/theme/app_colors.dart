import 'package:flutter/material.dart';

/// Premium color system — dark-first design with glassmorphism & neon accents.
/// All legacy aliases preserved at the bottom for backward compatibility.
abstract final class AppColors {
  // ── Brand / Primary ───────────────────────────────────────────────────────
  static const Color primary       = Color(0xFFFF6B2B); // Vivid Saffron-Orange
  static const Color primaryDark   = Color(0xFFE85510); // Deeper orange press
  static const Color primaryLight  = Color(0xFFFF8C5A); // Lighter orange hover

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent        = Color(0xFF7B75FF); // Electric Indigo
  static const Color accentDark    = Color(0xFF5A53E0);
  static const Color accentLight   = Color(0xFF9D98FF);

  // ── Secondary (legacy indigo, kept for existing references) ───────────────
  static const Color secondary     = Color(0xFF283593);

  // ── Glow Colors (for box shadows) ─────────────────────────────────────────
  static const Color primaryGlow   = Color(0x40FF6B2B); // 25% alpha orange
  static const Color accentGlow    = Color(0x407B75FF); // 25% alpha indigo
  static const Color successGlow   = Color(0x3300E676);
  static const Color errorGlow     = Color(0x33FF4757);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success       = Color(0xFF00C853);
  static const Color successDark   = Color(0xFF00E676); // Neon green (dark mode)
  static const Color error         = Color(0xFFFF3D57);
  static const Color errorAlt      = Color(0xFFFF4757);
  static const Color warning       = Color(0xFFFFD600);
  static const Color warningDark   = Color(0xFFFFD60A);
  static const Color info          = Color(0xFF29B6F6);

  // ── Backgrounds — Light ───────────────────────────────────────────────────
  static const Color backgroundLight      = Color(0xFFF5F7FA);
  static const Color surfaceLight         = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFFAFAFA);
  static const Color cardLight            = Color(0xFFFFFFFF);

  // ── Backgrounds — Dark ────────────────────────────────────────────────────
  static const Color backgroundDark      = Color(0xFF0D0F14); // Deep near-black
  static const Color surfaceDark         = Color(0xFF1A1D26); // Card surface
  static const Color surfaceElevatedDark = Color(0xFF21263A); // Modal/elevated
  static const Color cardDark            = Color(0xFF1E2130); // Slightly warm card

  // ── Text — Light ──────────────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textHintLight      = Color(0xFFADB5BD);
  static const Color textDisabledLight  = Color(0xFFCED4DA);

  // ── Text — Dark ───────────────────────────────────────────────────────────
  static const Color textPrimaryDark    = Color(0xFFF0F2FF);
  static const Color textSecondaryDark  = Color(0xFF8B93A5);
  static const Color textHintDark       = Color(0xFF4A5168);
  static const Color textDisabledDark   = Color(0xFF343A50);

  // ── Text always ───────────────────────────────────────────────────────────
  static const Color textOnPrimary      = Color(0xFFFFFFFF);
  static const Color textOnDark         = Color(0xFFFFFFFF);

  // ── Borders / Dividers — Light ────────────────────────────────────────────
  static const Color borderLight        = Color(0xFFE5E7EB);
  static const Color dividerLight       = Color(0xFFF3F4F6);

  // ── Borders / Dividers — Dark ─────────────────────────────────────────────
  // Use with .withOpacity in code for glassmorphism
  static const Color borderDark         = Color(0x14FFFFFF); // 8% white
  static const Color dividerDark        = Color(0x0AFFFFFF); // 4% white
  static const Color borderDarkStrong   = Color(0x29FFFFFF); // 16% white

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  static const Color navSelected        = Color(0xFFFF6B2B);
  static const Color navUnselectedLight = Color(0xFF9E9E9E);
  static const Color navUnselectedDark  = Color(0xFF4A5168);
  static const Color navBgLight         = Color(0xFFFFFFFF);
  static const Color navBgDark          = Color(0xFF1A1D26);

  // ── Quiz Specific ─────────────────────────────────────────────────────────
  static const Color correctBg          = Color(0xFF0D3321); // Dark green bg
  static const Color correctBgLight     = Color(0xFFE8F5E9);
  static const Color wrongBg            = Color(0xFF3A0D12); // Dark red bg
  static const Color wrongBgLight       = Color(0xFFFFEBEE);
  static const Color timerNormal        = Color(0xFFFF6B2B);
  static const Color timerWarning       = Color(0xFFFFD600);
  static const Color timerDanger        = Color(0xFFFF3D57);
  static const Color optionNormalDark   = Color(0xFF21263A);
  static const Color optionNormalLight  = Color(0xFFFFFFFF);

  // ── Gradients (begin/end stops) ───────────────────────────────────────────
  static const Color gradOrangeStart    = Color(0xFFFF6B2B);
  static const Color gradOrangeEnd      = Color(0xFFFFAB40);
  static const Color gradIndigoStart    = Color(0xFF7B75FF);
  static const Color gradIndigoEnd      = Color(0xFF9D98FF);
  static const Color gradDarkStart      = Color(0xFF0D0F14);
  static const Color gradDarkEnd        = Color(0xFF1A1D26);
  static const Color gradHeroStart      = Color(0xFF1A0A2E); // Deep purple-dark
  static const Color gradHeroEnd        = Color(0xFF0D0F14);

  // ── Difficulty Colors ─────────────────────────────────────────────────────
  static const Color diffEasy     = Color(0xFF00C853);
  static const Color diffMedium   = Color(0xFFFFD600);
  static const Color diffHard     = Color(0xFFFF6B2B);
  static const Color diffExpert   = Color(0xFFFF3D57);

  // ── Module / Topic Colors (for Learn tab modules) ─────────────────────────
  static const Color module1Color = Color(0xFFFF6B2B); // Number Foundations
  static const Color module2Color = Color(0xFF29B6F6); // Geometry & Trig
  static const Color module3Color = Color(0xFF00C853); // Arithmetic Formulas
  static const Color module4Color = Color(0xFF7B75FF); // Advanced Topics
  static const Color module5Color = Color(0xFFFFD600); // Quick Reference

  // ─────────────────────────────────────────────────────────────────────────
  // LEGACY ALIASES — kept for backward compatibility with existing code
  // ─────────────────────────────────────────────────────────────────────────
  static const Color background         = backgroundLight;
  static const Color textPrimary        = textPrimaryLight;
  static const Color textSecondary      = textSecondaryLight;
  static const Color textHint           = textHintLight;
  static const Color border             = borderLight;
  static const Color divider            = dividerLight;
  static const Color navUnselected      = navUnselectedLight;
  static const Color lightBlue          = Color(0xFFFFF3E0); // warm peach bg
  static const Color paleBlueBg         = Color(0xFFFFF3E0);
  static const Color secondaryBlue      = secondary;
  static const Color lightWarmBg        = Color(0xFFFFF3E0);
}
