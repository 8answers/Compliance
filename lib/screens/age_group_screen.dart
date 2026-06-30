import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'diet_type_screen.dart';

class AgeGroupScreen extends StatefulWidget {
  const AgeGroupScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<AgeGroupScreen> createState() => _AgeGroupScreenState();
}

class _AgeGroupScreenState extends State<AgeGroupScreen> {
  final Set<int> _selectedIndexes = {};

  static const _horizontalPadding = 16.0;
  static const _listGap = 17.0;

  static const _ageGroups = [
    _AgeGroup(title: '2–5 Years', subtitle: 'Early Childhood'),
    _AgeGroup(title: '6–12 Years', subtitle: 'School Children'),
    _AgeGroup(title: '13–18 Years', subtitle: 'Adolescents'),
    _AgeGroup(title: '19–30 Years', subtitle: 'Young Adults'),
    _AgeGroup(title: '31–50 Years', subtitle: 'Adults'),
    _AgeGroup(title: '51–60 Years', subtitle: 'Senior Adults'),
    _AgeGroup(title: '60+ Years', subtitle: 'Elderly'),
    _AgeGroup(title: 'Mixed Age Group', subtitle: 'All Ages'),
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

  List<String> _selectedAgeGroups() {
    final indexes = _selectedIndexes.toList()..sort();
    return [for (final index in indexes) _ageGroups[index].title];
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
                    child: InspectionFlowHeader(currentStep: 2, scale: scale),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Select Age Group(s)',
                    style: GoogleFonts.nataSans(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 15 * scale),
                  Text(
                    'You can select multiple groups',
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
                          for (var i = 0; i < _ageGroups.length; i++) ...[
                            if (i > 0) SizedBox(height: _listGap * scale),
                            InspectionSelectionCard(
                              title: _ageGroups[i].title,
                              subtitle: _ageGroups[i].subtitle,
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
            InspectionBottomActions(
              scale: scale,
              nextEnabled: _selectedIndexes.isNotEmpty,
              onBack: () => Navigator.of(context).pop(),
              onNext: _selectedIndexes.isNotEmpty
                  ? () {
                      final draft = widget.draft.copyWith(
                        ageGroups: _selectedAgeGroups(),
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DietTypeScreen(draft: draft),
                        ),
                      );
                    }
                  : null,
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

class _AgeGroup {
  const _AgeGroup({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
