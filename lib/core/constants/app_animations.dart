import 'package:flutter/material.dart';

class AppAnimations {
  // Standard durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideInCurve = Curves.easeOutCubic;
  static const Curve fadeInCurve = Curves.easeInQuad;
  
  // Hero animation
  static const Duration heroAnimationDuration = Duration(milliseconds: 300);
  
  // Stagger animation delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  
  // Ripple animation
  static const Duration rippleDuration = Duration(milliseconds: 200);
}