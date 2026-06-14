import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
          fontSize: 30,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
          fontSize: 24,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textDark,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textGray,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}
