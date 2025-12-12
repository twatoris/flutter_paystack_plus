// ============================================================================
// lib/extensions/decorations.dart (COMPLETE ENHANCED VERSION)
// ============================================================================

import 'package:flutter/material.dart';

import 'constants.dart';
import 'dynamic_theme.dart';
import 'colors.dart';

// ============================================================================
// ORIGINAL DECORATIONS (PRESERVED)
// ============================================================================

/// Returns Radius
BorderRadius radius([double? radius]) {
  return BorderRadius.all(radiusCircular(radius ?? defaultRadius));
}

/// Returns Radius
Radius radiusCircular([double? radius]) {
  return Radius.circular(radius ?? defaultRadius);
}

ShapeBorder dialogShape([double? borderRadius]) {
  return RoundedRectangleBorder(
    borderRadius: radius(borderRadius ?? defaultRadius),
  );
}

/// Returns custom Radius on each side
BorderRadius radiusOnly({
  double? topRight,
  double? topLeft,
  double? bottomRight,
  double? bottomLeft,
}) {
  return BorderRadius.only(
    topRight: radiusCircular(topRight ?? 0),
    topLeft: radiusCircular(topLeft ?? 0),
    bottomRight: radiusCircular(bottomRight ?? 0),
    bottomLeft: radiusCircular(bottomLeft ?? 0),
  );
}

Decoration boxDecorationDefault({
  BorderRadiusGeometry? borderRadius,
  Color? color,
  Gradient? gradient,
  BoxBorder? border,
  BoxShape? shape,
  BlendMode? backgroundBlendMode,
  List<BoxShadow>? boxShadow,
  DecorationImage? image,
}) {
  return BoxDecoration(
    borderRadius: (shape != null && shape == BoxShape.circle) ? null : (borderRadius ?? radius()),
    boxShadow: boxShadow ?? defaultBoxShadow(),
    color: color ?? Colors.white,
    gradient: gradient,
    border: border,
    shape: shape ?? BoxShape.rectangle,
    backgroundBlendMode: backgroundBlendMode,
    image: image,
  );
}

/// Rounded box decoration
Decoration boxDecorationWithRoundedCorners({
  Color? backgroundColor,
  BorderRadius? borderRadius,
  LinearGradient? gradient,
  BoxBorder? border,
  List<BoxShadow>? boxShadow,
  DecorationImage? decorationImage,
  BoxShape boxShape = BoxShape.rectangle,
}) {
  return BoxDecoration(
    color: backgroundColor ?? cardLightColor, // Removed appStore.isDarkMode
    borderRadius: boxShape == BoxShape.circle ? null : (borderRadius ?? radius()),
    gradient: gradient,
    border: border,
    boxShadow: boxShadow,
    image: decorationImage,
    shape: boxShape,
  );
}

/// Box decoration with shadow
Decoration boxDecorationWithShadow({
  Color? backgroundColor,
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
  LinearGradient? gradient,
  BoxBorder? border,
  List<BoxShadow>? boxShadow,
  DecorationImage? decorationImage,
  BoxShape boxShape = BoxShape.rectangle,
  BorderRadius? borderRadius,
}) {
  return BoxDecoration(
    boxShadow: boxShadow ??
        defaultBoxShadow(
          shadowColor: shadowColor,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
    color: backgroundColor ?? cardLightColor, // Removed appStore.isDarkMode
    gradient: gradient,
    border: border,
    image: decorationImage,
    shape: boxShape,
    borderRadius: borderRadius,
  );
}

/// Rounded box decoration with shadow
Decoration boxDecorationRoundedWithShadow(
  int radiusAll, {
  Color? backgroundColor,
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0, 0),
  LinearGradient? gradient,
}) {
  return BoxDecoration(
    boxShadow: defaultBoxShadow(
      shadowColor: shadowColor ?? Colors.grey.withAlpha((0.065 * 255).round()),
      blurRadius: blurRadius ?? defaultBlurRadius,
      spreadRadius: spreadRadius ?? defaultSpreadRadius,
      offset: offset,
    ),
    color: backgroundColor ?? cardLightColor, // Removed appStore.isDarkMode
    gradient: gradient,
    borderRadius: radius(radiusAll.toDouble()),
  );
}

/// Default box shadow
List<BoxShadow> defaultBoxShadow({
  Color? shadowColor,
  double? blurRadius,
  double? spreadRadius,
  Offset offset = const Offset(0.0, 0.0),
}) {
  return [
    BoxShadow(
      color: shadowColor ?? Colors.grey.withAlpha((0.065 * 255).round()),
      blurRadius: blurRadius ?? defaultBlurRadius,
      spreadRadius: spreadRadius ?? defaultSpreadRadius,
      offset: offset,
    )
  ];
}

// ============================================================================
// 🎨 GLASSMORPHISM DECORATIONS (NEW ADDITIONS)
// ============================================================================

/// Glassmorphism preset levels
enum GlassIntensity {
  subtle, // Light blur, high transparency
  medium, // Balanced blur and opacity
  strong, // Heavy blur, more opaque
}

