import 'package:flutter/material.dart';
import '../../../core/responsive/responsive_helper.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../widgets/AppTextField.dart';
import '../widgets/AuthButton.dart';
import '../widgets/AuthResponsiveShell.dart';
import '../widgets/passwordField.dart';
import 'helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InstitutionLoginView extends StatefulWidget {
  const InstitutionLoginView({super.key});

  @override
  State<InstitutionLoginView> createState() => _InstitutionLoginViewState();
}

class _InstitutionLoginViewState extends State<InstitutionLoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;

    context.read<InstitutionAuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InstitutionAuthCubit, InstitutionAuthState>(
      listener: (context, state) {
        if (state is InstitutionLoginSuccess) {
          checkInstitutionStatus(context);
        } else if (state is InstitutionAuthFailure) {
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
        title: 'Welcome',
        subtitle: 'Sign in to your institution account',
        logo: Image.asset(
          ResponsiveHelper.isDesktop(context)
              ? 'assets/images/Qudra_logo_Dark_mode.png'
              : 'assets/images/Qudra_Institution_logo.png',
          fit: BoxFit.contain,
        ),
        footer: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: AppTextStyles.description,
            ),
            GestureDetector(
              onTap: () => context.go('/institutionSignUp'),
              child: const Text(
                'Register',
                style: AppTextStyles.underlineLink,
              ),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _emailController,
                label: 'Institution Email',
                hint: 'contact@institution.com',
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  color: AppColors.iconGrey,
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Email is required';
                  }
                  if (!v.contains('@')) {
                    return 'Enter valid email';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              PasswordField(
                controller: _passwordController,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/ForgetPassword'),
                  child: const Text(
                    'Forgot Password?',
                    style: AppTextStyles.underlineLink,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AuthButton(
                label: 'Login',
                onPressed: _onLoginPressed,
                trailingIcon: const Icon(
                  Icons.login,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
