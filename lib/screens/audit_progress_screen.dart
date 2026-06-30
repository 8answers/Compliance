import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../services/app_services.dart';
import '../services/nutritional_audit_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_svg.dart';
import '../widgets/home_indicator.dart';
import 'nutritional_audit_screen.dart';

class AuditProgressScreen extends StatefulWidget {
  const AuditProgressScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<AuditProgressScreen> createState() => _AuditProgressScreenState();
}

class _AuditProgressScreenState extends State<AuditProgressScreen> {
  static const _stepDuration = Duration(milliseconds: 700);
  static const _completionHold = Duration(milliseconds: 900);
  static const _steps = [
    'Extracting menu items...',
    'Identifying food groups and dishes...',
    'Estimating serving sizes and portions...',
    'Calculating nutritional values per meal...',
    'Comparing against ICMR/NIN & RDA by FSSAI standards...',
    'Detecting Compliance gaps and deficiencies...',
    'Generating AI-powered Recommendations...',
    'Compiling Nutritional Audit Report...',
  ];

  Timer? _progressTimer;
  Timer? _completionTimer;
  int _activeStepIndex = 0;
  bool _isSaving = false;
  bool _completedAllSteps = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _progressTimer = Timer.periodic(_stepDuration, (_) => _advanceProgress());
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _completionTimer?.cancel();
    super.dispose();
  }

  double get _progress {
    if (_completedAllSteps) {
      return 1;
    }
    return (_activeStepIndex + 1) / _steps.length;
  }

  void _advanceProgress() {
    if (_isSaving || _errorMessage != null) {
      return;
    }

    if (_activeStepIndex < _steps.length - 1) {
      setState(() => _activeStepIndex += 1);
      return;
    }

    _progressTimer?.cancel();
    _saveInspection();
  }

  Future<void> _saveInspection() async {
    setState(() => _isSaving = true);
    final services = AppServices.of(context);

    try {
      final inspectionId = await services.inspectionRepository.createInspection(
        widget.draft,
      );
      final report = await services.nutritionalAuditService.generateReport(
        widget.draft,
      );
      await services.inspectionRepository.saveNutritionalAuditReport(
        inspectionId: inspectionId,
        report: report,
      );
      if (!mounted) {
        return;
      }

      setState(() => _completedAllSteps = true);
      _completionTimer = Timer(_completionHold, () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => NutritionalAuditScreen(report: report),
            ),
          );
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = error is NutritionalAuditException
            ? error.message
            : 'Could not generate nutritional audit. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuditProgressBackground()),
          Positioned.fill(
            bottom: 34 * scale,
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final centeredHeight = constraints.maxHeight - 64 * scale;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 32 * scale,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: centeredHeight < 0 ? 0 : centeredHeight,
                      ),
                      child: Center(
                        child: _AuditProgressCard(
                          scale: scale,
                          progress: _progress,
                          activeStepIndex: _activeStepIndex,
                          completedAllSteps: _completedAllSteps,
                          errorMessage: _errorMessage,
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: HomeIndicator(scale: scale),
          ),
        ],
      ),
    );
  }
}

class _AuditProgressBackground extends StatelessWidget {
  const _AuditProgressBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.black,
            AppColors.black,
            Color(0xFF00180B),
            AppColors.green,
          ],
          stops: [0, 0.34, 0.58, 1],
        ),
      ),
    );
  }
}

class _AuditProgressCard extends StatelessWidget {
  const _AuditProgressCard({
    required this.scale,
    required this.progress,
    required this.activeStepIndex,
    required this.completedAllSteps,
    required this.errorMessage,
    required this.onClose,
  });

  final double scale;
  final double progress;
  final int activeStepIndex;
  final bool completedAllSteps;
  final String? errorMessage;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 358 * scale,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.white, width: 1 * scale),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AuditProgressHeader(scale: scale, onClose: onClose),
          SizedBox(height: 32 * scale),
          _AuditProgressBar(scale: scale, progress: progress),
          SizedBox(height: 32 * scale),
          for (
            var index = 0;
            index < _AuditProgressScreenState._steps.length;
            index++
          ) ...[
            _AuditProgressStepText(
              scale: scale,
              text: _AuditProgressScreenState._steps[index],
              state: _stateFor(index),
            ),
            if (index != _AuditProgressScreenState._steps.length - 1)
              SizedBox(height: 32 * scale),
          ],
          if (errorMessage != null) ...[
            SizedBox(height: 24 * scale),
            Text(
              errorMessage!,
              style: GoogleFonts.nataSans(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFF3B30),
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _AuditProgressStepState _stateFor(int index) {
    if (completedAllSteps || index < activeStepIndex) {
      return _AuditProgressStepState.completed;
    }
    if (index == activeStepIndex) {
      return _AuditProgressStepState.active;
    }
    return _AuditProgressStepState.pending;
  }
}

class _AuditProgressHeader extends StatelessWidget {
  const _AuditProgressHeader({required this.scale, required this.onClose});

  final double scale;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppSvg(
          asset: 'assets/images/Audit.svg',
          width: 50 * scale,
          height: 50 * scale,
          color: AppColors.green,
        ),
        SizedBox(width: 16 * scale),
        Expanded(
          child: Text(
            'AI Audit In Progress',
            style: GoogleFonts.nataSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.green,
              height: 1.0,
            ),
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(24 * scale),
          child: Padding(
            padding: EdgeInsets.all(2 * scale),
            child: Icon(
              Icons.close,
              color: const Color(0xFFFF3B30),
              size: 32 * scale,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuditProgressBar extends StatelessWidget {
  const _AuditProgressBar({required this.scale, required this.progress});

  final double scale;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 4 * scale,
              width: constraints.maxWidth,
              color: AppColors.recentLabel,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 4 * scale,
              width: constraints.maxWidth * progress.clamp(0, 1),
              color: AppColors.green,
            ),
          ],
        );
      },
    );
  }
}

enum _AuditProgressStepState { completed, active, pending }

class _AuditProgressStepText extends StatelessWidget {
  const _AuditProgressStepText({
    required this.scale,
    required this.text,
    required this.state,
  });

  final double scale;
  final String text;
  final _AuditProgressStepState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _AuditProgressStepState.completed => AppColors.green.withValues(
        alpha: 0.5,
      ),
      _AuditProgressStepState.active => AppColors.green,
      _AuditProgressStepState.pending => AppColors.recentLabel,
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.nataSans(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.25,
          decoration: state == _AuditProgressStepState.completed
              ? TextDecoration.lineThrough
              : TextDecoration.none,
          decorationColor: color,
          decorationThickness: 1.5 * scale,
        ),
      ),
    );
  }
}
