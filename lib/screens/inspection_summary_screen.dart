import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../models/menu_file_selection.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_svg.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'menu_upload_screen.dart';

class InspectionSummaryScreen extends StatefulWidget {
  const InspectionSummaryScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<InspectionSummaryScreen> createState() =>
      _InspectionSummaryScreenState();
}

class _InspectionSummaryScreenState extends State<InspectionSummaryScreen> {
  bool _isSaving = false;
  String? _errorMessage;

  static const _horizontalPadding = 16.0;

  Future<void> _generateAudit() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await AppServices.of(
        context,
      ).inspectionRepository.createInspection(widget.draft);
      if (!mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = 'Could not generate audit. Please try again.';
      });
    }
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16 * scale,
                    horizontalPadding,
                    0,
                  ),
                  child: Row(
                    children: [
                      InspectionBackButton(
                        scale: scale,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: _GenerateAuditButton(
                          scale: scale,
                          isSaving: _isSaving,
                          onTap: _generateAudit,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'Summary',
                    style: GoogleFonts.nataSans(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      height: 1.0,
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      14 * scale,
                      0,
                      14 * scale,
                      44 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummarySection(
                          scale: scale,
                          title: 'Institution Type',
                          values: [widget.draft.institutionType ?? ''],
                        ),
                        _SummarySection(
                          scale: scale,
                          title: 'Age Group(s)',
                          values: widget.draft.ageGroups,
                        ),
                        _SummarySection(
                          scale: scale,
                          title: 'Diet Type',
                          values: widget.draft.dietTypes,
                        ),
                        _SummarySection(
                          scale: scale,
                          title: 'Meals Served',
                          values: widget.draft.mealsServed,
                        ),
                        _SummarySection(
                          scale: scale,
                          title: 'Region',
                          values: [widget.draft.region ?? ''],
                        ),
                        _MenuSummary(scale: scale, draft: widget.draft),
                        if (_errorMessage != null) ...[
                          SizedBox(height: 16 * scale),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nataSans(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                              height: 1.35,
                            ),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }
}

class _GenerateAuditButton extends StatelessWidget {
  const _GenerateAuditButton({
    required this.scale,
    required this.isSaving,
    required this.onTap,
  });

  final double scale;
  final bool isSaving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: isSaving ? null : onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: SizedBox(
          height: 64 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isSaving
                ? [
                    SizedBox(
                      width: 24 * scale,
                      height: 24 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5 * scale,
                        color: AppColors.white,
                      ),
                    ),
                  ]
                : [
                    Text(
                      'Generate Audit',
                      style: GoogleFonts.nataSans(
                        fontSize: 24 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    AppSvg(
                      asset: 'assets/images/Audit.svg',
                      width: 26 * scale,
                      height: 26 * scale,
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.scale,
    required this.title,
    required this.values,
  });

  final double scale;
  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final visibleValues = values.where((value) => value.isNotEmpty).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nataSans(
              fontSize: 24 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
              height: 1.0,
            ),
          ),
          SizedBox(height: 8 * scale),
          for (final value in visibleValues) ...[
            Text(
              value,
              style: GoogleFonts.nataSans(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.35,
              ),
            ),
            if (value != visibleValues.last) SizedBox(height: 4 * scale),
          ],
        ],
      ),
    );
  }
}

class _MenuSummary extends StatelessWidget {
  const _MenuSummary({required this.scale, required this.draft});

  final double scale;
  final InspectionDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: GoogleFonts.nataSans(
            fontSize: 24 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.green,
            height: 1.0,
          ),
        ),
        SizedBox(height: 8 * scale),
        if (draft.menuEntryMethod == InspectionDraft.uploadFileMethod)
          SelectedMenuFileCard(
            scale: scale,
            file: MenuFileSelection(
              name: draft.menuFileName ?? '',
              sizeBytes: draft.menuFileSizeBytes ?? 0,
            ),
          )
        else
          Text(
            draft.menuText ?? '',
            style: GoogleFonts.nataSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1.25,
            ),
          ),
      ],
    );
  }
}
