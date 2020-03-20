import 'package:flutter/material.dart';

class CustomColors {

  static const _shoppyBlue = 0xFF2865fe;
  static const _shoppyLightBlue = 0xFF2194f3;

  static const _shoppyGreen = 0xFF004d40;

  static const MaterialColor shoppyBlue = const MaterialColor(
    _shoppyBlue,
    const <int, Color>{
      50:  const Color(_shoppyBlue),
      100: const Color(_shoppyBlue),
      200: const Color(_shoppyBlue),
      300: const Color(_shoppyBlue),
      400: const Color(_shoppyBlue),
      500: const Color(_shoppyBlue),
      600: const Color(_shoppyBlue),
      700: const Color(_shoppyBlue),
      800: const Color(_shoppyBlue),
      900: const Color(_shoppyBlue),
    },
  );

  static const MaterialColor shoppyLightBlue = const MaterialColor(
    _shoppyLightBlue,
    const <int, Color>{
      50:  const Color(0xFFe0e0e0),
      100: const Color(0xFFb3b3b3),
      200: const Color(0xFF808080),
      300: const Color(0xFF4d4d4d),
      400: const Color(0xFF262626),
      500: const Color(_shoppyLightBlue),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

}