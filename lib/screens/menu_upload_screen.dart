import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../models/menu_file_selection.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';

enum _MenuUploadState { empty, uploading, uploaded }

class MenuUploadScreen extends StatefulWidget {
  const MenuUploadScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<MenuUploadScreen> createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  _MenuUploadState _uploadState = _MenuUploadState.empty;
  MenuFileSelection? _selectedFile;
  Timer? _uploadTimer;
  double _uploadProgress = 0;
  bool _isSaving = false;
  String? _errorMessage;

  static const _horizontalPadding = 16.0;

  @override
  void dispose() {
    _uploadTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_uploadState == _MenuUploadState.uploading || _isSaving) {
      return;
    }

    final file = await AppServices.of(context).menuFilePicker.pickMenuFile();
    if (file == null || !mounted) {
      return;
    }

    _uploadTimer?.cancel();
    setState(() {
      _selectedFile = file;
      _uploadState = _MenuUploadState.uploading;
      _uploadProgress = 0.1;
      _errorMessage = null;
    });

    _uploadTimer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final nextProgress = _uploadProgress + 0.18;
      if (nextProgress >= 1) {
        timer.cancel();
        setState(() {
          _uploadProgress = 1;
          _uploadState = _MenuUploadState.uploaded;
        });
        return;
      }

