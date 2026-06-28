import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'meals_served_screen.dart';

class DietTypeScreen extends StatefulWidget {
  const DietTypeScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<DietTypeScreen> createState() => _DietTypeScreenState();
}

class _DietTypeScreenState extends State<DietTypeScreen> {
  final Set<int> _selectedIndexes = {};

  static const _horizontalPadding = 16.0;
  static const _listGap = 17.0;

  static const _dietOptions = [
    _DietOption(
      title: 'Vegetarian',
      indicatorAsset: 'assets/images/diet_indicator_1.svg',
    ),
    _DietOption(
      title: 'Non-Vegetarian',
      indicatorAsset: 'assets/images/diet_indicator_2.svg',
    ),
    _DietOption(
      title: 'Eggetarian',
      indicatorAsset: 'assets/images/diet_indicator_3.svg',
    ),
    _DietOption(
      title: 'Vegan',
      indicatorAsset: 'assets/images/diet_indicator_4.svg',
    ),
    _DietOption(
      title: 'Jain',
      indicatorAsset: 'assets/images/diet_indicator_5.svg',
    ),
  ];

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  List<String> _selectedDietTypes() {
    final indexes = _selectedIndexes.toList()..sort();
    return [for (final index in indexes) _dietOptions[index].title];
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
                    child: InspectionFlowHeader(currentStep: 3, scale: scale),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Select Diet Type',
                    style: GoogleFonts.nataSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Text(
                    'You can select multiple diet options',
                    style: GoogleFonts.nataSans(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w400,
                      color: AppColors.recentLabel,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 22 * scale),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _dietOptions.length; i++) ...[
                            if (i > 0) SizedBox(height: _listGap * scale),
                            InspectionSelectionCard(
                              title: _dietOptions[i].title,
                              leadingIndicatorAsset:
                                  _dietOptions[i].indicatorAsset,
                              isSelected: _selectedIndexes.contains(i),
                              scale: scale,
                              onTap: () => _toggleSelection(i),
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
                      enabled: _selectedIndexes.isNotEmpty,
                      onTap: _selectedIndexes.isNotEmpty
                          ? () {
                              final draft = widget.draft.copyWith(
                                dietTypes: _selectedDietTypes(),
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      MealsServedScreen(draft: draft),
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

class _DietOption {
  const _DietOption({required this.title, required this.indicatorAsset});

  final String title;
  final String indicatorAsset;
}
