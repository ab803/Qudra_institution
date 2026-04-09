import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../widgets/AppTextField.dart';
import '../widgets/AuthButton.dart';
import '../widgets/passwordField.dart';


class InstitutionLoginView extends StatefulWidget {
  const InstitutionLoginView({super.key});

  @override
  State<InstitutionLoginView> createState() =>
      _InstitutionLoginViewState();
}

class _InstitutionLoginViewState
    extends State<InstitutionLoginView> {
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
          context.go('/dashboard');
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
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Container(
                    width: 80,
                    height: 80,
                    child: Image.asset('assets/images/logo.png'),
                  ),

                  const SizedBox(height: 24),

                  Text('Institution Portal',
                      style: AppTextStyles.subtitle),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome',
                            style: AppTextStyles.screenTitle),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your institution account',
                          style: AppTextStyles.description,
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: _emailController,
                          label: 'Institution Email',
                          hint: 'contact@institution.com',
                          prefixIcon: const Icon(Icons.mail_outline,
                              color: AppColors.iconGrey),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return 'Enter valid email';
                            }
                            return null;
                          }, keyboardType: TextInputType.emailAddress,
                        ),

                        PasswordField(
                            controller: _passwordController),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.go('/ForgetPassword'),
                            child: const Text(
                                'Forgot Password?',
                                style: AppTextStyles.underlineLink),
                          ),
                        ),

                        const SizedBox(height: 24),

                        AuthButton(
                          label: 'Login',
                          onPressed: _onLoginPressed,
                          trailingIcon: const Icon(Icons.login,
                              color: AppColors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: AppTextStyles.description),
                      GestureDetector(
                        onTap: () =>
                            context.go('/institutionSignUp'),
                        child: const Text('Register',
                            style: AppTextStyles.underlineLink),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}