/// 🌟 MAIN GLASSMORPHIC DECORATION
/// Creates a beautiful frosted glass effect with blur
///
/// Usage:
/// ```dart
/// Container(
///   decoration: boxDecorationGlass(
///     context,
///     intensity: GlassIntensity.medium,
///   ),
///   child: YourWidget(),
/// )
/// ```
Decoration boxDecorationGlass(
  BuildContext context, {
  GlassIntensity intensity = GlassIntensity.medium,
  Color? tintColor,
  BorderRadius? borderRadius,
  Border? border,
  List<BoxShadow>? boxShadow,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark; // Fixed
  final brandColor = tintColor ?? ColorUtils.colorPrimary;

  // Define blur and opacity based on intensity
  double whiteOpacity;
  double borderOpacity;

  switch (intensity) {
    case GlassIntensity.subtle:
      whiteOpacity = isDark ? 0.08 : 0.25;
      borderOpacity = isDark ? 0.15 : 0.4;
      break;
    case GlassIntensity.medium:
      whiteOpacity = isDark ? 0.15 : 0.4;
      borderOpacity = isDark ? 0.2 : 0.5;
      break;
    case GlassIntensity.strong:
      whiteOpacity = isDark ? 0.2 : 0.5;
      borderOpacity = isDark ? 0.25 : 0.6;
      break;
  }

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(whiteOpacity),
        Colors.white.withOpacity(whiteOpacity * 0.6),
      ],
    ),
    borderRadius: borderRadius ?? radius(16),
    border: border ??
        Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: 1.5,
        ),
    boxShadow: boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
  );
}

/// 🍎 APPLE-STYLE GLASS DECORATION
/// iOS-inspired glassmorphism with brand color tint
///
/// Usage:
/// ```dart
/// Container(
///   decoration: boxDecorationAppleGlass(context),
///   child: YourWidget(),
/// )
/// ```
Decoration boxDecorationAppleGlass(
  BuildContext context, {
  Color? tintColor,
  BorderRadius? borderRadius,
  double? borderWidth,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark; // Fixed
  final brandColor = tintColor ?? ColorUtils.colorPrimary;

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              brandColor.withOpacity(0.15),
              brandColor.withOpacity(0.08),
              Colors.white.withOpacity(0.05),
            ]
          : [
              Colors.white.withOpacity(0.6),
              brandColor.withOpacity(0.1),
              Colors.white.withOpacity(0.3),
            ],
      stops: const [0.0, 0.5, 1.0],
    ),
    borderRadius: borderRadius ?? radius(16),
    border: Border.all(
      color: brandColor.withOpacity(isDark ? 0.3 : 0.2),
      width: borderWidth ?? 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: brandColor.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

/// ❄️ FROST GLASS DECORATION
/// Subtle frosted effect for overlays and modals
///
/// Usage:
/// ```dart
/// Container(
///   decoration: boxDecorationFrost(context),
///   child: YourWidget(),
/// )
/// ```
Decoration boxDecorationFrost(
  BuildContext context, {
  BorderRadius? borderRadius,
  double? borderWidth,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark; // Fixed

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ]
          : [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.2),
            ],
    ),
    borderRadius: borderRadius ?? radius(16),
    border: Border.all(
      color: Colors.white.withOpacity(isDark ? 0.15 : 0.4),
      width: borderWidth ?? 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// 💎 CRYSTAL GLASS DECORATION
/// Balanced glass effect for cards and containers
///
/// Usage:
/// ```dart
/// Container(
///   decoration: boxDecorationCrystal(context),
///   child: YourWidget(),
/// )
/// ```
Decoration boxDecorationCrystal(
  BuildContext context, {
  Color? tintColor,
  BorderRadius? borderRadius,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark; // Fixed

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.08),
            ]
          : [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.2),
            ],
    ),
    borderRadius: borderRadius ?? radius(16),
    border: Border.all(
      color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// 🌌 ETHEREAL GLASS DECORATION
/// Ultra-subtle glass for backgrounds
///
/// Usage:
/// ```dart
/// Container(
///   decoration: boxDecorationEthereal(context),
///   child: YourWidget(),
/// )
/// ```
Decoration boxDecorationEthereal(
  BuildContext context, {
  BorderRadius? borderRadius,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark; // Fixed

  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              Colors.white.withOpacity(0.08),
              Colors.white.withOpacity(0.03),
            ]
          : [
              Colors.white.withOpacity(0.25),
              Colors.white.withOpacity(0.15),
            ],
    ),
    borderRadius: borderRadius ?? radius(16),
    border: Border.all(
      color: Colors.white.withOpacity(isDark ? 0.15 : 0.4),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ============================================================================
// 🎯 CONTEXT EXTENSIONS FOR QUICK ACCESS
// ============================================================================

/// Extension methods for easy glass effects
extension GlassDecorationExtensions on BuildContext {
  /// Returns a glass decoration with the specified intensity
  BoxDecoration glassDecoration({
    GlassIntensity intensity = GlassIntensity.medium,
    BorderRadius? borderRadius,
    Color? tintColor,
  }) {
    return boxDecorationGlass(
      this,
      intensity: intensity,
      borderRadius: borderRadius,
      tintColor: tintColor,
    ) as BoxDecoration;
  }

  /// Quick access to frosted glass
  BoxDecoration get frostGlass => boxDecorationFrost(this) as BoxDecoration;

  /// Quick access to crystal glass
  BoxDecoration get crystalGlass => boxDecorationCrystal(this) as BoxDecoration;

  /// Quick access to apple glass
  BoxDecoration get appleGlass => boxDecorationAppleGlass(this) as BoxDecoration;

  /// Quick access to ethereal glass
  BoxDecoration get etherealGlass => boxDecorationEthereal(this) as BoxDecoration;
}
