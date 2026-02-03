import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🎨 Rased Light Palette
class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF2ECC71); // Rased Green
  static const Color primaryDark = Color(0xFF27AE60);

  // Backgrounds
  static const Color background = Color(
    0xFFF8F9FA,
  ); // Light Grey (Like the image)
  static const Color surface = Colors.white; // Pure White for Cards

  // Text Colors
  static const Color textBlack = Color(
    0xFF1E293B,
  ); // Dark Blue-Grey for headings
  static const Color textGrey = Color(0xFF64748B); // Slate Grey for subtitles
  static const Color textLight = Colors.white; // For buttons

  // Feedback
  static const Color error = Color(0xFFEF4444);
  static const Color success = primaryGreen;
}

class AppTheme {
  // ☀️ Rased Light Theme (The Default)
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryGreen,
        surface: Color(0xFFF3F4F6),
        onSurface: Color(0xFF1F2937),
        onPrimary: AppColors.textLight,
        error: AppColors.error,
      ),

      // Text Theme (Cairo) - Black & Grey
      textTheme: GoogleFonts.cairoTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          color: AppColors.textBlack,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(color: AppColors.textBlack, fontSize: 16),
        bodyMedium: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        bodySmall: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),

      // AppBar Theme (Clean White or Transparent)
      appBarTheme: const AppBarTheme(
        backgroundColor:
            Colors.transparent, // Or AppColors.surface if you want a white bar
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textBlack),
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          color: AppColors.textBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme (White with soft shadow)
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ), // Very subtle border
        ),
        margin: const EdgeInsets.only(bottom: 16),
      ),

      // Input Decoration (Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.textGrey),
        labelStyle: const TextStyle(color: AppColors.textGrey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),

      // ElevatedButton Theme (Green)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      // OutlinedButton Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      // Dialog & BottomSheet Theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.primaryGreen),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
    );
  }

  // Compatibility getters
  static const Color primaryColor = AppColors.primaryGreen;
  static const Color textSecondary = AppColors.textGrey;
  static const Color textPrimary = AppColors.textBlack;
  static const Color error = AppColors.error;
  static const Color success = AppColors.success;

  // Use Light Theme by default
  static ThemeData get rasedTheme => lightTheme;
}
