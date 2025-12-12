// lib/main/utils/dynamic_theme.dart
import 'package:flutter/material.dart';

class ColorUtils {
  static Color? themeColor;
  static Color? _colorPrimary;
  static Color? _colorPrimaryLight;
  static Color? _borderColor;
  static Color? _bottomNavigationColor;
  static Color? _scaffoldSecondaryDark;
  static Color? _scaffoldColorDark;
  static Color? _scaffoldColorLight;
  static Color? _appButtonColorDark;
  static Color? _dividerColor;
  static Color? _cardDarkColor;

  ColorUtils({String primaryHex = "FF573391"}) {
    themeColor = colorFromHex(primaryHex);
    _colorPrimary = colorFromHex(primaryHex);

    _initializeColors();
  }

  void _initializeColors() {
    _colorPrimaryLight = const Color(0xFFF5F5F5);
    _borderColor = const Color(0xFFEAEAEA);
    _scaffoldSecondaryDark = const Color(0xFF1E1E1E);
    _scaffoldColorDark = const Color(0xFF090909);
    _scaffoldColorLight = Colors.white;
    _appButtonColorDark = const Color(0xFF282828);
    _dividerColor = const Color(0xFFD3D3D3);
    _cardDarkColor = const Color(0xFF2F2F2F);
    _bottomNavigationColor = bottomNavigationBarColor("6b7cff");
  }

  static void updateColors(String color) {
    themeColor = colorFromHex(color);
    _colorPrimary = colorFromHex(color);
    _colorPrimaryLight = const Color(0xFFF5F5F5);
    _borderColor = const Color(0xFFEAEAEA);
    _scaffoldSecondaryDark = const Color(0xFF1E1E1E);
    _scaffoldColorDark = const Color(0xFF090909);
    _scaffoldColorLight = Colors.white;
    _appButtonColorDark = const Color(0xFF282828);
    _dividerColor = const Color(0xFFD3D3D3);
    _cardDarkColor = const Color(0xFF2F2F2F);
    _bottomNavigationColor = bottomNavigationBarColor(color);
  }

  static Color colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static Color bottomNavigationBarColor(String color) {
    final String convertedColor = color.replaceAll("#", "");
    final Color baseColor = ColorUtils.colorFromHex(convertedColor);
    final double lightenPercent = 90.0;

    final Color hoverColor = lightenColor(baseColor, lightenPercent);

    debugPrint('Original Color (from hex): $baseColor');
    debugPrint('Lightened Color: $hoverColor');
    return hoverColor;
  }

  static Color lightenColor(Color color, double percent) {
    final double p = percent / 100.0;

    final int r = (color.red + ((255 - color.red) * p)).round().clamp(0, 255);
    final int g = (color.green + ((255 - color.green) * p)).round().clamp(0, 255);
    final int b = (color.blue + ((255 - color.blue) * p)).round().clamp(0, 255);

    return Color.fromARGB(color.alpha, r, g, b);
  }

  static Color get colorPrimary => _colorPrimary ?? const Color(0xFFBB2548);
  static Color get colorPrimaryLight => _colorPrimaryLight ?? const Color(0xFFF5F5F5);
  static Color get borderColor => _borderColor ?? const Color(0xFFEAEAEA);
  static Color get bottomNavigationColor => _bottomNavigationColor ?? const Color(0xFFD6CDE4);
  static Color get scaffoldSecondaryDark => _scaffoldSecondaryDark ?? const Color(0xFF1E1E1E);
  static Color get scaffoldColorDark => _scaffoldColorDark ?? const Color(0xFF090909);
  static Color get scaffoldColorLight => _scaffoldColorLight ?? Colors.white;
  static Color get appButtonColorDark => _appButtonColorDark ?? const Color(0xFF282828);
  static Color get dividerColor => _dividerColor ?? const Color(0xFFD3D3D3);
  static Color get cardDarkColor => _cardDarkColor ?? Colors.black;
}
