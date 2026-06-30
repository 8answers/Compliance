import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/nutritional_audit_report.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';

class NutritionalAuditScreen extends StatefulWidget {
  const NutritionalAuditScreen({
    super.key,
    required this.report,
    this.savedAuditId,
  });

  final NutritionalAuditReport report;
  final String? savedAuditId;

  static const _red = Color(0xFFFF0000);
  static const _orange = Color(0xFFFF9500);
  static const _yellow = Color(0xFFFBBC05);
  static const _blue = Color(0xFF4285F4);

  static const _nutrientSections = [
    _NutrientSection('Macro-nutrients', [
      'Protein',
      'Carbohydrate',
      'Total Fat',
      'Saturated Fat',
      'Monounsaturated Fat',
      'Polyunsaturated Fat',
      'Omega-3 Fatty Acids',
      'Omega-6 Fatty Acids',
      'Dietary Fiber',
    ]),
    _NutrientSection('Sugar', ['Total Sugar']),
    _NutrientSection('Major Minerals', ['Calcium', 'Phosphorus', 'Magnesium']),
    _NutrientSection('Trace Minerals', [
      'Iron',
      'Zinc',
      'Copper',
      'Manganese',
      'Selenium',
      'Iodine',
      'Chromium',
      'Molybdenum',
    ]),
    _NutrientSection('Water-Soluble Vitamins', [
      'Vitamin B1',
      'Vitamin B2',
      'Vitamin B3',
      'Vitamin B5',
      'Vitamin B6',
      'Vitamin B7',
      'Vitamin B9',
      'Vitamin B12',
      'Vitamin C',
    ]),
    _NutrientSection('Fat-Soluble Vitamins', [
      'Vitamin A',
      'Vitamin D',
      'Vitamin E',
      'Vitamin K',
    ]),
  ];

  static const _foodGroups = [
    'Cereals & Millets',
    'Pulses & Legumes',
    'Milk & Dairy',
    'Protein Sources',
    'Vegetables',
    'Nuts & Seeds',
    'Healthy Fats & Oils',
    'Fruits',
  ];

  @override
  State<NutritionalAuditScreen> createState() => _NutritionalAuditScreenState();

  static Color scoreColor(num score) {
    if (score < 50) {
      return _red;
    }
    if (score < 75) {
      return _orange;
    }
    if (score < 95) {
      return _blue;
    }
    return AppColors.green;
  }

  static Color gradeColor(String grade) {
    return switch (grade) {
      'A' => AppColors.green,
      'B' => _blue,
      'C' => _yellow,
      'D' => _orange,
      _ => _red,
    };
  }

  static Color nutrientColor(num compliancePercent) {
    if (compliancePercent > 85) {
      return AppColors.green;
    }
    if (compliancePercent >= 65) {
      return _yellow;
    }
    return _red;
  }

  static NutrientAnalysisItem nutrientFor(
    NutritionalAuditReport report,
    String name,
  ) {
    return report.nutrientAnalysis.firstWhere(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
      orElse: () => NutrientAnalysisItem(
        name: name,
        requiredAmount: '-',
        estimatedAmount: '-',
        compliancePercent: 0,
      ),
    );
  }

  static FoodGroupCoverageItem foodGroupFor(
    NutritionalAuditReport report,
    String name,
  ) {
    return report.foodGroupCoverage.firstWhere(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
      orElse: () => FoodGroupCoverageItem(
        name: name,
        totalPercent: 100,
        compliantPercent: 0,
      ),
    );
  }
}

class _NutritionalAuditScreenState extends State<NutritionalAuditScreen> {
  bool _showDelete = false;
  bool _isDeleting = false;

