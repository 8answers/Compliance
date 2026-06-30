import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection_draft.dart';
import '../models/nutritional_audit_report.dart';
import '../models/saved_nutritional_audit.dart';

abstract interface class InspectionRepository {
  Future<String> createInspection(InspectionDraft draft);
  Future<SavedNutritionalAudit> saveNutritionalAuditReport({
    required String inspectionId,
    required NutritionalAuditReport report,
  });
  Future<List<SavedNutritionalAudit>> fetchSavedAudits();
  Future<void> deleteNutritionalAudit(String inspectionId);
}

class SupabaseInspectionRepository implements InspectionRepository {
  const SupabaseInspectionRepository();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<String> createInspection(InspectionDraft draft) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save an inspection.');
    }

    final row = await _client
        .from('inspections')
        .insert(draft.toInsert(userId: userId))
        .select('id')
        .single();
    return row['id'].toString();
  }

  @override
  Future<SavedNutritionalAudit> saveNutritionalAuditReport({
    required String inspectionId,
    required NutritionalAuditReport report,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save an audit report.');
    }

    final existing = await _client
        .from('inspections')
        .select('audit_number')
        .eq('id', inspectionId)
        .eq('created_by', userId)
        .single();
    final existingAuditNumber = _intValue(existing['audit_number']);
    final auditNumber = existingAuditNumber > 0
        ? existingAuditNumber
        : await _nextAuditNumber(userId);

    final row = await _client
        .from('inspections')
        .update({
          'audit_number': auditNumber,
          'nutritional_report': report.toJson(),
          'report_created_at': DateTime.now().toUtc().toIso8601String(),
          'report_deleted_at': null,
        })
        .eq('id', inspectionId)
        .eq('created_by', userId)
        .select(
          'id,audit_number,nutritional_report,report_created_at,created_at',
        )
        .single();

    return SavedNutritionalAudit.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<List<SavedNutritionalAudit>> fetchSavedAudits() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const [];
    }

    final rows = await _client
        .from('inspections')
        .select(
          'id,audit_number,nutritional_report,report_created_at,created_at',
        )
        .eq('created_by', userId)
        .not('nutritional_report', 'is', null)
        .isFilter('report_deleted_at', null)
        .order('audit_number', ascending: false);

    return [
      for (final row in rows)
        SavedNutritionalAudit.fromJson(Map<String, dynamic>.from(row)),
    ];
  }

  @override
  Future<void> deleteNutritionalAudit(String inspectionId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to delete an audit report.');
    }

    await _client
        .from('inspections')
        .update({'report_deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', inspectionId)
        .eq('created_by', userId);
  }

  Future<int> _nextAuditNumber(String userId) async {
    final rows = await _client
        .from('inspections')
        .select('audit_number')
        .eq('created_by', userId)
        .not('audit_number', 'is', null)
        .order('audit_number', ascending: false)
        .limit(1);
    if (rows.isEmpty) {
      return 1;
    }

    return _intValue(rows.first['audit_number']) + 1;
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
