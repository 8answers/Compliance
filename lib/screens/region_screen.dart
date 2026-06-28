import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'menu_upload_screen.dart';

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  int? _selectedIndex;

  static const _horizontalPadding = 16.0;
  static const _listGap = 17.0;

  static const _regionOptions = [
    _RegionOption(
      title: 'North India',
      iconAsset: 'assets/images/region_north.svg',
      iconWidth: 14.222,
      iconHeight: 16,
    ),
    _RegionOption(
      title: 'South India',
      iconAsset: 'assets/images/region_north.svg',
      iconWidth: 14.222,
      iconHeight: 16,
      iconRotation: math.pi,
    ),
    _RegionOption(
      title: 'East India',
      iconAsset: 'assets/images/region_north.svg',
      iconWidth: 16,
      iconHeight: 14.222,
      iconRotation: math.pi / 2,
    ),
    _RegionOption(
      title: 'West India',
      iconAsset: 'assets/images/region_north.svg',
      iconWidth: 16,
      iconHeight: 14.222,
      iconRotation: -math.pi / 2,
    ),
    _RegionOption(
      title: 'Central India',
      iconAsset: 'assets/images/region_central.svg',
      iconWidth: 16,
      iconHeight: 14.222,
      iconRotation: math.pi / 2,
    ),
    _RegionOption(
      title: 'North-East India',
      iconAsset: 'assets/images/region_north.svg',
      iconWidth: 21.37,
      iconHeight: 21.37,
      iconRotation: math.pi / 4,
    ),
  ];

  void _openMenuUpload() {
    final selectedIndex = _selectedIndex;
    if (selectedIndex == null) {
      return;
    }

    final draft = widget.draft.copyWith(
      region: _regionOptions[selectedIndex].title,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => MenuUploadScreen(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = _horizontalPadding * scale;

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
                  Padding(
                    padding: EdgeInsets.only(top: horizontalPadding),
                    child: InspectionFlowHeader(currentStep: 5, scale: scale),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Select Region',
                    style: GoogleFonts.nataSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 23 * scale),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _regionOptions.length; i++) ...[
                            if (i > 0) SizedBox(height: _listGap * scale),
                            InspectionSelectionCard(
                              title: _regionOptions[i].title,
                              leadingIconAsset: _regionOptions[i].iconAsset,
                              leadingIconWidth: _regionOptions[i].iconWidth,
                              leadingIconHeight: _regionOptions[i].iconHeight,
                              leadingIconRotation:
                                  _regionOptions[i].iconRotation,
                              isSelected: _selectedIndex == i,
                              scale: scale,
                              onTap: () {
                                setState(() => _selectedIndex = i);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 96 * scale),
                ],
              ),
            ),
            Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: 34 * scale,
              child: Row(
                children: [
                  InspectionBackButton(
                    scale: scale,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: InspectionNextButton(
                      scale: scale,
                      enabled: _selectedIndex != null,
                      onTap: _selectedIndex != null ? _openMenuUpload : null,
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

class _RegionOption {
  const _RegionOption({
    required this.title,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    this.iconRotation = 0,
  });

  final String title;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final double iconRotation;
}
