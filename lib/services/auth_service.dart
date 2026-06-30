import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

abstract interface class AuthService {
  bool get hasSession;
  String? get currentUserId;
  Stream<bool> get signedInChanges;

  Future<void> signInWithGoogle();
  Future<void> deleteAccount();
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

  @override
  Future<void> deleteAccount() async {
    if (!hasSession) {
      throw const AuthDeleteAccountException(
        'Please sign in again before deleting your account.',
      );
    }

    try {
      final response = await _client.functions.invoke('delete-account');
      final data = response.data;
      if (data is Map && data['deleted'] == true) {
        await _signOutAfterDelete();
        return;
      }

      if (data is Map && data['error'] != null) {
        throw AuthDeleteAccountException(data['error'].toString());
      }

      throw const AuthDeleteAccountException(
        'Invalid response from delete account service.',
      );
    } catch (error) {
      if (error is AuthDeleteAccountException) {
        rethrow;
      }

      throw AuthDeleteAccountException(_deleteAccountMessage(error));
    }
  }

  Future<void> _signOutAfterDelete() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      return;
    }
  }

  String _deleteAccountMessage(Object error) {
    final text = error.toString();
    if (text.contains('Missing authorization token') ||
        text.contains('User not found') ||
        text.contains('Not authenticated') ||
        text.contains('401')) {
      return 'Please sign in again before deleting your account.';
    }
    if (text.contains('Function not found') ||
        text.contains('404') ||
        text.contains('delete-account')) {
      return 'Supabase delete account function is not deployed.';
    }
    if (text.contains('SUPABASE_SERVICE_ROLE_KEY') ||
        text.contains('SUPABASE_URL')) {
      return 'Supabase delete account service is not configured.';
    }
    if (text.contains('Failed host lookup') ||
        text.contains('SocketException')) {
      return 'Network error while deleting account.';
    }
    return 'Could not delete account. Please try again.';
  }
}

class AuthLaunchException implements Exception {
  const AuthLaunchException();

  @override
  String toString() => 'Google sign-in could not be opened.';
}

class AuthDeleteAccountException implements Exception {
  const AuthDeleteAccountException(this.message);

  final String message;

  @override
  String toString() => message;
}
