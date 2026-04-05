import 'package:flutter/material.dart';
import '../models/plant_model.dart';

// ── Theme data model ──────────────────────────────────────────────────────────

class PlantThemeData {
  final String name;
  final String emoji;
  final List<Color> gradient;      // header gradient
  final Color primary;
  final Color primaryLight;
  final Color bg;
  final Color surface;
  final Color border;
  final Color accent;              // soft tint bg (like bgGreen)
  final Color textDark;
  final Color textMuted;
  final bool isDark;

  const PlantThemeData({
    required this.name,
    required this.emoji,
    required this.gradient,
    required this.primary,
    required this.primaryLight,
    required this.bg,
    required this.surface,
    required this.border,
    required this.accent,
    required this.textDark,
    required this.textMuted,
    this.isDark = false,
  });

  ThemeData get materialTheme => ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: bg,
        brightness: isDark ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: primary,
          onPrimary: Colors.white,
          secondary: primaryLight,
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          surface: surface,
          onSurface: textDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: isDark ? Colors.white : textDark,
          titleTextStyle: TextStyle(
            color: isDark ? Colors.white : textDark,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            letterSpacing: -0.5,
          ),
        ),
        dialogBackgroundColor: surface,
      );
}

// ── 8 built-in themes ─────────────────────────────────────────────────────────

class AppThemes {
  static const List<PlantThemeData> all = [
    // 0 — Forest (default)
    PlantThemeData(
      name: 'Forest',
      emoji: '🌿',
      gradient: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF52B788)],
      primary: Color(0xFF2D6A4F),
      primaryLight: Color(0xFF40916C),
      bg: Color(0xFFF8FDF9),
      surface: Colors.white,
      border: Color(0xFFB7E4C7),
      accent: Color(0xFFD8F3DC),
      textDark: Color(0xFF1A3C2E),
      textMuted: Color(0xFF6B8F71),
    ),
    // 1 — Sunset
    PlantThemeData(
      name: 'Sunset',
      emoji: '🌅',
      gradient: [Color(0xFFB5330F), Color(0xFFE8603C), Color(0xFFF4A261)],
      primary: Color(0xFFD04A1E),
      primaryLight: Color(0xFFE8603C),
      bg: Color(0xFFFFF8F5),
      surface: Colors.white,
      border: Color(0xFFFFCCB3),
      accent: Color(0xFFFFE8D6),
      textDark: Color(0xFF3D1A0A),
      textMuted: Color(0xFFA0522D),
    ),
    // 2 — Ocean
    PlantThemeData(
      name: 'Ocean',
      emoji: '🌊',
      gradient: [Color(0xFF023E8A), Color(0xFF0077B6), Color(0xFF48CAE4)],
      primary: Color(0xFF0077B6),
      primaryLight: Color(0xFF0096C7),
      bg: Color(0xFFF0F8FF),
      surface: Colors.white,
      border: Color(0xFFADE8F4),
      accent: Color(0xFFCAF0F8),
      textDark: Color(0xFF03045E),
      textMuted: Color(0xFF0077B6),
    ),
    // 3 — Lavender
    PlantThemeData(
      name: 'Lavender',
      emoji: '💜',
      gradient: [Color(0xFF4A0E78), Color(0xFF7B2D8B), Color(0xFFC77DFF)],
      primary: Color(0xFF7B2D8B),
      primaryLight: Color(0xFF9D4EDD),
      bg: Color(0xFFFAF5FF),
      surface: Colors.white,
      border: Color(0xFFD4AAFF),
      accent: Color(0xFFEDD9FF),
      textDark: Color(0xFF2D0045),
      textMuted: Color(0xFF7B2D8B),
    ),
    // 4 — Desert
    PlantThemeData(
      name: 'Desert',
      emoji: '🏜️',
      gradient: [Color(0xFF7D4C1A), Color(0xFFB5651D), Color(0xFFD4A574)],
      primary: Color(0xFFB5651D),
      primaryLight: Color(0xFFCD853F),
      bg: Color(0xFFFDF8F2),
      surface: Colors.white,
      border: Color(0xFFE8C99A),
      accent: Color(0xFFF4E1C1),
      textDark: Color(0xFF3D1F00),
      textMuted: Color(0xFF8B6340),
    ),
    // 5 — Midnight (dark)
    PlantThemeData(
      name: 'Midnight',
      emoji: '🌙',
      gradient: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF16213E)],
      primary: Color(0xFF52B788),
      primaryLight: Color(0xFF74C69D),
      bg: Color(0xFF0F0F1A),
      surface: Color(0xFF1E1E2E),
      border: Color(0xFF2D2D45),
      accent: Color(0xFF1A2E22),
      textDark: Color(0xFFE8F5E9),
      textMuted: Color(0xFF74C69D),
      isDark: true,
    ),
    // 6 — Cherry
    PlantThemeData(
      name: 'Cherry',
      emoji: '🌸',
      gradient: [Color(0xFF8B0A35), Color(0xFFD63060), Color(0xFFFF758C)],
      primary: Color(0xFFD63060),
      primaryLight: Color(0xFFFF758C),
      bg: Color(0xFFFFF5F7),
      surface: Colors.white,
      border: Color(0xFFFFB3C1),
      accent: Color(0xFFFFD6E0),
      textDark: Color(0xFF3D0018),
      textMuted: Color(0xFFAD3060),
    ),
    // 7 — Tropical
    PlantThemeData(
      name: 'Tropical',
      emoji: '🌴',
      gradient: [Color(0xFF005F37), Color(0xFF2DC653), Color(0xFFA8E063)],
      primary: Color(0xFF2DC653),
      primaryLight: Color(0xFF57D97A),
      bg: Color(0xFFF4FFF6),
      surface: Colors.white,
      border: Color(0xFFB0F0C0),
      accent: Color(0xFFD4FFE0),
      textDark: Color(0xFF003D20),
      textMuted: Color(0xFF2D8C4E),
    ),
  ];
}

// ── Urgency colors (theme-aware) ──────────────────────────────────────────────

class UrgencyStyle {
  final Color background;
  final Color bar;
  final Color text;

  const UrgencyStyle({
    required this.background,
    required this.bar,
    required this.text,
  });

  static UrgencyStyle of(WaterUrgency urgency) {
    switch (urgency) {
      case WaterUrgency.critical:
        return const UrgencyStyle(
          background: Color(0xFFFFE5E5),
          bar: Color(0xFFE63946),
          text: Color(0xFFC1121F),
        );
      case WaterUrgency.soon:
        return const UrgencyStyle(
          background: Color(0xFFFFF4E0),
          bar: Color(0xFFF4A261),
          text: Color(0xFFE07B1A),
        );
      case WaterUrgency.upcoming:
        return const UrgencyStyle(
          background: Color(0xFFE8F5E9),
          bar: Color(0xFF52B788),
          text: Color(0xFF2D6A4F),
        );
      case WaterUrgency.ok:
        return const UrgencyStyle(
          background: Color(0xFFF0F7F2),
          bar: Color(0xFF95D5B2),
          text: Color(0xFF40916C),
        );
    }
  }
}
