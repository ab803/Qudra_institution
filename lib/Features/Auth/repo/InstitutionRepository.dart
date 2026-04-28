import '../../../core/Models/institutionModel.dart';


abstract class IInstitutionRepository {
  Future<InstitutionModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String description,
    required String institutionType,
    required String location,
  });

  Future<InstitutionModel?> getCurrentProfile();

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });

  Future<void> logout();
}