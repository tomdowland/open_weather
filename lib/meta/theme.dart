import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue.shade500,
  hintColor: Colors.blueGrey.shade300,
  cardColor: Colors.blue.shade100,
  // Define additional light theme properties here
);
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey.shade800,
  hintColor: Colors.grey.shade200,
  cardColor: Colors.grey.shade600,
  // Define additional dark theme properties here
);
