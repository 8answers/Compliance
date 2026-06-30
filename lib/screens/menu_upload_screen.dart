import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/inspection_draft.dart';
import '../models/menu_file_selection.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/home_indicator.dart';
import '../widgets/inspection_widgets.dart';
import 'inspection_summary_screen.dart';

enum _MenuInputMode { uploadFile, typeMenu }

enum _MenuUploadState { empty, uploading, uploaded }

class MenuUploadScreen extends StatefulWidget {
  const MenuUploadScreen({super.key, required this.draft});

  final InspectionDraft draft;

  @override
  State<MenuUploadScreen> createState() => _MenuUploadScreenState();
}

class _MenuUploadScreenState extends State<MenuUploadScreen> {
  final _typedMenuController = TextEditingController();
  _MenuInputMode _inputMode = _MenuInputMode.uploadFile;
  _MenuUploadState _uploadState = _MenuUploadState.empty;
  MenuFileSelection? _selectedFile;
  Timer? _uploadTimer;
  double _uploadProgress = 0;

  static const _horizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _typedMenuController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _typedMenuController.dispose();
    _uploadTimer?.cancel();
    super.dispose();
  }

  bool get _canContinue {
    return switch (_inputMode) {
      _MenuInputMode.uploadFile => _uploadState == _MenuUploadState.uploaded,
      _MenuInputMode.typeMenu => _typedMenuController.text.trim().isNotEmpty,
    };
  }

  Future<void> _pickFile() async {
    if (_uploadState == _MenuUploadState.uploading) {
      return;
    }

    final file = await AppServices.of(context).menuFilePicker.pickMenuFile();
    if (file == null || !mounted) {
      return;
    }

    _uploadTimer?.cancel();
    setState(() {
      _inputMode = _MenuInputMode.uploadFile;
      _selectedFile = file;
      _uploadState = _MenuUploadState.uploading;
      _uploadProgress = 0.1;
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
    _uploadTimer?.cancel();
    setState(() {
      _selectedFile = null;
      _uploadState = _MenuUploadState.empty;
      _uploadProgress = 0;
    });
  }

  void _openSummary() {
    if (!_canContinue) {
      return;
    }

    final draft = switch (_inputMode) {
      _MenuInputMode.uploadFile => widget.draft.copyWith(
        menuEntryMethod: InspectionDraft.uploadFileMethod,
        menuFileName: _selectedFile!.name,
        menuFileSizeBytes: _selectedFile!.sizeBytes,
        menuFileMimeType: _selectedFile!.mimeType,
        menuFileBase64Data: _selectedFile!.base64Data,
      ),
      _MenuInputMode.typeMenu => widget.draft.copyWith(
        menuEntryMethod: InspectionDraft.typedMenuMethod,
        menuText: _typedMenuController.text.trim(),
      ),
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InspectionSummaryScreen(draft: draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = designScale(context);
    final horizontalPadding = _horizontalPadding * scale;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    SizedBox(height: 16 * scale),
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
                    _MenuModeTabs(
                      scale: scale,
                      inputMode: _inputMode,
                      onModeChanged: (mode) {
                        setState(() => _inputMode = mode);
                      },
                    ),
                    SizedBox(height: 16 * scale),
                    if (_inputMode == _MenuInputMode.uploadFile) ...[
                      SizedBox(height: 16 * scale),
                      if (_uploadState == _MenuUploadState.empty)
                        _EmptyUploadPanel(scale: scale, onBrowse: _pickFile)
                      else
                        SelectedMenuFileCard(
                          scale: scale,
                          file: _selectedFile!,
                          isUploading:
                              _uploadState == _MenuUploadState.uploading,
                          progress: _uploadProgress,
                          onRemove: _removeFile,
                        ),
                    ] else
                      _TypedMenuInput(
                        scale: scale,
                        controller: _typedMenuController,
                      ),
                    SizedBox(height: 132 * scale),
                  ],
                ),
              ),
            ),
            InspectionBottomActions(
              scale: scale,
              nextEnabled: _canContinue,
              onBack: () => Navigator.of(context).pop(),
              onNext: _canContinue ? _openSummary : null,
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
  const _MenuModeTabs({
    required this.scale,
    required this.inputMode,
    required this.onModeChanged,
  });

  final double scale;
  final _MenuInputMode inputMode;
  final ValueChanged<_MenuInputMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.nataSans(
      fontSize: 20 * scale,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );

    Widget tab({required _MenuInputMode mode, required String label}) {
      final selected = inputMode == mode;
      return Expanded(
        child: InkWell(
          onTap: () => onModeChanged(mode),
          child: Padding(
            padding: EdgeInsets.only(bottom: 7 * scale),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: labelStyle.copyWith(
                color: selected ? AppColors.green : AppColors.white,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            tab(mode: _MenuInputMode.uploadFile, label: 'Upload File'),
            tab(mode: _MenuInputMode.typeMenu, label: 'Type Menu'),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1 * scale,
                color: inputMode == _MenuInputMode.uploadFile
                    ? AppColors.green
                    : AppColors.white,
              ),
            ),
            Expanded(
              child: Container(
                height: 1 * scale,
                color: inputMode == _MenuInputMode.typeMenu
                    ? AppColors.green
                    : AppColors.white,
              ),
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

class _TypedMenuInput extends StatelessWidget {
  const _TypedMenuInput({required this.scale, required this.controller});

  final double scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 378 * scale,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white, width: 1 * scale),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 8 * scale,
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        expands: true,
        maxLines: null,
        minLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: AppColors.white,
        style: GoogleFonts.nataSans(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w400,
          color: AppColors.white,
          height: 1.35,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText:
              'Paste or type the menu here...\n\nExample:\nMonday\nBreakfast: Upma, Banana, Milk\nLunch: Chapati, Aloo Sabzi, Rice, Palak Dal,\nButter Milk\n...',
          hintStyle: GoogleFonts.nataSans(
            fontSize: 16 * scale,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF313131),
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class SelectedMenuFileCard extends StatelessWidget {
  const SelectedMenuFileCard({
    super.key,
    required this.scale,
    required this.file,
    this.isUploading = false,
    this.progress = 1,
    this.onRemove,
  });

  final double scale;
  final MenuFileSelection file;
  final bool isUploading;
  final double progress;
  final VoidCallback? onRemove;

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
              if (onRemove != null)
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
