import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'app_svg.dart';

enum _StepState { completed, active, inactive }

class InspectionFlowHeader extends StatelessWidget {
  const InspectionFlowHeader({
    super.key,
    required this.currentStep,
    required this.scale,
  });

  final int currentStep;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'New Inspection',
              style: GoogleFonts.nataSans(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.white,
                height: 1.0,
              ),
            ),
            Text(
              'Step $currentStep of 6',
              style: GoogleFonts.nataSans(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w500,
                color: AppColors.recentLabel,
                height: 1.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 16 * scale),
        InspectionStepProgressBar(currentStep: currentStep, scale: scale),
      ],
    );
  }
}

class InspectionStepProgressBar extends StatelessWidget {
  const InspectionStepProgressBar({
    super.key,
    required this.currentStep,
    required this.scale,
  });

  final int currentStep;
  final double scale;

  _StepState _stateFor(int step) {
    if (step < currentStep) {
      return _StepState.completed;
    }
    if (step == currentStep) {
      return _StepState.active;
    }
    return _StepState.inactive;
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    for (var step = 1; step <= 6; step++) {
      if (step > 1) {
        final connectorAsset = step - 1 < currentStep
            ? 'assets/images/step_connector_active.svg'
            : 'assets/images/step_connector_inactive.svg';
        items.add(
          AppSvg(asset: connectorAsset, width: 15 * scale, height: 8 * scale),
        );
      }

      items.add(_StepDot(state: _stateFor(step), step: step, scale: scale));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.state,
    required this.step,
    required this.scale,
  });

  final _StepState state;
  final int step;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (state) {
      _StepState.completed => AppColors.green,
      _StepState.active => AppColors.white,
      _StepState.inactive => AppColors.searchBackground,
    };
    final textColor = switch (state) {
      _StepState.completed => AppColors.white,
      _StepState.active => AppColors.green,
      _StepState.inactive => AppColors.recentLabel,
    };

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32 * scale),
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: GoogleFonts.nataSans(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w500,
          color: textColor,
          height: 1.0,
        ),
      ),
    );
  }
}

class InspectionBackButton extends StatelessWidget {
  const InspectionBackButton({
    super.key,
    required this.scale,
    required this.onTap,
  });

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(32 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32 * scale),
        child: SizedBox(
          height: 64 * scale,
          width: 64 * scale,
          child: Center(
            child: Transform.rotate(
              angle: -1.5708,
              child: AppSvg(
                asset: 'assets/images/arrow_back.svg',
                width: 24 * scale,
                height: 21.33 * scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InspectionNextButton extends StatelessWidget {
  const InspectionNextButton({
    super.key,
    required this.scale,
    required this.enabled,
    required this.onTap,
    this.label = 'Next',
    this.isBusy = false,
  });

  final double scale;
  final bool enabled;
  final VoidCallback? onTap;
  final String label;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(32 * scale);
    final foregroundOpacity = enabled ? 1.0 : 0.5;

    return Material(
      color: enabled ? AppColors.green : const Color(0xFF005126),
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          height: 64 * scale,
          child: Opacity(
            opacity: foregroundOpacity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isBusy
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
                        label,
                        style: GoogleFonts.nataSans(
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 24 * scale),
                      Transform.rotate(
                        angle: 1.5708,
                        child: AppSvg(
                          asset: 'assets/images/arrow_forward.svg',
                          width: 24 * scale,
                          height: 21.33 * scale,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class InspectionBottomActions extends StatelessWidget {
  const InspectionBottomActions({
    super.key,
    required this.scale,
    required this.nextEnabled,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
    this.nextIsBusy = false,
  });

  final double scale;
  final bool nextEnabled;
  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextIsBusy;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: 0.08),
                  AppColors.black.withValues(alpha: 0.62),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                12 * scale,
                16 * scale,
                34 * scale,
              ),
              child: Row(
                children: [
                  InspectionBackButton(scale: scale, onTap: onBack),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: InspectionNextButton(
                      scale: scale,
                      enabled: nextEnabled,
                      onTap: onNext,
                      label: nextLabel,
                      isBusy: nextIsBusy,
                    ),
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

class InspectionSelectionCard extends StatelessWidget {
  const InspectionSelectionCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.scale,
    required this.onTap,
    this.subtitle,
    this.iconAsset,
    this.iconColor,
    this.leadingIndicatorAsset,
    this.leadingIconAsset,
    this.leadingIconWidth,
    this.leadingIconHeight,
    this.leadingIconRotation,
  });

  final String title;
  final String? subtitle;
  final bool isSelected;
  final double scale;
  final VoidCallback onTap;
  final String? iconAsset;
  final Color? iconColor;
  final String? leadingIndicatorAsset;
  final String? leadingIconAsset;
  final double? leadingIconWidth;
  final double? leadingIconHeight;
  final double? leadingIconRotation;

  @override
  Widget build(BuildContext context) {
    final titleColor = isSelected ? AppColors.green : AppColors.white;
    final subtitleColor = isSelected ? AppColors.green : AppColors.recentLabel;

    return Material(
      color: isSelected ? AppColors.white : AppColors.searchBackground,
      borderRadius: BorderRadius.circular(16 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIconAsset != null)
                Row(
                  children: [
                    Transform.rotate(
                      angle: leadingIconRotation ?? 0,
                      child: AppSvg(
                        asset: leadingIconAsset!,
                        width: (leadingIconWidth ?? 20) * scale,
                        height: (leadingIconHeight ?? 20) * scale,
                        color: isSelected ? AppColors.green : AppColors.white,
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      title,
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                )
              else if (leadingIndicatorAsset != null)
                Row(
                  children: [
                    AppSvg(
                      asset: leadingIndicatorAsset!,
                      width: 16 * scale,
                      height: 16 * scale,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      title,
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.0,
                      ),
                    ),
                  ],
                )
              else ...[
                if (iconAsset != null) ...[
                  AppSvg(
                    asset: iconAsset!,
                    width: 40 * scale,
                    height: 40 * scale,
                    color:
                        iconColor ??
                        (isSelected ? AppColors.green : AppColors.white),
                  ),
                  SizedBox(height: 8 * scale),
                ],
                Text(
                  title,
                  style: GoogleFonts.nataSans(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    height: 1.0,
                  ),
                ),
              ],
              if (subtitle != null) ...[
                SizedBox(height: 8 * scale),
                Text(
                  subtitle!,
                  style: GoogleFonts.nataSans(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
