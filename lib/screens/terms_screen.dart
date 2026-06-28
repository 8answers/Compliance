import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import 'welcome_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _titleFontSize = 32.0;
  static const _cardHeight = 56.0;
  static const _cardRadius = 32.0;
  static const _cardGap = 32.0;
  static const _footerGap = 16.0;
  static const _linkIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = AppLayout.horizontalPadding * scale;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 44 * scale),
                          Center(
                            child: Text(
                              'Terms',
                              style: GoogleFonts.borel(
                                fontSize: _titleFontSize * scale,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white,
                                height: 0.9908,
                              ),
                            ),
                          ),
                          SizedBox(height: 32 * scale),
                          _LinkCard(
                            label: 'Terms and Conditions',
                            scale: scale,
                            onTap: () {},
                          ),
                          SizedBox(height: _cardGap * scale),
                          _LinkCard(
                            label: 'Privacy Policy',
                            scale: scale,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _AgreementText(),
                  SizedBox(height: _footerGap * scale),
                  _NextButton(
                    scale: scale,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WelcomeScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 34 * scale),
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

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.label,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final double scale;
  final VoidCallback onTap;

  static const _cardHeight = TermsScreen._cardHeight;
  static const _cardRadius = TermsScreen._cardRadius;
  static const _linkIconSize = TermsScreen._linkIconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(_cardRadius * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius * scale),
        child: SizedBox(
          height: _cardHeight * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.nataSans(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                      height: 1.0,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/images/Terms.svg',
                  width: _linkIconSize * scale,
                  height: _linkIconSize * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgreementText extends StatelessWidget {
  const _AgreementText();

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final baseStyle = GoogleFonts.nataSans(
      fontSize: 16 * scale,
      fontWeight: FontWeight.w500,
      color: AppColors.white,
      height: 1.35,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'By Clicking Next I agree to the '),
            TextSpan(
              text: 'Terms',
              style: baseStyle.copyWith(color: AppColors.green),
            ),
            const TextSpan(
              text:
                  ' and confirm that I am at least 18 years old or using the service under parental control.',
            ),
          ],
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  static const _cardHeight = TermsScreen._cardHeight;
  static const _cardRadius = TermsScreen._cardRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(_cardRadius * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius * scale),
        child: SizedBox(
          height: _cardHeight * scale,
          child: Center(
            child: Text(
              'Next',
              style: GoogleFonts.nataSans(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
