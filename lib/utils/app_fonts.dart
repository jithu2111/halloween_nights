import 'package:flutter/material.dart';

class AppFonts {
  static TextStyle creepster({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'serif',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
      fontStyle: fontStyle,
      shadows: [
        Shadow(
          offset: const Offset(1, 1),
          blurRadius: 2,
          color: Colors.black.withOpacity(0.5),
        ),
      ],
    );
  }

  static TextStyle roboto({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: 'sans-serif',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
  }
}