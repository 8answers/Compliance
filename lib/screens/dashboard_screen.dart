import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/app_svg.dart';
import '../widgets/home_indicator.dart';
import 'new_inspection_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _headerHeight = 64.0;
  static const _searchHeight = 48.0;
  static const _buttonHeight = 56.0;
  static const _buttonRadius = 32.0;
  static const _navBarWidth = 172.0;
  static const _fabHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = AppLayout.horizontalPadding * scale;

    void openNewInspection() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const NewInspectionScreen()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _headerHeight * scale,
                  width: double.infinity,
                  child: AppSvg(
                    asset: 'assets/images/header_logo.svg',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                  child: _SearchBar(scale: scale),
                ),
                SizedBox(height: 16 * scale),
                Padding(
                  padding: EdgeInsets.only(left: 8 * scale),
                  child: Text(
                    'Recent',
                    style: GoogleFonts.nataSans(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.recentLabel,
                      height: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: Text(
                          'No audits available',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nataSans(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                            height: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      _NewAuditButton(scale: scale, onTap: openNewInspection),
                    ],
                  ),
                ),
                SizedBox(height: 96 * scale),
              ],
            ),
            Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 34 * scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BottomNavBar(scale: scale),
                  _FabButton(scale: scale, onTap: openNewInspection),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.scale});

  final double scale;

  static const _searchHeight = DashboardScreen._searchHeight;
  static const _buttonRadius = DashboardScreen._buttonRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _searchHeight * scale,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(_buttonRadius * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Search',
              style: GoogleFonts.nataSans(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.searchPlaceholder,
                height: 1.0,
              ),
            ),
          ),
          AppSvg(
            asset: 'assets/images/search_icon.svg',
            width: 24 * scale,
            height: 24 * scale,
          ),
        ],
      ),
    );
  }
}

class _NewAuditButton extends StatelessWidget {
  const _NewAuditButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  static const _buttonHeight = DashboardScreen._buttonHeight;
  static const _buttonRadius = DashboardScreen._buttonRadius;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final buttonWidth = (342 * scale).clamp(0.0, screenWidth - (48 * scale));

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(_buttonRadius * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_buttonRadius * scale),
        child: SizedBox(
          height: _buttonHeight * scale,
          width: buttonWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Nutritional Audit',
                    style: GoogleFonts.nataSans(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 18 * scale),
                  AppSvg(
                    asset: 'assets/images/plus_icon.svg',
                    width: 20 * scale,
                    height: 20 * scale,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.scale});

  final double scale;

  static const _navBarWidth = DashboardScreen._navBarWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _navBarWidth * scale,
      padding: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        color: AppColors.navBackground,
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppSvg(
            asset: 'assets/images/nav_home.svg',
            width: 71 * scale,
            height: 48 * scale,
          ),
          AppSvg(
            asset: 'assets/images/nav_profile.svg',
            width: 71 * scale,
            height: 48 * scale,
          ),
        ],
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  static const _fabHeight = DashboardScreen._fabHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navBackground,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: Container(
          height: _fabHeight * scale,
          padding: EdgeInsets.all(8 * scale),
          child: AppSvg(
            asset: 'assets/images/fab_plus.svg',
            width: 71 * scale,
            height: 48 * scale,
          ),
        ),
      ),
    );
  }
}
