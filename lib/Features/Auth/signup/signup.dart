import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/styles/AppColors.dart';
import '../../../core/styles/AppTextStyles.dart';
import '../ViewModel/auth_cubit.dart';
import '../ViewModel/auth_state.dart';
import '../widgets/AppTextField.dart';
import '../widgets/AuthButton.dart';

class InstitutionSignUpView extends StatefulWidget {
  const InstitutionSignUpView({super.key});

  @override
  State<InstitutionSignUpView> createState() => _InstitutionSignUpViewState();
}

class _InstitutionSignUpViewState extends State<InstitutionSignUpView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedType;

  static const _institutionTypes = [
    'Hospital / Clinic',
    'Rehabilitation Center',
    'School / Education',
    'NGO / Charity',
    'Government Body',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<InstitutionAuthCubit>().signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      institutionType: _selectedType!,
      location: _locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InstitutionAuthCubit, InstitutionAuthState>(
      listener: (context, state) {
        if (state is InstitutionSignUpSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            // This success message tells the institution user to verify the email before logging in.
            const SnackBar(
              content: Text(
                '✅ Registration successful. Please check your email, verify your account, then log in.',
              ),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 4),
            ),
          );

          // This redirects the user to the login screen instead of opening the dashboard without a confirmed session.
          context.go('/institutionLogin');
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Institution Details',
                style: AppTextStyles.screenTitle,
              ),
              const SizedBox(height: 6),
              Text(
                'Register your institution to access Qudra services',
                style: AppTextStyles.description,
              ),
              const SizedBox(height: 28),
              CustomTextField(
                controller: _nameController,
                label: 'Institution Name *',
                hint: 'e.g. Cairo Rehabilitation Center',
                prefixIcon:
                const Icon(Icons.business, color: AppColors.iconGrey),
                keyboardType: TextInputType.text,
              ),
              CustomTextField(
                controller: _emailController,
                label: 'Official Email *',
                hint: 'contact@institution.com',
                prefixIcon:
                const Icon(Icons.mail_outline, color: AppColors.iconGrey),
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Min. 8 characters',
                obscureText: true,
                prefixIcon:
                const Icon(Icons.lock_outline, color: AppColors.iconGrey),
                keyboardType: TextInputType.visiblePassword,
              ),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                hint: '01234567890',
                prefixIcon:
                const Icon(Icons.phone, color: AppColors.iconGrey),
                keyboardType: TextInputType.phone,
              ),
              CustomTextField(
                controller: _addressController,
                label: 'Address *',
                hint: 'Full address',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.iconGrey,
                ),
                keyboardType: TextInputType.streetAddress,
              ),

              // Dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Institution Type *',
                      style: AppTextStyles.fieldLabel,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          hint: Text(
                            'Select type',
                            style: AppTextStyles.hint,
                          ),
                          items: _institutionTypes
                              .map(
                                (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedType = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomTextField(
                controller: _locationController,
                label: 'Location Link',
                hint: 'Google Maps link',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.iconGrey,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 10),
              AuthButton(
                label: 'Register Institution',
                onPressed: _onSignUp,
                trailingIcon:
                const Icon(Icons.arrow_forward, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/institutionLogin'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already registered? ',
                      style: TextStyle(color: AppColors.primary),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: AppTextStyles.underlineLink,
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
    );
  }
}