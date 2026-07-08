import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themePrefsKey = 'app_user_theme_mode';

  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.dark; // Default to dark mode
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themePrefsKey);
    if (saved != null) {
      state = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefsKey, newMode == ThemeMode.light ? 'light' : 'dark');
  }
}

class AppTheme {
  AppTheme._();

  // SevaFind Figma Color Palette
  static const Color primaryColor = Color(0xFFF97316);   // Brand Orange
  static const Color accentColor = Color(0xFFEA580C);    // Brand Orange Dark
  static const Color secondaryColor = Color(0xFFEA580C); // Secondary same as accent for simplicity
  
  // Dark Theme specifics
  static const Color darkBg = Color(0xFF12121A);
  static const Color darkHeaderStart = Color(0xFF1E1230);
  static const Color darkHeaderEnd = Color(0xFF12121A);
  static const Color darkCard = Color(0x0AFFFFFF);      // rgba(255,255,255,0.04)
  static const Color darkInput = Color(0x12FFFFFF);     // rgba(255,255,255,0.07)
  static const Color darkBorder = Color(0x12FFFFFF);    // rgba(255,255,255,0.07)
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  static const Color darkTextMuted = Color(0x59FFFFFF);     // rgba(255,255,255,0.35)
  static const Color darkNavBg = Color(0xF712121A);     // rgba(18,18,26,0.97)

  // Light Theme specifics
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightHeaderStart = Color(0xFFFFF7F0);
  static const Color lightHeaderEnd = Color(0xFFF5F5F7);
  static const Color lightCard = Colors.white;
  static const Color lightInput = Color(0x0D000000);    // rgba(0,0,0,0.05)
  static const Color lightBorder = Color(0x12000000);   // rgba(0,0,0,0.07)
  static const Color lightTextPrimary = Color(0xFF111118);
  static const Color lightTextSecondary = Color(0xFF444450);
  static const Color lightTextMuted = Color(0xFF8888A0);
  static const Color lightNavBg = Color(0xF7FAFAFC);    // rgba(250,250,252,0.97)

  // Glassmorphic Decoration Utility to match Figma Card styles
  static BoxDecoration glassDecoration({
    required bool isDark,
    double opacity = -1.0, // Default triggers correct theme value
    double borderRadius = 18.0,
    Color? borderColor,
  }) {
    final double computedOpacity = opacity >= 0 ? opacity : (isDark ? 0.04 : 1.0);
    return BoxDecoration(
      color: isDark 
          ? Colors.white.withOpacity(computedOpacity) 
          : Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? (isDark 
            ? Colors.white.withOpacity(0.07) 
            : Colors.black.withOpacity(0.07)),
        width: 1.0,
      ),
      boxShadow: isDark 
          ? [] 
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  // Linear Gradient for premium buttons & accents from Figma
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Common Button Style helper
  static ButtonStyle premiumButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
      padding: EdgeInsets.zero,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  // Light Theme
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        tertiary: const Color(0xFF34D399),
        surface: lightCard,
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: lightBg,
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          fontFamily: 'Outfit',
        ),
        iconTheme: IconThemeData(color: lightTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        labelStyle: const TextStyle(color: lightTextSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: lightTextMuted, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        disabledColor: const Color(0xFFF3F4F6),
        selectedColor: const Color(0xFFFFF7F0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: lightBorder, width: 1),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: accentColor,
        tertiary: const Color(0xFF34D399),
        surface: darkBg,
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: darkBg,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          fontFamily: 'Outfit',
        ),
        iconTheme: IconThemeData(color: darkTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: darkTextMuted, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        disabledColor: Colors.white.withOpacity(0.02),
        selectedColor: Colors.white.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    );
  }
}
