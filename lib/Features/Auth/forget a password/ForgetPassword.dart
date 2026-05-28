import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../widgets/AppTextField.dart';
import '../widgets/AuthResponsiveShell.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPressed() {
    if (!_formKey.currentState!.validate()) return;

    context.read<InstitutionAuthCubit>().forgotPassword(
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InstitutionAuthCubit, InstitutionAuthState>(
      listener: (context, state) {
        if (state is InstitutionForgotPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Reset link sent to ${state.email}'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/ResetPassword', extra: state.email);
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
        title: 'Reset your password',
        subtitle: 'Enter your email and we’ll send a reset link.',
        sideTitle: 'Recover your institution access',
        sideSubtitle:
        'Use your official institution email to receive a recovery token and create a new password.',
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
                controller: _emailController,
                label: 'Official Email *',
                hint: 'contact@institution.com',
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  color: AppColors.iconGrey,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Email is required';
                  }
                  if (!v.contains('@')) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),
              Text(
                'Make sure this is the email you signed up with.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 28),
              BlocBuilder<InstitutionAuthCubit, InstitutionAuthState>(
                builder: (context, state) {
                  final isLoading = state is InstitutionAuthLoading;

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onResetPressed,
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
                        color: AppColors.white,
                      )
                          : const Text(
                        'Reset Password',
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
              'Remember your password? ',
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