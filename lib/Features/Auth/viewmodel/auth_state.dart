import 'package:flutter/cupertino.dart';
import '../../../core/Models/institutionModel.dart';


@immutable
abstract class InstitutionAuthState {}

class InstitutionAuthInitial    extends InstitutionAuthState {}
class InstitutionAuthLoading    extends InstitutionAuthState {}
class InstitutionLogoutSuccess  extends InstitutionAuthState {}

class InstitutionSignUpSuccess extends InstitutionAuthState {
  final InstitutionModel institution;
  InstitutionSignUpSuccess({required this.institution});
}

class InstitutionLoginSuccess extends InstitutionAuthState {
  final InstitutionModel institution;
  InstitutionLoginSuccess({required this.institution});
}

class InstitutionForgotPasswordSuccess extends InstitutionAuthState {
  final String email;
  InstitutionForgotPasswordSuccess({required this.email});
}

class InstitutionResetPasswordSuccess extends InstitutionAuthState {}

class InstitutionAuthFailure extends InstitutionAuthState {
  final String errorMessage;
  InstitutionAuthFailure({required this.errorMessage});
}