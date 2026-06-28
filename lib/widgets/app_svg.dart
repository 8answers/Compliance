import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Loads SVG assets exported from Figma with reliable fallbacks.
class AppSvg extends StatelessWidget {
  const AppSvg({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );

    return picture;
  }
}
