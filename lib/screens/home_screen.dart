import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import 'terms_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const _logoWidth = 260.439;
  static const _logoHeight = 54.0;
  static const _subtitleFontSize = 24.0;
  static const _logoToSubtitleGap = 8.0;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 5), _goToTermsScreen);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _goToTermsScreen() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TermsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final logoWidth = HomeScreen._logoWidth * scale;
    final logoHeight = HomeScreen._logoHeight * scale;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/whatihadinfogreen.svg',
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: HomeScreen._logoToSubtitleGap * scale),
                  Text(
                    'Compliance',
                    style: GoogleFonts.nataSans(
                      fontSize: HomeScreen._subtitleFontSize * scale,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: HomeIndicator(scale: scale),
            ),
          ],
        ),
      ),
    );
  }
}
