import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Card text styles
  static TextStyle cardTitle = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle cardSubtitle = GoogleFonts.notoSans(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle cardContent = GoogleFonts.notoSans(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Flashcard text styles
  static TextStyle stepText = GoogleFonts.notoSans(
    fontSize: 16,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle stepNumber = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryColor,
  );

  // Category chip styles
  static TextStyle chipText = GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle chipTextSelected = GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Recipe name styles
  static TextStyle recipeNameLarge = GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle recipeNameMedium = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // App bar styles
  static TextStyle appBarTitle = GoogleFonts.notoSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Progress text
  static TextStyle progressText = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Empty state styles
  static TextStyle emptyStateTitle = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle emptyStateDescription = GoogleFonts.notoSans(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}