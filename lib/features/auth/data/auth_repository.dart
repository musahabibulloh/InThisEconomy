import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // 1. Bypass Supabase default email limits using custom RPC
    await _client.rpc('register_fake_user', params: {
      'email_input': email,
      'password_input': password,
      'display_name_input': displayName ?? email.split('@').first,
    });

    // 2. Log in immediately since the user is auto-confirmed in DB
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final data =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return data;
  }
}
