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
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    return MenuFileSelection(name: file.name, sizeBytes: file.size);
  }
}
