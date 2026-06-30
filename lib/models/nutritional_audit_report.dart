class NutritionalAuditReport {
  const NutritionalAuditReport({
    required this.complianceScore,
    required this.nutritionScore,
    required this.mealDiversityScore,
    required this.nutrientAnalysis,
    required this.foodGroupCoverage,
    required this.deficiencies,
    required this.recommendations,
  });

  final int complianceScore;
  final int nutritionScore;
  final int mealDiversityScore;
  final List<NutrientAnalysisItem> nutrientAnalysis;
  final List<FoodGroupCoverageItem> foodGroupCoverage;
  final List<String> deficiencies;
  final List<String> recommendations;

  double get averageScore {
    return (complianceScore + nutritionScore) / 2;
  }

  bool get hasGeneratedContent {
    return complianceScore > 0 ||
        nutritionScore > 0 ||
        mealDiversityScore > 0 ||
        nutrientAnalysis.isNotEmpty ||
        foodGroupCoverage.isNotEmpty ||
        deficiencies.isNotEmpty ||
        recommendations.isNotEmpty;
  }

  String get grade {
    final score = averageScore;
    if (score > 95) {
      return 'A';
    }
    if (score > 85) {
      return 'B';
    }
    if (score > 75) {
      return 'C';
    }
    if (score > 50) {
      return 'D';
    }
    return 'F';
  }

  factory NutritionalAuditReport.fromJson(Map<String, dynamic> json) {
    final source = json['report'] is Map<String, dynamic>
        ? json['report'] as Map<String, dynamic>
        : json;

    return NutritionalAuditReport(
      complianceScore: _boundedScore(source['complianceScore']),
      nutritionScore: _boundedScore(source['nutritionScore']),
      mealDiversityScore: _boundedScore(source['mealDiversityScore']),
      nutrientAnalysis: _nutrientsFromJson(source['nutrientAnalysis']),
      foodGroupCoverage: _foodGroupsFromJson(source['foodGroupCoverage']),
      deficiencies: _stringList(source['deficiencies']),
      recommendations: _stringList(source['recommendations']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'complianceScore': complianceScore,
      'nutritionScore': nutritionScore,
      'mealDiversityScore': mealDiversityScore,
      'nutrientAnalysis': [for (final item in nutrientAnalysis) item.toJson()],
      'foodGroupCoverage': [
        for (final item in foodGroupCoverage) item.toJson(),
      ],
      'deficiencies': deficiencies,
      'recommendations': recommendations,
    };
  }

  static List<NutrientAnalysisItem> _nutrientsFromJson(Object? value) {
    if (value is! List) {
      return const [];
    }

    return [
      for (final item in value)
        if (item is Map)
          NutrientAnalysisItem.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  static List<FoodGroupCoverageItem> _foodGroupsFromJson(Object? value) {
    if (value is! List) {
      return const [];
    }

    return [
      for (final item in value)
        if (item is Map)
          FoodGroupCoverageItem.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return [
      for (final item in value)
        if (item.toString().trim().isNotEmpty) item.toString().trim(),
    ];
  }

  static int _boundedScore(Object? value) {
    final score = _numberValue(value).round();
    return score.clamp(0, 100);
  }

  static double _numberValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final normalized = value.replaceAll('%', '').trim();
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }
}

class NutrientAnalysisItem {
  const NutrientAnalysisItem({
    required this.name,
    required this.requiredAmount,
    required this.estimatedAmount,
    required this.compliancePercent,
  });

  final String name;
  final String requiredAmount;
  final String estimatedAmount;
  final double compliancePercent;

  factory NutrientAnalysisItem.fromJson(Map<String, dynamic> json) {
    return NutrientAnalysisItem(
      name: _text(json['name']),
      requiredAmount: _text(json['required']),
      estimatedAmount: _text(json['estimated']),
      compliancePercent: NutritionalAuditReport._numberValue(
        json['compliancePercent'],
      ).clamp(0, 200),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'required': requiredAmount,
      'estimated': estimatedAmount,
      'compliancePercent': compliancePercent,
    };
  }
}

class FoodGroupCoverageItem {
  const FoodGroupCoverageItem({
    required this.name,
    required this.totalPercent,
    required this.compliantPercent,
  });

  final String name;
  final double totalPercent;
  final double compliantPercent;

  factory FoodGroupCoverageItem.fromJson(Map<String, dynamic> json) {
    return FoodGroupCoverageItem(
      name: _text(json['name']),
      totalPercent: 100,
      compliantPercent: NutritionalAuditReport._numberValue(
        json['compliantPercent'],
      ).clamp(0, 100),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalPercent': totalPercent,
      'compliantPercent': compliantPercent,
    };
  }
}

String _text(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? '-' : text;
}
