import 'package:flutter/material.dart';

abstract final class AppColors {
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const green = Color(0xFF00A24D);
  static const searchBackground = Color(0xFF292929);
  static const recentLabel = Color(0xFFCCCCCC);
  static const searchPlaceholder = Color(0x52FFFFFF);
  static const navBackground = Color(0x29FFFFFF);
}

abstract final class AppLayout {
  static const designWidth = 390.0;
  static const horizontalPadding = 16.04;
}

double designScale(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= AppLayout.designWidth) {
    return 1;
  }
  return width / AppLayout.designWidth;
}
