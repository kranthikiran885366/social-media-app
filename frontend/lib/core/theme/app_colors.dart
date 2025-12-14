import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Instagram-inspired palette
  static const Color primary = Color(0xFF6C5CE7);        // Purple primary
  static const Color primaryLight = Color(0xFF8B7ED8);   // Light purple
  static const Color primaryDark = Color(0xFF5A4FCF);    // Dark purple
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF6B9D);      // Pink accent
  static const Color secondaryLight = Color(0xFFFF8FB3); // Light pink
  static const Color secondaryDark = Color(0xFFE55A87);  // Dark pink
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF667EEA);  // Blue gradient start
  static const Color gradientEnd = Color(0xFF764BA2);    // Purple gradient end
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);     // Pure white
  static const Color backgroundSecondary = Color(0xFFFAFAFA); // Light gray
  static const Color backgroundTertiary = Color(0xFFF5F5F5);  // Lighter gray
  
  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);        // White surface
  static const Color surfaceVariant = Color(0xFFF8F9FA); // Light surface
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);    // Almost black
  static const Color textSecondary = Color(0xFF6B7280);  // Medium gray
  static const Color textTertiary = Color(0xFF9CA3AF);   // Light gray
  static const Color textDisabled = Color(0xFFD1D5DB);   // Very light gray
  
  // Border Colors
  static const Color border = Color(0xFFE5E7EB);         // Light border
  static const Color borderSecondary = Color(0xFFD1D5DB); // Medium border
  static const Color borderFocus = Color(0xFF6C5CE7);    // Focus border
  
  // Status Colors
  static const Color success = Color(0xFF10B981);        // Green
  static const Color successLight = Color(0xFFD1FAE5);   // Light green
  static const Color warning = Color(0xFFF59E0B);        // Orange
  static const Color warningLight = Color(0xFFFEF3C7);   // Light orange
  static const Color error = Color(0xFFEF4444);          // Red
  static const Color errorLight = Color(0xFFFEE2E2);     // Light red
  static const Color info = Color(0xFF3B82F6);           // Blue
  static const Color infoLight = Color(0xFFDBEAFE);      // Light blue
  
  // Social Colors
  static const Color facebook = Color(0xFF1877F2);       // Facebook blue
  static const Color google = Color(0xFFDB4437);         // Google red
  static const Color apple = Color(0xFF000000);          // Apple black
  static const Color twitter = Color(0xFF1DA1F2);        // Twitter blue
  
  // Interactive Colors
  static const Color like = Color(0xFFFF3040);           // Like red
  static const Color share = Color(0xFF1877F2);          // Share blue
  static const Color comment = Color(0xFF6B7280);        // Comment gray
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);        // Black overlay
  static const Color overlayLight = Color(0x40000000);   // Light overlay
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient storyGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFF6C5CE7), Color(0xFF667EEA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}