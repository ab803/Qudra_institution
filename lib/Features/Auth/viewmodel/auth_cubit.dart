import 'package:flutter_bloc/flutter_bloc.dart';
import '../repo/InstitutionRepository.dart';
import 'auth_state.dart';

class InstitutionAuthCubit extends Cubit<InstitutionAuthState> {
  final IInstitutionRepository _repository;

  // ✅ Constructor Injection (clean & correct)
  InstitutionAuthCubit(this._repository)
      : super(InstitutionAuthInitial());

  // ─────────────────────────────────────────
  // SIGN UP
  // ─────────────────────────────────────────
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String description,
    required String institutionType,
    required String location
  }) async {
    emit(InstitutionAuthLoading());
    try {
      final institution = await _repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        description: description,
        institutionType: institutionType,
        location: location,
      );

      emit(InstitutionSignUpSuccess(institution: institution));
    } catch (e) {
      emit(InstitutionAuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(InstitutionAuthLoading());
    try {
      await _repository.login(email: email, password: password);

      final profile = await _repository.getCurrentProfile();

      if (profile == null) {
        emit(InstitutionAuthFailure(
          errorMessage: 'Institution profile not found',
        ));
        return;
      }

      emit(InstitutionLoginSuccess(institution: profile));
    } catch (e) {
      emit(InstitutionAuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────
  Future<void> forgotPassword({
    required String email,
  }) async {
    emit(InstitutionAuthLoading());
    try {
      await _repository.forgotPassword(email: email);
      emit(InstitutionForgotPasswordSuccess(email: email));
    } catch (e) {
      emit(InstitutionAuthFailure(errorMessage: e.toString()));
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
    emit(InstitutionAuthLoading());
    try {
      await _repository.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );

      emit(InstitutionResetPasswordSuccess());
    } catch (e) {
      emit(InstitutionAuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    emit(InstitutionAuthLoading());
    try {
      await _repository.logout();
      emit(InstitutionLogoutSuccess());
    } catch (e) {
      emit(InstitutionAuthFailure(errorMessage: e.toString()));
    }
  }

  // ─────────────────────────────────────────
  // RESET STATE
  // ─────────────────────────────────────────
  void reset() => emit(InstitutionAuthInitial());
}