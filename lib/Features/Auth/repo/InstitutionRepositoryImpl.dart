import '../../../core/Models/institutionModel.dart';
import '../../../core/supabase/institutionservice.dart';
import 'InstitutionRepository.dart';

class InstitutionRepositoryImpl implements IInstitutionRepository {
  final InstitutionService _service;

  InstitutionRepositoryImpl({required InstitutionService service})
      : _service = service;

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  @override
  Future<InstitutionModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String description,
    required String institutionType,
    required String location,
  }) async {

    return await _service.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      address: address,
      description: description,
      institutionType: institutionType,
      location: location,
    );
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _service.login(email: email, password: password);
  }

  // ─────────────────────────────────────────
  // GET CURRENT PROFILE
  // ─────────────────────────────────────────
  @override
  Future<InstitutionModel?> getCurrentProfile() async {
    return await _service.getCurrentProfile();
  }

  // ─────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────
  @override
  Future<void> forgotPassword({required String email}) async {
    await _service.forgotPassword(email: email);
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────
  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await _service.resetPassword(
      email:       email,
      token:       token,
      newPassword: newPassword,
    );
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  @override
  Future<void> logout() async {
    await _service.logout();
  }
}