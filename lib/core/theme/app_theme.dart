import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const String _fontFamily = 'Cairo';

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: _fontFamily,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
          hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w400),
          labelStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXXL, vertical: AppSizes.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          labelStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingS, vertical: 2),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w800),
          headlineLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
          labelMedium: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
          labelSmall: TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w600),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: _fontFamily,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.accent,
          surface: AppColors.darkSurface,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTextPrimary,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL, vertical: AppSizes.paddingM),
          hintStyle: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w400),
          labelStyle: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXXL, vertical: AppSizes.paddingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.darkTextSecondary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
              fontFamily: _fontFamily, fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(
              fontFamily: _fontFamily, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      );
}
