import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'age_group_screen.dart';

class NewInspectionScreen extends StatefulWidget {
  const NewInspectionScreen({super.key, this.draft = const InspectionDraft()});

  final InspectionDraft draft;

  @override
  State<NewInspectionScreen> createState() => _NewInspectionScreenState();
}

class _NewInspectionScreenState extends State<NewInspectionScreen> {
  int? _selectedIndex;

  static const _institutionTypes = [
    _InstitutionType(
      title: 'Education',
      subtitle: 'Schools, Colleges, Universities',
      iconAsset: 'assets/images/institution_education.svg',
    ),
    _InstitutionType(
      title: 'Residential',
      subtitle: 'Hostels, PGs, Dormitories',
      iconAsset: 'assets/images/institution_residential.svg',
    ),
    _InstitutionType(
      title: 'Workplace',
      subtitle: 'Corporate Canteens, Offices',
      iconAsset: 'assets/images/institution_workplace.svg',
    ),
    _InstitutionType(
      title: 'Community',
      subtitle: 'NGOs, Shelters, Orphanages',
      iconAsset: 'assets/images/institution_community.svg',
    ),
    _InstitutionType(
      title: 'Other',
      subtitle: 'Any Other Institution',
      iconAsset: 'assets/images/institution_other.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = 16 * scale;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: InspectionFlowHeader(currentStep: 1, scale: scale),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'Select Institution Type',
                    style: GoogleFonts.nataSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: _InstitutionGrid(
                      types: _institutionTypes,
                      selectedIndex: _selectedIndex,
                      scale: scale,
                      onSelect: (index) {
                        setState(() => _selectedIndex = index);
                      },
                    ),
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
                      onTap: _selectedIndex != null
                          ? () {
                              final draft = widget.draft.copyWith(
                                institutionType:
                                    _institutionTypes[_selectedIndex!].title,
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => AgeGroupScreen(draft: draft),
                                ),
                              );
                            }
                          : null,
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

class _InstitutionType {
  const _InstitutionType({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
}

class _InstitutionGrid extends StatelessWidget {
  const _InstitutionGrid({
    required this.types,
    required this.selectedIndex,
    required this.scale,
    required this.onSelect,
  });

  final List<_InstitutionType> types;
  final int? selectedIndex;
  final double scale;
  final ValueChanged<int> onSelect;

  static const _cardWidth = 171.0;
  static const _rowGap = 17.0;

  @override
  Widget build(BuildContext context) {
    final cardWidth = _cardWidth * scale;

    return Column(
      children: [
        for (var row = 0; row < (types.length / 2).ceil(); row++) ...[
          if (row > 0) SizedBox(height: _rowGap * scale),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var col = 0; col < 2; col++)
                if (row * 2 + col < types.length)
                  SizedBox(
                    width: cardWidth,
                    child: InspectionSelectionCard(
                      title: types[row * 2 + col].title,
                      subtitle: types[row * 2 + col].subtitle,
                      iconAsset: types[row * 2 + col].iconAsset,
                      isSelected: selectedIndex == row * 2 + col,
                      scale: scale,
                      onTap: () => onSelect(row * 2 + col),
                    ),
                  )
                else
                  SizedBox(width: cardWidth),
            ],
          ),
        ],
      ],
    );
  }
}
