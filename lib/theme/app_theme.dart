import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const primary = Color(0xFF6C3CE1);       // vivid purple
  static const primaryDark = Color(0xFF4A1DA3);
  static const secondary = Color(0xFFEC4899);      // hot pink
  static const accent = Color(0xFFF97316);         // orange
  static const teal = Color(0xFF0D9488);
  static const green = Color(0xFF10B981);
  static const yellow = Color(0xFFF59E0B);
  static const blue = Color(0xFF3B82F6);
  static const red = Color(0xFFEF4444);

  // Gradients
  static const gradientPurplePink = LinearGradient(
    colors: [Color(0xFF6C3CE1), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientOrangeYellow = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientTealBlue = LinearGradient(
    colors: [Color(0xFF0D9488), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientGreenTeal = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientPinkOrange = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientBackground = LinearGradient(
    colors: [Color(0xFFF3F0FF), Color(0xFFFCE7F3), Color(0xFFEFF6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surfaces
  static const surface = Color(0xFFFAF9FF);
  static const cardBg = Colors.white;

  // Design tokens — used across all screens for consistency
  static const kScaffoldBg = Color(0xFFF5F3FF);
  static const kCardRadius = 18.0;
  static const kSheetBg = Color(0xFFF5F3FF);
  static const kAppBarHeight = 160.0;
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          displayLarge: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          displayMedium: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          headlineLarge: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          headlineMedium: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.nunito(fontWeight: FontWeight.w500),
          bodyMedium: GoogleFonts.nunito(fontWeight: FontWeight.w400),
          labelLarge: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          shadowColor: AppColors.primary.withValues(alpha: 0.08),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
          shape: StadiumBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.nunito(
                fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary);
            }
            return GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return IconThemeData(color: Colors.grey.shade500, size: 22);
          }),
        ),
      );
}
