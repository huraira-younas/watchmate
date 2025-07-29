import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenHeight => screenSize.height;
  double get screenWidth => screenSize.width;

  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  void unfocus() => FocusScope.of(this).unfocus();
}
