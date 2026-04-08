import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';

import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../widgets/AppTextField.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUpdatePassword() {
    if (!_formKey.currentState!.validate()) return;

    context.read<InstitutionAuthCubit>().resetPassword(
      email: widget.email, // ⚠️ مهم: لازم تبعته من ForgotPassword أو DeepLink
      token: _tokenController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InstitutionAuthCubit, InstitutionAuthState>(
      listener: (context, state) {

        if (state is InstitutionResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Password updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );

          context.go('/institutionLogin');
        }

        if (state is InstitutionAuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.error,
            ),
          );

          context.read<InstitutionAuthCubit>().reset();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text(
            'Reset Password',
            style: AppTextStyles.appBarTitle,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              'Enter the verification code and new password',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.description.copyWith(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // 🔢 TOKEN
                          CustomTextField(
                            controller: _tokenController,
                            label: 'Verification Token',
                            hint: 'Enter token',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Token is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // 🔒 NEW PASSWORD
                          CustomTextField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            hint: 'Enter New Password',
                            obscureText: _obscureNewPassword,
                            keyboardType:
                            TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword =
                                  !_obscureNewPassword;
                                });
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Min 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // 🔒 CONFIRM PASSWORD
                          CustomTextField(
                            controller:
                            _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Confirm New Password',
                            obscureText:
                            _obscureConfirmPassword,
                            keyboardType:
                            TextInputType.visiblePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.textPrimary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirm password';
                              }
                              if (v !=
                                  _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔘 BUTTON
                  BlocBuilder<InstitutionAuthCubit,
                      InstitutionAuthState>(
                    builder: (context, state) {
                      final isLoading =
                      state is InstitutionAuthLoading;

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : _onUpdatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(30),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            'Update Password',
                            style:
                            AppTextStyles.button,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}