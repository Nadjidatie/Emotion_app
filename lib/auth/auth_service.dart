import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient _client = Supabase.instance.client;

  //sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email, 
      password: password
      );
  }

  //sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await _client.auth.signUp(
      email: email, 
      password: password
      );
  }

  
  // sign out 
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  //get user email 
  String? getCurrentUserEmail(){
    final session = _client.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.emotion.app://login-callback/',
    );
  }
}