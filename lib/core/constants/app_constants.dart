import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const accent = Color(0xFF8B5CF6);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Neutral Light
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);

  // Neutral Dark
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF334155);
  static const darkBorder = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);

  // Group colors
  static const groupColors = [
    Color(0xFF6366F1),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
  ];
}

class AppSizes {
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 12;
  static const double paddingL = 16;
  static const double paddingXL = 20;
  static const double paddingXXL = 24;

  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;

  static const double iconS = 16;
  static const double iconM = 20;
  static const double iconL = 24;
  static const double iconXL = 32;

  static const double navBarHeight = 72;
  static const double appBarHeight = 60;
}

class AppStrings {
  static const appName = 'منظم دروسك';
  static const appSlogan = 'نظّم دروسك ... نجاح طلابك';

  // Nav
  static const navHome = 'الرئيسية';
  static const navStudents = 'الطلاب';
  static const navExams = 'الاختبارات';
  static const navPayments = 'المدفوعات';
  static const navMore = 'المزيد';

  // Grades
  static const List<String> defaultGrades = [
    'أولى إعدادي',
    'ثانية إعدادي',
    'ثالثة إعدادي',
    'أولى ثانوي',
    'ثانية ثانوي',
    'ثالثة ثانوي',
  ];

  // Student statuses
  static const Map<String, String> studentStatuses = {
    'active': 'نشط',
    'paused': 'متوقف مؤقتاً',
    'withdrawn': 'منسحب',
    'deferred': 'مؤجل',
    'graduated': 'متخرج',
    'archived': 'مؤرشف',
  };

  // Attendance statuses
  static const Map<String, String> attendanceStatuses = {
    'present': 'حاضر',
    'absent': 'غائب',
    'late': 'متأخر',
    'excused': 'بإذن',
  };

  // Reservation statuses
  static const Map<String, String> reservationStatuses = {
    'new': 'جديد',
    'contacted': 'تم التواصل',
    'registered': 'تم التسجيل',
    'cancelled': 'ملغي',
  };

  // Study types
  static const Map<String, String> studyTypes = {
    'general': 'عام',
    'azhari': 'أزهري',
    'baccalaureate': 'بكالوريا',
  };

  // Days of week
  static const List<String> daysOfWeek = [
    'السبت', 'الأحد', 'الاثنين', 'الثلاثاء',
    'الأربعاء', 'الخميس', 'الجمعة',
  ];
}
