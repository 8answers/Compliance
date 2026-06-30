import 'nutritional_audit_report.dart';

class SavedNutritionalAudit {
  const SavedNutritionalAudit({
    required this.id,
    required this.auditNumber,
    required this.report,
    required this.createdAt,
  });

  final String id;
  final int auditNumber;
  final NutritionalAuditReport report;
  final DateTime createdAt;

  factory SavedNutritionalAudit.fromJson(Map<String, dynamic> json) {
    final reportJson = json['nutritional_report'];
    return SavedNutritionalAudit(
      id: json['id'].toString(),
      auditNumber: _intValue(json['audit_number']),
      report: NutritionalAuditReport.fromJson(
        reportJson is Map
            ? Map<String, dynamic>.from(reportJson)
            : const <String, dynamic>{},
      ),
      createdAt:
          DateTime.tryParse(json['report_created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static int _intValue(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
