class InspectionDraft {
  const InspectionDraft({
    this.institutionType,
    this.ageGroups = const [],
    this.dietTypes = const [],
    this.mealsServed = const [],
    this.region,
    this.menuEntryMethod,
    this.menuFileName,
    this.menuFileSizeBytes,
    this.menuText,
  });

  static const uploadFileMethod = 'upload_file';
  static const typedMenuMethod = 'typed_menu';

  final String? institutionType;
  final List<String> ageGroups;
  final List<String> dietTypes;
  final List<String> mealsServed;
  final String? region;
  final String? menuEntryMethod;
  final String? menuFileName;
  final int? menuFileSizeBytes;
  final String? menuText;

  InspectionDraft copyWith({
    String? institutionType,
    List<String>? ageGroups,
    List<String>? dietTypes,
    List<String>? mealsServed,
    String? region,
    String? menuEntryMethod,
    String? menuFileName,
    int? menuFileSizeBytes,
    String? menuText,
  }) {
    return InspectionDraft(
      institutionType: institutionType ?? this.institutionType,
      ageGroups: ageGroups ?? this.ageGroups,
      dietTypes: dietTypes ?? this.dietTypes,
      mealsServed: mealsServed ?? this.mealsServed,
      region: region ?? this.region,
      menuEntryMethod: menuEntryMethod ?? this.menuEntryMethod,
      menuFileName: menuFileName ?? this.menuFileName,
      menuFileSizeBytes: menuFileSizeBytes ?? this.menuFileSizeBytes,
      menuText: menuText ?? this.menuText,
    );
  }

  Map<String, dynamic> toInsert({required String userId}) {
    final selectedInstitutionType = institutionType;
    final selectedRegion = region;
    final selectedMenuEntryMethod = menuEntryMethod;

    if (selectedInstitutionType == null ||
        selectedInstitutionType.isEmpty ||
        ageGroups.isEmpty ||
        dietTypes.isEmpty ||
        mealsServed.isEmpty ||
        selectedRegion == null ||
        selectedRegion.isEmpty ||
        selectedMenuEntryMethod == null ||
        selectedMenuEntryMethod.isEmpty) {
      throw StateError('Inspection draft is incomplete.');
    }

    final row = {
      'created_by': userId,
      'institution_type': selectedInstitutionType,
      'age_groups': ageGroups,
      'diet_types': dietTypes,
      'meals_served': mealsServed,
      'region': selectedRegion,
      'menu_entry_method': selectedMenuEntryMethod,
    };

    if (selectedMenuEntryMethod == uploadFileMethod) {
      final selectedMenuFileName = menuFileName;
      final selectedMenuFileSizeBytes = menuFileSizeBytes;
      if (selectedMenuFileName == null ||
          selectedMenuFileName.isEmpty ||
          selectedMenuFileSizeBytes == null) {
        throw StateError('Inspection draft is missing the uploaded menu file.');
      }

      row.addAll({
        'menu_file_name': selectedMenuFileName,
        'menu_file_size_bytes': selectedMenuFileSizeBytes,
      });
    } else if (selectedMenuEntryMethod == typedMenuMethod) {
      final selectedMenuText = menuText?.trim();
      if (selectedMenuText == null || selectedMenuText.isEmpty) {
        throw StateError('Inspection draft is missing typed menu text.');
      }

      row['menu_text'] = selectedMenuText;
    } else {
      throw StateError('Unsupported menu entry method.');
    }

    return {...row};
  }
}
