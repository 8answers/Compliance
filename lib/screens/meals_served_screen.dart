import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'region_screen.dart';

class MealsServedScreen extends StatefulWidget {
  const MealsServedScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<MealsServedScreen> createState() => _MealsServedScreenState();
}

class _MealsServedScreenState extends State<MealsServedScreen> {
  final Set<int> _selectedIndexes = {};

  static const _horizontalPadding = 16.0;
  static const _listGap = 17.0;

  static const _mealOptions = [
    _MealOption(
      title: 'Breakfast',
      iconAsset: 'assets/images/meal_breakfast.svg',
      iconWidth: 24,
      iconHeight: 10,
    ),
    _MealOption(
      title: 'Lunch',
      iconAsset: 'assets/images/meal_lunch.svg',
      iconWidth: 20,
      iconHeight: 20,
    ),
    _MealOption(
      title: 'Dinner',
      iconAsset: 'assets/images/meal_dinner.svg',
      iconWidth: 16,
      iconHeight: 15,
    ),
    _MealOption(
      title: 'Morning Snack',
      iconAsset: 'assets/images/meal_breakfast.svg',
      iconWidth: 24,
      iconHeight: 10,
    ),
    _MealOption(
      title: 'Afternoon Snack',
      iconAsset: 'assets/images/meal_lunch.svg',
      iconWidth: 20,
      iconHeight: 20,
    ),
    _MealOption(
      title: 'Night Snack',
      iconAsset: 'assets/images/meal_dinner.svg',
      iconWidth: 16,
      iconHeight: 15,
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

  List<String> _selectedMealsServed() {
    final indexes = _selectedIndexes.toList()..sort();
    return [for (final index in indexes) _mealOptions[index].title];
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
                    child: InspectionFlowHeader(currentStep: 4, scale: scale),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Select Meals Served',
                    style: GoogleFonts.nataSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Text(
                    'You can select multiple options',
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
                          for (var i = 0; i < _mealOptions.length; i++) ...[
                            if (i > 0) SizedBox(height: _listGap * scale),
                            InspectionSelectionCard(
                              title: _mealOptions[i].title,
                              leadingIconAsset: _mealOptions[i].iconAsset,
                              leadingIconWidth: _mealOptions[i].iconWidth,
                              leadingIconHeight: _mealOptions[i].iconHeight,
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
                                mealsServed: _selectedMealsServed(),
                              );

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RegionScreen(draft: draft),
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

class _MealOption {
  const _MealOption({
    required this.title,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String title;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
}
