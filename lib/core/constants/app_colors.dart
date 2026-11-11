import 'package:flutter/material.dart';

/// ProCV Design System Colors
/// Primary: Navy Blue | Secondary: White | Accent: Blue-Purple
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF0A1628);
  static const Color primaryLight = Color(0xFF1B2A4A);
  static const Color primaryDark = Color(0xFF060E1A);

  // Accent palette
  static const Color accent = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFF6366F1);
  static const Color accentLighter = Color(0xFF818CF8);
  static const Color accentDark = Color(0xFF3730A3);

  // Secondary palette (Blue)
  static const Color secondary = Color(0xFF2563EB);
  static const Color secondaryLight = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF1D4ED8);

  // Neutral palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Status badge colors mapped to CV statuses
  static Color statusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return textTertiary;
      case 'PENDING':
        return warning;
      case 'UNDER_REVIEW':
        return info;
      case 'ASSIGNED':
        return secondary;
      case 'IN_PROGRESS':
        return accentLight;
      case 'SUBMITTED_FOR_REVIEW':
        return accent;
      case 'REVISION_REQUIRED':
        return error;
      case 'APPROVED':
        return success;
      case 'REJECTED':
        return error;
      case 'COMPLETED':
        return success;
      default:
        return textTertiary;
    }
  }

  static Color statusBackgroundColor(String status) {
    switch (status) {
      case 'DRAFT':
        return const Color(0xFFF1F5F9);
      case 'PENDING':
        return warningLight;
      case 'UNDER_REVIEW':
        return infoLight;
      case 'ASSIGNED':
        return const Color(0xFFDBEAFE);
      case 'IN_PROGRESS':
        return const Color(0xFFEEF2FF);
      case 'SUBMITTED_FOR_REVIEW':
        return const Color(0xFFEDE9FE);
      case 'REVISION_REQUIRED':
        return errorLight;
      case 'APPROVED':
        return successLight;
      case 'REJECTED':
        return errorLight;
      case 'COMPLETED':
        return successLight;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  // Sidebar
  static const Color sidebarBackground = primary;
  static const Color sidebarItemHover = Color(0xFF1E293B);
  static const Color sidebarItemActive = accent;
  static const Color sidebarText = Color(0xFFCBD5E1);
  static const Color sidebarTextActive = white;
}

