import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/institutionModel.dart';

class InstitutionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  Future<InstitutionModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String institutionType,
    required String location,
  }) async {
    try {
      // ✅ Step 1: Create auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // ✅ FIX: Get userId safely
      final userId = authResponse.user!.id;



      // ✅ Step 2: Insert into institutions table
      final data = InstitutionModel(
         id : userId,
         createdAt: DateTime.now(),
         name: name,
         email: email,
         phone: phone,
         address: address,
         institutionType : institutionType,
         location: location,
      );

      await _supabase.from('institutions').upsert(data.toJson());

      return data;
    } on AuthException catch (e) {
      throw Exception('Registration error: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // GET CURRENT PROFILE
  // ─────────────────────────────────────────
  Future<InstitutionModel?> getCurrentProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('institutions')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return InstitutionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Failed to fetch profile: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────
  Future<void> forgotPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Reset password failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  User? get currentUser => _supabase.auth.currentUser;

  bool get isLoggedIn => _supabase.auth.currentUser != null;
}