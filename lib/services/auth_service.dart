import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

abstract interface class AuthService {
  bool get hasSession;
  String? get currentUserId;
  Stream<bool> get signedInChanges;

  Future<void> signInWithGoogle();
}

class SupabaseAuthService implements AuthService {
  const SupabaseAuthService();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  bool get hasSession => _client.auth.currentSession != null;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<bool> get signedInChanges {
    return _client.auth.onAuthStateChange
        .map((state) => state.session != null)
        .distinct();
  }

  @override
  Future<void> signInWithGoogle() async {
    final launched = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : SupabaseConfig.redirectTo,
    );

    if (!launched) {
      throw const AuthLaunchException();
    }
  }
}

class AuthLaunchException implements Exception {
  const AuthLaunchException();

  @override
  String toString() => 'Google sign-in could not be opened.';
}
