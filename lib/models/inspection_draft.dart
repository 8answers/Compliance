class InspectionDraft {
  const InspectionDraft({
    this.institutionType,
    this.ageGroups = const [],
    this.dietTypes = const [],
    this.mealsServed = const [],
    this.region,
    this.menuFileName,
    this.menuFileSizeBytes,
  });

  final String? institutionType;
  final List<String> ageGroups;
  final List<String> dietTypes;
  final List<String> mealsServed;
  final String? region;
  final String? menuFileName;
  final int? menuFileSizeBytes;

  InspectionDraft copyWith({
    String? institutionType,
    List<String>? ageGroups,
    List<String>? dietTypes,
    List<String>? mealsServed,
    String? region,
    String? menuFileName,
    int? menuFileSizeBytes,
  }) {
    return InspectionDraft(
      institutionType: institutionType ?? this.institutionType,
      ageGroups: ageGroups ?? this.ageGroups,
      dietTypes: dietTypes ?? this.dietTypes,
      mealsServed: mealsServed ?? this.mealsServed,
      region: region ?? this.region,
      menuFileName: menuFileName ?? this.menuFileName,
      menuFileSizeBytes: menuFileSizeBytes ?? this.menuFileSizeBytes,
    );
  }

  Map<String, dynamic> toInsert({required String userId}) {
    final selectedInstitutionType = institutionType;
    final selectedRegion = region;
    final selectedMenuFileName = menuFileName;
    final selectedMenuFileSizeBytes = menuFileSizeBytes;

    if (selectedInstitutionType == null ||
        selectedInstitutionType.isEmpty ||
        ageGroups.isEmpty ||
        dietTypes.isEmpty ||
        mealsServed.isEmpty ||
        selectedRegion == null ||
        selectedRegion.isEmpty ||
        selectedMenuFileName == null ||
        selectedMenuFileName.isEmpty ||
        selectedMenuFileSizeBytes == null) {
      throw StateError('Inspection draft is incomplete.');
    }

    return {
      'created_by': userId,
      'institution_type': selectedInstitutionType,
      'age_groups': ageGroups,
      'diet_types': dietTypes,
      'meals_served': mealsServed,
      'region': selectedRegion,
      'menu_entry_method': 'upload_file',
      'menu_file_name': selectedMenuFileName,
      'menu_file_size_bytes': selectedMenuFileSizeBytes,
    };
  }
}
