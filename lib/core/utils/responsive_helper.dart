import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;
  
  // Grid columns
  static int getGridColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      // Mobile: 2 columns
      return 2;
    } else if (screenWidth < tabletBreakpoint) {
      // Tablet portrait: 3 columns
      return 3;
    } else {
      // Tablet landscape/Desktop: 4 columns
      return 4;
    }
  }
  
  // Card aspect ratio
  static double getCardAspectRatio(BuildContext context) {
    return 1.0; // Square cards as specified
  }
  
  // Grid spacing
  static double getGridSpacing(BuildContext context) {
    return 12.0;
  }
  
  // Screen padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    return const EdgeInsets.all(16.0);
  }
  
  // Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  // Check if device is tablet
  static bool isTablet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
  }
  
  // Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  // Get font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return baseFontSize * 0.9;
    } else if (screenWidth < tabletBreakpoint) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }
  
  // Get icon size based on screen size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return baseIconSize * 0.9;
    } else if (screenWidth < tabletBreakpoint) {
      return baseIconSize;
    } else {
      return baseIconSize * 1.2;
    }
  }
}