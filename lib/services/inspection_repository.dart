import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/inspection_draft.dart';

abstract interface class InspectionRepository {
  Future<void> createInspection(InspectionDraft draft);
}

class SupabaseInspectionRepository implements InspectionRepository {
  const SupabaseInspectionRepository();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<void> createInspection(InspectionDraft draft) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('You must be signed in to save an inspection.');
    }

    await _client.from('inspections').insert(draft.toInsert(userId: userId));
  }
}
