import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../models/menu_file_selection.dart';

abstract interface class MenuFilePicker {
  Future<MenuFileSelection?> pickMenuFile();
}

class NativeMenuFilePicker implements MenuFilePicker {
  const NativeMenuFilePicker();

  static const _allowedExtensions = [
    'pdf',
    'xlsx',
    'xls',
    'jpg',
    'jpeg',
    'png',
    'gsheet',
    'csv',
    'heic',
  ];

  @override
  Future<MenuFileSelection?> pickMenuFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    return MenuFileSelection(
      name: file.name,
      sizeBytes: file.size,
      mimeType: _mimeTypeForName(file.name),
      base64Data: file.bytes == null ? null : base64Encode(file.bytes!),
    );
  }

  String _mimeTypeForName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'heic' => 'image/heic',
      'csv' => 'text/csv',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xls' => 'application/vnd.ms-excel',
      _ => 'application/octet-stream',
    };
  }
}
