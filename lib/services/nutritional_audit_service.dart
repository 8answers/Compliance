import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection_draft.dart';
import '../models/nutritional_audit_report.dart';

abstract interface class NutritionalAuditService {
  Future<NutritionalAuditReport> generateReport(InspectionDraft draft);
}

class NutritionalAuditException implements Exception {
  const NutritionalAuditException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SupabaseNutritionalAuditService implements NutritionalAuditService {
  const SupabaseNutritionalAuditService();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<NutritionalAuditReport> generateReport(InspectionDraft draft) async {
    try {
      final response = await _client.functions.invoke(
        'generate-nutritional-audit',
        body: {'draft': _draftPayload(draft)},
      );
      final data = response.data;
      if (data is Map) {
        final report = NutritionalAuditReport.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (report.hasGeneratedContent) {
          return report;
        }
        throw const NutritionalAuditException(
          'Gemini returned an empty audit report.',
        );
      }

      throw const NutritionalAuditException(
        'Invalid response from nutritional audit service.',
      );
    } catch (error) {
      if (error is NutritionalAuditException) {
        rethrow;
      }
      throw NutritionalAuditException(_friendlyMessage(error));
    }
  }

  Map<String, dynamic> _draftPayload(InspectionDraft draft) {
    return {
      'institutionType': draft.institutionType,
      'ageGroups': draft.ageGroups,
      'dietTypes': draft.dietTypes,
      'mealsServed': draft.mealsServed,
      'region': draft.region,
      'menuEntryMethod': draft.menuEntryMethod,
      'menuFileName': draft.menuFileName,
      'menuFileMimeType': draft.menuFileMimeType,
      'menuFileBase64Data': draft.menuFileBase64Data,
      'menuText': draft.menuText,
    };
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.contains('GEMINI_API_KEY is not configured')) {
      return 'Gemini API key is not configured on Supabase.';
    }
    if (text.contains('Function not found') ||
        text.contains('404') ||
        text.contains('generate-nutritional-audit')) {
      return 'Supabase audit function is not deployed.';
    }
    if (text.contains('Gemini audit generation failed')) {
      return 'Gemini could not generate the audit. Check the API key and model.';
    }
    if (text.contains('Failed host lookup') ||
        text.contains('SocketException')) {
      return 'Network error while generating nutritional audit.';
    }
    return 'Could not generate nutritional audit. Please try again.';
  }
}
