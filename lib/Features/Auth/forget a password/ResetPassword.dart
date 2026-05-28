import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../widgets/AppTextField.dart';
import '../widgets/AuthResponsiveShell.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
      email: widget.email,
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
      child: AuthResponsiveShell(
        title: 'Create new password',
        subtitle: 'Enter the verification code and your new password.',
        sideTitle: 'Secure your institution account',
        sideSubtitle:
        'Use the recovery token sent to your email, then set a new secure password for the portal.',
        logo: Image.asset(
          'assets/images/Qudra_Institution_logo.png',
          fit: BoxFit.contain,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _tokenController,
                label: 'Verification Token',
                hint: 'Enter token',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Icons.pin_outlined,
                  color: AppColors.iconGrey,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Token is required';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _newPasswordController,
                label: 'New Password',
                hint: 'Enter New Password',
                obscureText: _obscureNewPassword,
                keyboardType: TextInputType.visiblePassword,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.iconGrey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
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
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                hint: 'Confirm New Password',
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                prefixIcon: const Icon(
                  Icons.lock_reset_outlined,
                  color: AppColors.iconGrey,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Confirm password';
                  }
                  if (v != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              BlocBuilder<InstitutionAuthCubit, InstitutionAuthState>(
                builder: (context, state) {
                  final isLoading = state is InstitutionAuthLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onUpdatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        'Update Password',
                        style: AppTextStyles.button,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        footer: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Back to ',
              style: AppTextStyles.description,
            ),
            GestureDetector(
              onTap: () => context.go('/institutionLogin'),
              child: const Text(
                'Sign In',
                style: AppTextStyles.underlineLink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}