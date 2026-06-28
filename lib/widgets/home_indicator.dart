import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Container(
        width: 134 * scale,
        height: 5 * scale,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
