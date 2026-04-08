import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../widgets/AppTextField.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

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
              content: Text(
                  '✅ Reset link sent to ${state.email}'),
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
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // 🔐 Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🧠 Title
                  const Text(
                    'Reset your\npassword',
                    style: AppTextStyles.largeTitle,
                  ),

                  const SizedBox(height: 16),

                  // 📄 Description
                  Text(
                    'Enter your email and we’ll send a reset link.',
                    style: AppTextStyles.description.copyWith(
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 📧 Label
                  const Text(
                    'Email Address',
                    style: AppTextStyles.fieldLabel,
                  ),

                  const SizedBox(height: 10),

                  // 📥 Input
                  CustomTextField(
                    controller: _emailController,
                    label: 'Official Email *',
                    hint: 'contact@institution.com',
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: AppColors.iconGrey,
                    ),
                    keyboardType:
                    TextInputType.emailAddress,
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

                  const SizedBox(height: 8),

                  Text(
                    'Make sure this is the email you signed up with.',
                    style: AppTextStyles.subtitle
                        .copyWith(fontSize: 13),
                  ),

                  const SizedBox(height: 40),

                  // 🔘 Button with loading state
                  BlocBuilder<InstitutionAuthCubit,
                      InstitutionAuthState>(
                    builder: (context, state) {
                      final isLoading =
                      state is InstitutionAuthLoading;

                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                          isLoading ? null : _onResetPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.textPrimary,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: AppColors.white,
                          )
                              : const Text(
                            'Reset Password',
                            style:
                            AppTextStyles.button,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // 🔁 Back to login
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          context.go('/institutionLogin'),
                      child: RichText(
                        text: TextSpan(
                          text:
                          'Remember your password? ',
                          style: AppTextStyles.description
                              .copyWith(
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Sign In',
                              style: AppTextStyles
                                  .underlineLink,
                            ),
                          ],
                        ),
                      ),
                    ),
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