  Future<void> _deleteAudit() async {
    final auditId = widget.savedAuditId;
    if (auditId == null || _isDeleting) {
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await AppServices.of(
        context,
      ).inspectionRepository.deleteNutritionalAudit(auditId);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final canDelete = widget.savedAuditId != null;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  scale: scale,
                  onClose: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  showMenuButton: canDelete,
                  isMenuOpen: _showDelete,
                  onToggleMenu: () =>
                      setState(() => _showDelete = !_showDelete),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16 * scale,
                      32 * scale,
                      16 * scale,
                      56 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _OverallAssessment(scale: scale, report: widget.report),
                        _Divider(scale: scale),
                        _NutrientAnalysis(scale: scale, report: widget.report),
                        _Divider(scale: scale),
                        _FoodGroupCoverage(scale: scale, report: widget.report),
                        SizedBox(height: 16 * scale),
                        _Deficiencies(scale: scale, report: widget.report),
                        SizedBox(height: 16 * scale),
                        _Recommendations(scale: scale, report: widget.report),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: HomeIndicator(scale: scale),
            ),
            if (canDelete && _showDelete)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => setState(() => _showDelete = false),
                ),
              ),
            if (canDelete && _showDelete)
              Positioned(
                top: 54 * scale,
                right: 16 * scale,
                child: _DeleteAuditButton(
                  scale: scale,
                  isDeleting: _isDeleting,
                  onTap: _deleteAudit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.scale,
    required this.onClose,
    required this.showMenuButton,
    required this.isMenuOpen,
    required this.onToggleMenu,
  });

  final double scale;
  final VoidCallback onClose;
  final bool showMenuButton;
  final bool isMenuOpen;
  final VoidCallback onToggleMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 8 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Nutritional Audit',
            style: GoogleFonts.nataSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1.0,
            ),
          ),
          Row(
            children: [
              Material(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(32 * scale),
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(32 * scale),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 8 * scale,
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              if (showMenuButton) ...[
                SizedBox(width: 16 * scale),
                Material(
                  color: isMenuOpen
                      ? AppColors.green.withValues(alpha: 0.5)
                      : AppColors.green,
                  borderRadius: BorderRadius.circular(32 * scale),
                  child: InkWell(
                    onTap: onToggleMenu,
                    borderRadius: BorderRadius.circular(32 * scale),
                    child: SizedBox(
                      height: 37 * scale,
                      width: 56 * scale,
                      child: Icon(
                        Icons.more_horiz,
                        color: AppColors.white,
                        size: 18 * scale,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DeleteAuditButton extends StatelessWidget {
  const _DeleteAuditButton({
    required this.scale,
    required this.isDeleting,
    required this.onTap,
  });

  final double scale;
  final bool isDeleting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF0606),
      borderRadius: BorderRadius.circular(16 * scale),
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Container(
          height: 56 * scale,
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDeleting ? 'Deleting' : 'Delete',
                style: GoogleFonts.nataSans(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                  height: 1.0,
                ),
              ),
              SizedBox(width: 16 * scale),
              Icon(
                Icons.delete_outline,
                size: 18 * scale,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.all(4 * scale),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _OverallAssessment extends StatelessWidget {
  const _OverallAssessment({required this.scale, required this.report});

  final double scale;
  final NutritionalAuditReport report;

  @override
  Widget build(BuildContext context) {
    return _Section(
      scale: scale,
      title: 'Overall Assessment',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScoreMetric(
                scale: scale,
                label: 'Compliance Score',
                score: report.complianceScore,
              ),
              SizedBox(width: 40 * scale),
              _ScoreMetric(
                scale: scale,
                label: 'Nutrition Score',
                score: report.nutritionScore,
              ),
            ],
          ),
          SizedBox(height: 32 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ScoreMetric(
                scale: scale,
                label: 'Meal Diversity Score',
                score: report.mealDiversityScore,
              ),
              SizedBox(width: 40 * scale),
              _GradeMetric(scale: scale, grade: report.grade),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreMetric extends StatelessWidget {
  const _ScoreMetric({
    required this.scale,
    required this.label,
    required this.score,
  });

  final double scale;
  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final color = NutritionalAuditScreen.scoreColor(score);

    return SizedBox(
      width: 140 * scale,
      child: Column(
        children: [
          SizedBox(
            width: 140 * scale,
            height: 140 * scale,
            child: CustomPaint(
              painter: _ScoreRingPainter(
                progress: score.clamp(0, 100) / 100,
                color: color,
                scale: scale,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: GoogleFonts.nataSans(
                        fontSize: 32 * scale,
                        fontWeight: FontWeight.w500,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '/100',
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nataSans(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeMetric extends StatelessWidget {
  const _GradeMetric({required this.scale, required this.grade});

  final double scale;
  final String grade;

  @override
  Widget build(BuildContext context) {
    final color = NutritionalAuditScreen.gradeColor(grade);

    return SizedBox(
      width: 140 * scale,
      child: Column(
        children: [
          Container(
            width: 140 * scale,
            height: 140 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 4 * scale),
            ),
            child: Text(
              grade,
              style: GoogleFonts.nataSans(
                fontSize: 48 * scale,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Grade',
            style: GoogleFonts.nataSans(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w400,
              color: AppColors.white,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientAnalysis extends StatelessWidget {
  const _NutrientAnalysis({required this.scale, required this.report});

  final double scale;
  final NutritionalAuditReport report;

  @override
  Widget build(BuildContext context) {
    return _Section(
      scale: scale,
      header: _SectionHeader(
        scale: scale,
        child: Text.rich(
          TextSpan(
            text: 'Nutrient Analysis ',
            style: GoogleFonts.nataSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
              height: 1.0,
            ),
            children: [
              TextSpan(
                text: '(Avg of all meals for per day)',
                style: GoogleFonts.nataSans(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF575757),
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(scale: scale),
          SizedBox(height: 16 * scale),
          _NutrientTableHeader(scale: scale),
          SizedBox(height: 8 * scale),
          _NutrientRow(
            scale: scale,
            item: NutritionalAuditScreen.nutrientFor(
              report,
              'Energy (Calories)',
            ),
          ),
          SizedBox(height: 4 * scale),
          for (final section in NutritionalAuditScreen._nutrientSections) ...[
            _TableSectionLabel(scale: scale, label: section.title),
            for (final nutrient in section.nutrients)
              _NutrientRow(
                scale: scale,
                item: NutritionalAuditScreen.nutrientFor(report, nutrient),
              ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendText(
          scale: scale,
          text: '>85% Compliant',
          color: AppColors.green,
        ),
        SizedBox(height: 8 * scale),
        _LegendText(
          scale: scale,
          text: '65% - 85% Compliant',
          color: NutritionalAuditScreen._yellow,
        ),
        SizedBox(height: 8 * scale),
        _LegendText(
          scale: scale,
          text: '<65% Compliant',
          color: NutritionalAuditScreen._red,
        ),
      ],
    );
  }
}

class _LegendText extends StatelessWidget {
  const _LegendText({
    required this.scale,
    required this.text,
    required this.color,
  });

  final double scale;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nataSans(
        fontSize: 14 * scale,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.0,
      ),
    );
  }
}

class _NutrientTableHeader extends StatelessWidget {
  const _NutrientTableHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return _TableHeader(
      scale: scale,
      first: 'Information',
      second: 'Required',
      third: 'Estimated',
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.scale, required this.item});

  final double scale;
  final NutrientAnalysisItem item;

  @override
  Widget build(BuildContext context) {
    final color = NutritionalAuditScreen.nutrientColor(item.compliancePercent);

    return _BorderedTableRow(
      scale: scale,
      color: color,
      first: item.name,
      second: item.requiredAmount,
      third: item.estimatedAmount,
    );
  }
}

class _FoodGroupCoverage extends StatelessWidget {
  const _FoodGroupCoverage({required this.scale, required this.report});

  final double scale;
  final NutritionalAuditReport report;

  @override
  Widget build(BuildContext context) {
    return _Section(
      scale: scale,
      title: 'Food Group Coverage Score',
      child: Column(
        children: [
          _TableHeader(
            scale: scale,
            first: 'Food Group',
            second: 'Total',
            third: 'Compliant',
          ),
          SizedBox(height: 8 * scale),
          for (final foodGroup in NutritionalAuditScreen._foodGroups)
            _FoodGroupRow(
              scale: scale,
              item: NutritionalAuditScreen.foodGroupFor(report, foodGroup),
            ),
        ],
      ),
    );
  }
}

class _FoodGroupRow extends StatelessWidget {
  const _FoodGroupRow({required this.scale, required this.item});

  final double scale;
  final FoodGroupCoverageItem item;

  @override
  Widget build(BuildContext context) {
    final color = NutritionalAuditScreen.nutrientColor(item.compliantPercent);

    return _BorderedTableRow(
      scale: scale,
      color: color,
      first: item.name,
      second: '${item.totalPercent.round()}%',
      third: '${item.compliantPercent.round()}%',
    );
  }
}

class _Deficiencies extends StatelessWidget {
  const _Deficiencies({required this.scale, required this.report});

  final double scale;
  final NutritionalAuditReport report;

  @override
  Widget build(BuildContext context) {
    final deficiencies = report.deficiencies.isEmpty
        ? const ['No major deficiencies identified']
        : report.deficiencies;

    return _Section(
      scale: scale,
      title: 'Deficiencies Identified',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
            child: Text('Deficiencies', style: _tableHeaderStyle(scale)),
          ),
          SizedBox(height: 8 * scale),
          for (final deficiency in deficiencies)
            _SingleColumnRow(
              scale: scale,
              text: deficiency,
              color: NutritionalAuditScreen._red,
            ),
        ],
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  const _Recommendations({required this.scale, required this.report});

  final double scale;
  final NutritionalAuditReport report;

  @override
  Widget build(BuildContext context) {
    final recommendations = report.recommendations.isEmpty
        ? const ['No recommendation generated.']
        : report.recommendations.take(6).toList();

    return _Section(
      scale: scale,
      title: 'AI Recommendations',
      child: Container(
        constraints: BoxConstraints(minHeight: 202 * scale),
        padding: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.white, width: 1 * scale),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < recommendations.length; index++)
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: Text(
                  '${index + 1}. ${recommendations[index]}',
                  style: GoogleFonts.nataSans(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                    height: 1.25,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.scale,
    required this.child,
    this.title,
    this.header,
  });

  final double scale;
  final String? title;
  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header ??
            _SectionHeader(
              scale: scale,
              child: Text(
                title ?? '',
                style: GoogleFonts.nataSans(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                  height: 1.0,
                ),
              ),
            ),
        SizedBox(height: 16 * scale),
        child,
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.scale,
    required this.first,
    required this.second,
    required this.third,
  });

  final double scale;
  final String first;
  final String second;
  final String third;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Row(
        children: [
          Expanded(child: Text(first, style: _tableHeaderStyle(scale))),
          SizedBox(
            width: 61 * scale,
            child: Text(
              second,
              textAlign: TextAlign.center,
              style: _tableHeaderStyle(scale),
            ),
          ),
          SizedBox(width: 32 * scale),
          SizedBox(
            width: 72 * scale,
            child: Text(
              third,
              textAlign: TextAlign.center,
              style: _tableHeaderStyle(scale),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorderedTableRow extends StatelessWidget {
  const _BorderedTableRow({
    required this.scale,
    required this.color,
    required this.first,
    required this.second,
    required this.third,
  });

  final double scale;
  final Color color;
  final String first;
  final String second;
  final String third;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Container(
        padding: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1 * scale),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ScaledText(
                text: first,
                color: color,
                scale: scale,
                weight: FontWeight.w400,
              ),
            ),
            SizedBox(
              width: 61 * scale,
              child: _ScaledText(
                text: second,
                color: color,
                scale: scale,
                textAlign: TextAlign.center,
                weight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 32 * scale),
            SizedBox(
              width: 72 * scale,
              child: _ScaledText(
                text: third,
                color: color,
                scale: scale,
                textAlign: TextAlign.center,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleColumnRow extends StatelessWidget {
  const _SingleColumnRow({
    required this.scale,
    required this.text,
    required this.color,
  });

  final double scale;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1 * scale),
        ),
        child: Text(
          text,
          style: GoogleFonts.nataSans(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w400,
            color: color,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class _TableSectionLabel extends StatelessWidget {
  const _TableSectionLabel({required this.scale, required this.label});

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4 * scale, 4 * scale, 4 * scale, 8 * scale),
      child: Text(
        label,
        style: GoogleFonts.nataSans(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          height: 1.0,
        ),
      ),
    );
  }
}

class _ScaledText extends StatelessWidget {
  const _ScaledText({
    required this.text,
    required this.color,
    required this.scale,
    required this.weight,
    this.textAlign = TextAlign.left,
  });

  final String text;
  final Color color;
  final double scale;
  final FontWeight weight;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: textAlign == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.nataSans(
          fontSize: 14 * scale,
          fontWeight: weight,
          color: color,
          height: 1.0,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32 * scale),
      child: Container(height: 1 * scale, color: AppColors.white),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.scale,
  });

  final double progress;
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4 * scale;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        scale != oldDelegate.scale;
  }
}

TextStyle _tableHeaderStyle(double scale) {
  return GoogleFonts.nataSans(
    fontSize: 14 * scale,
    fontWeight: FontWeight.w700,
    color: AppColors.recentLabel,
    height: 1.0,
  );
}

class _NutrientSection {
  const _NutrientSection(this.title, this.nutrients);

  final String title;
  final List<String> nutrients;
}