      setState(() => _uploadProgress = nextProgress);
    });
  }

  void _removeFile() {
    if (_isSaving) {
      return;
    }

    _uploadTimer?.cancel();
    setState(() {
      _selectedFile = null;
      _uploadState = _MenuUploadState.empty;
      _uploadProgress = 0;
      _errorMessage = null;
    });
  }

  Future<void> _saveInspection() async {
    final selectedFile = _selectedFile;
    if (_uploadState != _MenuUploadState.uploaded ||
        selectedFile == null ||
        _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final draft = widget.draft.copyWith(
      menuFileName: selectedFile.name,
      menuFileSizeBytes: selectedFile.sizeBytes,
    );

    try {
      await AppServices.of(
        context,
      ).inspectionRepository.createInspection(draft);
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
        _errorMessage = 'Could not save inspection. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = _horizontalPadding * scale;
    final nextEnabled = _uploadState == _MenuUploadState.uploaded && !_isSaving;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: horizontalPadding),
                      child: InspectionFlowHeader(currentStep: 6, scale: scale),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Upload or Enter Menu',
                      style: GoogleFonts.nataSans(
                        fontSize: 24 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    Text(
                      'Provide the weekly/monthly menu. The AI will extract meal items, estimate nutrition, and run compliance analysis.',
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                        color: AppColors.recentLabel,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 39 * scale),
                    _MenuModeTabs(scale: scale),
                    SizedBox(height: 32 * scale),
                    if (_uploadState == _MenuUploadState.empty)
                      _EmptyUploadPanel(scale: scale, onBrowse: _pickFile)
                    else
                      _SelectedFileCard(
                        scale: scale,
                        file: _selectedFile!,
                        isUploading: _uploadState == _MenuUploadState.uploading,
                        progress: _uploadProgress,
                        onRemove: _removeFile,
                      ),
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
                    SizedBox(height: 132 * scale),
                  ],
                ),
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
                      enabled: nextEnabled,
                      isBusy: _isSaving,
                      onTap: nextEnabled ? _saveInspection : null,
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

class _MenuModeTabs extends StatelessWidget {
  const _MenuModeTabs({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.nataSans(
      fontSize: 20 * scale,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Upload File',
                textAlign: TextAlign.center,
                style: labelStyle.copyWith(color: AppColors.green),
              ),
            ),
            Expanded(
              child: Text(
                'Type Menu',
                textAlign: TextAlign.center,
                style: labelStyle.copyWith(color: AppColors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 7 * scale),
        Row(
          children: [
            Expanded(
              child: Container(height: 1 * scale, color: AppColors.green),
            ),
            Expanded(
              child: Container(height: 1 * scale, color: AppColors.white),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyUploadPanel extends StatelessWidget {
  const _EmptyUploadPanel({required this.scale, required this.onBrowse});

  final double scale;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: AppColors.white, scale: scale),
      child: SizedBox(
        height: 244 * scale,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.file_upload_outlined,
                size: 34 * scale,
                color: AppColors.white,
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Upload your file here',
                textAlign: TextAlign.center,
                style: GoogleFonts.nataSans(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Supports PDF, Excel (.xlsx), JPG, PNG,\nSheets (.gsheet), .csv, .HEIC',
                textAlign: TextAlign.center,
                style: GoogleFonts.nataSans(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w400,
                  color: AppColors.recentLabel,
                  height: 1.35,
                ),
              ),
              SizedBox(height: 30 * scale),
              _BrowseFileButton(scale: scale, onTap: onBrowse),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrowseFileButton extends StatelessWidget {
  const _BrowseFileButton({required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8 * scale),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 8 * scale,
          ),
          child: Text(
            'Browse File',
            textAlign: TextAlign.center,
            style: GoogleFonts.nataSans(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w400,
              color: AppColors.green,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedFileCard extends StatelessWidget {
  const _SelectedFileCard({
    required this.scale,
    required this.file,
    required this.isUploading,
    required this.progress,
    required this.onRemove,
  });

  final double scale;
  final MenuFileSelection file;
  final bool isUploading;
  final double progress;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (isUploading)
                _UploadingFileIcon(scale: scale)
              else
                _UploadedFileIcon(scale: scale),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                        color: AppColors.green,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      file.sizeLabel,
                      style: GoogleFonts.nataSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w400,
                        color: AppColors.green,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.close,
                  color: const Color(0xFFFF3B30),
                  size: 32 * scale,
                ),
              ),
            ],
          ),
          if (isUploading) ...[
            SizedBox(height: 16 * scale),
            ClipRRect(
              borderRadius: BorderRadius.circular(4 * scale),
              child: LinearProgressIndicator(
                minHeight: 4 * scale,
                value: progress.clamp(0, 1),
                backgroundColor: AppColors.recentLabel,
                color: AppColors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UploadingFileIcon extends StatelessWidget {
  const _UploadingFileIcon({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(color: AppColors.green, scale: scale),
      child: SizedBox(
        width: 50 * scale,
        height: 50 * scale,
        child: Icon(
          Icons.arrow_upward,
          color: AppColors.green,
          size: 28 * scale,
        ),
      ),
    );
  }
}

class _UploadedFileIcon extends StatelessWidget {
  const _UploadedFileIcon({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50 * scale,
      height: 50 * scale,
      child: Icon(
        Icons.insert_drive_file_outlined,
        color: AppColors.green,
        size: 50 * scale,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1 * scale
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    const gap = 4.0;

    void drawDashedLine(Offset start, Offset end) {
      final totalLength = (end - start).distance;
      final direction = (end - start) / totalLength;
      var distance = 0.0;

      while (distance < totalLength) {
        final segmentLength = (distance + dash).clamp(0.0, totalLength);
        canvas.drawLine(
          start + direction * distance,
          start + direction * segmentLength,
          paint,
        );
        distance += dash + gap;
      }
    }

    drawDashedLine(Offset.zero, Offset(size.width, 0));
    drawDashedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawDashedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawDashedLine(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color || scale != oldDelegate.scale;
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color, required this.scale});

  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2 * scale
      ..style = PaintingStyle.stroke;
    const dashRadians = 0.28;
    const gapRadians = 0.16;
    final rect = Offset.zero & size;
    var angle = -1.5708;

    while (angle < 4.7124) {
      canvas.drawArc(rect.deflate(1 * scale), angle, dashRadians, false, paint);
      angle += dashRadians + gapRadians;
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) {
    return color != oldDelegate.color || scale != oldDelegate.scale;
  }
}
