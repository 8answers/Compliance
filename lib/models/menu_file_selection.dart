class MenuFileSelection {
  const MenuFileSelection({required this.name, required this.sizeBytes});

  final String name;
  final int sizeBytes;

  String get sizeLabel {
    if (sizeBytes <= 0) {
      return '0 KB';
    }

    const bytesPerKb = 1024;
    const bytesPerMb = bytesPerKb * 1024;

    if (sizeBytes >= bytesPerMb) {
      final megabytes = sizeBytes / bytesPerMb;
      if (megabytes >= 10 || megabytes == megabytes.roundToDouble()) {
        return '${megabytes.round()} MB';
      }
      return '${megabytes.toStringAsFixed(1)} MB';
    }

    final kilobytes = sizeBytes / bytesPerKb;
    return '${kilobytes.ceil()} KB';
  }
}
